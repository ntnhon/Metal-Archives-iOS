//
//  UpcomingAlbumsSection.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 04/12/2022.
//

import SnapToScroll
import SwiftUI

typealias UpcomingAlbumsSectionViewModel = AdvancedSearchResultViewModel<UpcomingAlbum>

struct UpcomingAlbumsSection: View {
    @StateObject private var viewModel: UpcomingAlbumsSectionViewModel
    @State private var selectedBandUrl: String?
    @State private var selectedReleaseUrl: String?

    init(apiService: APIServiceProtocol) {
        _viewModel = .init(wrappedValue: .init(apiService: apiService,
                                               manager: UpcomingAlbumPageManager(apiService: apiService)))
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
                        ProgressView()
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
            ForEach(Array(viewModel.results.prefix(HomeSettings.entriesPerPage * 10))
                .chunked(into: HomeSettings.entriesPerPage)) { upcomingAlbums in
                VStack(spacing: HomeSettings.entrySpacing) {
                    ForEach(upcomingAlbums) { album in
                        UpcomingAlbumView(upcomingAlbum: album)
                    }
                }
                .snapAlignmentHelper(id: upcomingAlbums.hashValue)
            }

            Button(action: {
                print("See all")
            }, label: {
                Text("See All")
            })
            .frame(width: HomeSettings.entryWidth)
            .snapAlignmentHelper(id: "See All")
        }
        .frame(height: HomeSettings.pageHeight)
    }
}

private struct UpcomingAlbumView: View {
    @EnvironmentObject private var preferences: Preferences
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
    }
}
