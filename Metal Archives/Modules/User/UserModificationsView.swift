//
//  UserModificationsView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 08/11/2022.
//

import SwiftUI

struct UserModificationsView: View {
    @EnvironmentObject private var preferences: Preferences
    @ObservedObject var viewModel: UserModificationsViewModel
    let onSelectBand: (String) -> Void
    let onSelectArtist: (String) -> Void
    let onSelectRelease: (String) -> Void
    let onSelectLabel: (String) -> Void

    var body: some View {
        ZStack {
            if let error = viewModel.error {
                VStack {
                    Text(error.userFacingMessage)
                    RetryButton(onRetry: viewModel.refresh)
                }
            } else if viewModel.manager.isLoading, viewModel.modifications.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else if viewModel.modifications.isEmpty {
                Text("No modifications")
                    .font(.callout.italic())
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                reviewList
            }
        }
        .task {
            await viewModel.getMoreModifications(force: false)
        }
    }

    @ViewBuilder
    private var reviewList: some View {
        LazyVStack {
            HStack {
                let entryCount = viewModel.manager.total
                if entryCount == 1 {
                    Text("1 modification")
                } else {
                    Text("\(viewModel.manager.total) total modifications")
                }
                Spacer()
                sortOptions
            }
            ForEach(viewModel.modifications, id: \.hashValue) { modification in
                UserModificationView(modification: modification)
                    .onTapGesture {
                        switch modification.item {
                        case .band(let band):
                            onSelectBand(band.thumbnailInfo.urlString)
                        case .artist(let artist):
                            onSelectArtist(artist.thumbnailInfo.urlString)
                        case .release(let release):
                            onSelectRelease(release.thumbnailInfo.urlString)
                        case .label(let label):
                            if let urlString = label.thumbnailInfo?.urlString {
                                onSelectLabel(urlString)
                            }
                        default:
                            break
                        }
                    }
                    .task {
                        if modification == viewModel.modifications.last {
                            await viewModel.getMoreModifications(force: true)
                        }
                    }

                Divider()

                if modification == viewModel.modifications.last, viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .listStyle(.plain)
    }

    private var sortOptions: some View {
        Menu(content: {
            Button(action: {
                viewModel.sortOption = .date(.ascending)
            }, label: {
                view(for: .date(.ascending))
            })

            Button(action: {
                viewModel.sortOption = .date(.descending)
            }, label: {
                view(for: .date(.descending))
            })

            Button(action: {
                viewModel.sortOption = .item(.ascending)
            }, label: {
                view(for: .item(.ascending))
            })

            Button(action: {
                viewModel.sortOption = .item(.descending)
            }, label: {
                view(for: .item(.descending))
            })
        }, label: {
            Text(viewModel.sortOption.title)
                .padding(8)
                .background(preferences.theme.primaryColor)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        })
        .transaction { transaction in
            transaction.animation = nil
        }
        .opacity(viewModel.modifications.isEmpty ? 0 : 1)
        .disabled(viewModel.modifications.isEmpty)
    }

    @ViewBuilder
    private func view(for option: UserModificationPageManager.SortOption) -> some View {
        if option == viewModel.sortOption {
            Label(option.title, systemImage: "checkmark")
        } else {
            Text(option.title)
        }
    }
}

private struct UserModificationView: View {
    @EnvironmentObject private var preferences: Preferences
    let modification: UserModification

    var body: some View {
        HStack {
            if let thumbnailInfo = modification.item.thumbnailInfo {
                ThumbnailView(thumbnailInfo: thumbnailInfo, photoDescription: modification.item.title)
                    .font(.largeTitle)
                    .foregroundColor(preferences.theme.secondaryColor)
                    .frame(width: 64, height: 64)
            }

            VStack(alignment: .leading) {
                Label(title: {
                    Text(modification.item.title)
                        .fontWeight(.bold)
                        .foregroundColor(preferences.theme.primaryColor)
                }, icon: {
                    Image(systemName: modification.item.systemImage)
                })
                Text(modification.date)
                Text(modification.note)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
}
