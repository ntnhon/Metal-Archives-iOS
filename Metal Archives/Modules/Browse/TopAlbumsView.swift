//
//  TopAlbumsView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 17/10/2022.
//

import SwiftUI

struct TopAlbumsView: View {
    @StateObject private var viewModel = TopAlbumsViewModel()
    @Binding var path: NavigationPath

    var body: some View {
        ZStack {
            switch viewModel.topReleasesFetchable {
            case .fetching:
                MALoadingIndicator()
            case .fetched:
                List {
                    ForEach(0 ..< viewModel.releases.count, id: \.self) { index in
                        let topRelease = viewModel.releases[index]
                        TopAlbumView(
                            topRelease: topRelease,
                            index: index,
                            onSelectRelease: {
                                path.append(Detail.release(topRelease.release.thumbnailInfo.urlString))
                            },
                            onSelectBand: {
                                path.append(Detail.band(topRelease.band.thumbnailInfo.urlString))
                            }
                        )
                    }
                }
                .listStyle(.plain)
            case let .error(error):
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
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if viewModel.isFetched {
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
                    .disabled(!viewModel.isFetched)
                }
            }
        }
        .task {
            await viewModel.fetchTopReleases()
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
         onSelectBand: @escaping () -> Void)
    {
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
        .alert("#\(index + 1)",
               isPresented: $isShowingDialog,
               actions: {
                   Button(release.title, action: onSelectRelease)
                   Button(band.name, action: onSelectBand)
                   Button("Cancel", role: .cancel, action: {})
               },
               message: {
                   Text("\"\(release.title)\" by \"\(band.name)\"")
               })
    }
}
