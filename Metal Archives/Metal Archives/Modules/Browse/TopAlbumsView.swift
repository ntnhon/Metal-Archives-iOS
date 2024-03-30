//
//  TopAlbumsView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 17/10/2022.
//

import SwiftUI

struct TopAlbumsView: View {
    @StateObject private var viewModel: TopAlbumsViewModel
    @State private var detail: Detail?

    init(apiService: APIServiceProtocol) {
        _viewModel = .init(wrappedValue: .init(apiService: apiService))
    }

    var body: some View {
        ZStack {
            DetailView(detail: $detail, apiService: viewModel.apiService)

            switch viewModel.topReleasesFetchable {
            case .fetching:
                HornCircularLoader()
            case .fetched:
                List {
                    ForEach(0..<viewModel.releases.count, id: \.self) { index in
                        let topRelease = viewModel.releases[index]
                        TopAlbumView(
                            topRelease: topRelease,
                            index: index,
                            onSelectRelease: {
                                detail = .release(topRelease.release.thumbnailInfo.urlString)
                            },
                            onSelectBand: {
                                detail = .band(topRelease.band.thumbnailInfo.urlString)
                            })
                    }
                }
                .listStyle(.plain)
            case .error(let error):
                HStack {
                    Text(error.userFacingMessage)
                    RetryButton {
                        await viewModel.fetchTopReleases()
                    }
                }
            }
        }
        .navigationTitle("Top 100 albums")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .task {
            await viewModel.fetchTopReleases()
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Menu(content: {
                ForEach(TopAlbumsCategory.allCases, id: \.self) { category in
                    Button(action: {
                        viewModel.category = category
                    }, label: {
                        if viewModel.category == category {
                            Label(category.description, systemImage: "checkmark")
                        } else {
                            Text(category.description)
                        }
                    })
                }
            }, label: {
                Text(viewModel.category.description)
            })
            .transaction { transaction in
                transaction.animation = nil
            }
            .opacity(viewModel.isFetched ? 1 : 0)
            .disabled(!viewModel.isFetched)
        }
    }
}

private struct TopAlbumView: View {
    @EnvironmentObject private var preferences: Preferences
    @State private var isShowingDialog = false
    let topRelease: TopRelease
    let index: Int
    let onSelectRelease: () -> Void
    let onSelectBand: () -> Void

    init(topRelease: TopRelease,
         index: Int,
         onSelectRelease: @escaping () -> Void,
         onSelectBand: @escaping () -> Void) {
        self.topRelease = topRelease
        self.index = index
        self.onSelectRelease = onSelectRelease
        self.onSelectBand = onSelectBand
    }

    var body: some View {
        let release = topRelease.release
        let band = topRelease.band
        HStack {
            Text("\(index + 1). ")

            ThumbnailView(thumbnailInfo: release.thumbnailInfo,
                          photoDescription: release.title)
            .font(.largeTitle)
            .foregroundColor(preferences.theme.secondaryColor)
            .frame(width: 64, height: 64)

            VStack(alignment: .leading) {
                Text(release.title)
                    .fontWeight(.bold)
                    .foregroundColor(preferences.theme.primaryColor)

                Text(band.name)
                    .foregroundColor(preferences.theme.secondaryColor)

                Spacer()
            }
            .padding(.vertical)

            Spacer()

            Text("\(topRelease.count)")
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isShowingDialog.toggle()
        }
        .confirmationDialog(
            "",
            isPresented: $isShowingDialog,
            actions: {
                Button(release.title, action: onSelectRelease)

                Button(band.name, action: onSelectBand)
            },
            message: {
                Text("Top #\(index + 1)\n\"\(release.title)\" by \(band.name)")
            })
    }
}
