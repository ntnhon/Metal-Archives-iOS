//
//  UpcomingAlbumsSection.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 04/12/2022.
//

import SnapToScroll
import SwiftUI

typealias UpcomingAlbumsSectionViewModel = HomeSectionViewModel<UpcomingAlbum>

struct UpcomingAlbumsSection: View {
    @StateObject private var viewModel: UpcomingAlbumsSectionViewModel
    @Binding var detail: Detail?

    init(apiService: APIServiceProtocol,
         detail: Binding<Detail?>) {
        self._viewModel = .init(wrappedValue: .init(apiService: apiService,
                                                    manager: UpcomingAlbumPageManager(apiService: apiService)))
        self._detail = detail
    }

    var body: some View {
        ZStack {
            if let error = viewModel.error {
                VStack {
                    Text(error.userFacingMessage)
                    RetryButton(onRetry: viewModel.refresh)
                }
            } else {
                VStack(spacing: 0) {
                    HStack {
                        Text("Upcoming albums")
                            .font(.title2)
                            .fontWeight(.bold)

                        Spacer()

                        if !viewModel.isLoading && !viewModel.results.isEmpty {
                            Button(action: {
                                print("See All")
                            }, label: {
                                Text("See all")
                            })
                        }
                    }
                    .padding(.horizontal)

                    if viewModel.isLoading && viewModel.results.isEmpty {
                        HomeSectionSkeletonView()
                    } else if viewModel.results.isEmpty {
                        Text("No upcoming albums")
                            .font(.callout.italic())
                    } else {
                        resultList
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .task {
            await viewModel.getMoreResults(force: false)
        }
    }

    private var resultList: some View {
        HStackSnap(alignment: .leading(24)) {
            ForEach(viewModel.chunkedResults, id: \.hashValue) { upcomingAlbums in
                VStack(spacing: HomeSettings.entrySpacing) {
                    ForEach(upcomingAlbums) { album in
                        UpcomingAlbumView(detail: $detail, upcomingAlbum: album)
                    }
                }
                .snapAlignmentHelper(id: upcomingAlbums.hashValue)
            }
        }
        .frame(height: HomeSettings.pageHeight)
    }
}

private struct UpcomingAlbumView: View {
    @EnvironmentObject private var preferences: Preferences
    @State private var isShowingConfirmationDialog = false
    @Binding var detail: Detail?
    let upcomingAlbum: UpcomingAlbum

    var body: some View {
        HStack {
            ThumbnailView(thumbnailInfo: upcomingAlbum.release.thumbnailInfo,
                          photoDescription: upcomingAlbum.release.title)
            .font(.largeTitle)
            .foregroundColor(preferences.theme.secondaryColor)
            .frame(width: 64, height: 64)

            VStack(alignment: .leading) {
                let texts = upcomingAlbum.bands
                    .generateTexts(fontWeight: .bold,
                                   foregroundColor: preferences.theme.primaryColor)
                texts.reduce(into: Text("")) { partialResult, text in
                    // swiftlint:disable:next shorthand_operator
                    partialResult = partialResult + text
                }
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(2)
                .minimumScaleFactor(0.5)

                Text(upcomingAlbum.release.title)
                    .fontWeight(.semibold)
                    .foregroundColor(preferences.theme.secondaryColor)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)

                Text(upcomingAlbum.releaseType.description)
                    .fontWeight(upcomingAlbum.releaseType == .fullLength ? .heavy : .regular) +
                Text(" • ") +
                Text(upcomingAlbum.date)

                Text(upcomingAlbum.genre)
                    .font(.callout.italic())
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)

                Divider()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: HomeSettings.entryWidth)
        .contentShape(Rectangle())
        .onTapGesture { isShowingConfirmationDialog.toggle() }
        .confirmationDialog(
            "Upcoming album",
            isPresented: $isShowingConfirmationDialog,
            actions: {
                Button(action: {
                    detail = .release(upcomingAlbum.release.thumbnailInfo.urlString)
                }, label: {
                    Text("View release's detail")
                })

                ForEach(upcomingAlbum.bands) { band in
                    Button(action: {
                        detail = .band(band.thumbnailInfo.urlString)
                    }, label: {
                        if upcomingAlbum.bands.count == 1 {
                            Text("View band's detail")
                        } else {
                            Text(band.name)
                        }
                    })
                }
            },
            message: {
                Text("\"\(upcomingAlbum.release.title)\" by \(upcomingAlbum.bandsName)")
            })
    }
}
