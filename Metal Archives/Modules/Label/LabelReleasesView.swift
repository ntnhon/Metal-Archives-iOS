//
//  LabelReleasesView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 06/11/2022.
//

import SwiftUI

struct LabelReleasesView: View {
    @EnvironmentObject private var preferences: Preferences
    @ObservedObject var viewModel: LabelReleasesViewModel
    @State private var selectedRelease: LabelRelease?
    let onSelectBand: (String) -> Void
    let onSelectRelease: (String) -> Void

    var body: some View {
        let isShowingAlert = Binding<Bool>(get: {
            selectedRelease != nil
        }, set: { newValue in
            if !newValue {
                selectedRelease = nil
            }
        })
        ZStack {
            if let error = viewModel.error {
                VStack {
                    Text(error.userFacingMessage)
                    RetryButton(onRetry: viewModel.refresh)
                }
            } else if viewModel.manager.isLoading, viewModel.releases.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else if viewModel.releases.isEmpty {
                Text("No releases")
                    .font(.callout.italic())
            } else {
                releaseList
            }
        }
        .task {
            await viewModel.getMoreReleases(force: false)
        }
        .confirmationDialog(
            "",
            isPresented:
            isShowingAlert,
            actions: {
                if let selectedRelease {
                    Button(action: {
                        onSelectRelease(selectedRelease.release.thumbnailInfo.urlString)
                    }, label: {
                        Text("View release's detail")
                    })

                    Button(action: {
                        onSelectBand(selectedRelease.band.thumbnailInfo.urlString)
                    }, label: {
                        Text("View band's detail")
                    })
                }
            },
            message: {
                if let selectedRelease {
                    Text("\"\(selectedRelease.release.title)\" by \(selectedRelease.band.name)")
                }
            }
        )
    }

    @ViewBuilder
    private var releaseList: some View {
        LazyVStack {
            HStack {
                let entryCount = viewModel.manager.total
                if entryCount == 1 {
                    Text("1 release")
                } else {
                    Text("\(viewModel.manager.total) total releases")
                }
                Spacer()
                sortOptions
            }
            ForEach(viewModel.releases, id: \.hashValue) { release in
                LabelReleaseView(release: release)
                    .onTapGesture {
                        selectedRelease = release
                    }
                    .task {
                        if release == viewModel.releases.last {
                            await viewModel.getMoreReleases(force: true)
                        }
                    }

                Divider()

                if release == viewModel.releases.last, viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .listStyle(.plain)
    }

    private var sortOptions: some View {
        Menu(content: {
            Group {
                Button(action: {
                    viewModel.sortOption = .band(.ascending)
                }, label: {
                    view(for: .band(.ascending))
                })

                Button(action: {
                    viewModel.sortOption = .band(.descending)
                }, label: {
                    view(for: .band(.descending))
                })

                Button(action: {
                    viewModel.sortOption = .type(.ascending)
                }, label: {
                    view(for: .type(.ascending))
                })

                Button(action: {
                    viewModel.sortOption = .type(.descending)
                }, label: {
                    view(for: .type(.descending))
                })
            }

            Group {
                Button(action: {
                    viewModel.sortOption = .year(.ascending)
                }, label: {
                    view(for: .year(.ascending))
                })

                Button(action: {
                    viewModel.sortOption = .year(.descending)
                }, label: {
                    view(for: .year(.descending))
                })

                Button(action: {
                    viewModel.sortOption = .catalog(.ascending)
                }, label: {
                    view(for: .catalog(.ascending))
                })

                Button(action: {
                    viewModel.sortOption = .catalog(.descending)
                }, label: {
                    view(for: .catalog(.descending))
                })

                Button(action: {
                    viewModel.sortOption = .format(.ascending)
                }, label: {
                    view(for: .format(.ascending))
                })

                Button(action: {
                    viewModel.sortOption = .format(.descending)
                }, label: {
                    view(for: .format(.descending))
                })
            }
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
        .opacity(viewModel.releases.isEmpty ? 0 : 1)
        .disabled(viewModel.releases.isEmpty)
    }

    @ViewBuilder
    private func view(for option: LabelReleasePageManager.SortOption) -> some View {
        if option == viewModel.sortOption {
            Label(option.title, systemImage: "checkmark")
        } else {
            Text(option.title)
        }
    }
}

private struct LabelReleaseView: View {
    @EnvironmentObject private var preferences: Preferences
    let release: LabelRelease

    var body: some View {
        HStack {
            ThumbnailView(thumbnailInfo: release.release.thumbnailInfo, photoDescription: release.release.title)
                .font(.largeTitle)
                .foregroundColor(preferences.theme.secondaryColor)
                .frame(width: 64, height: 64)

            VStack(alignment: .leading) {
                Text(release.release.title)
                    .fontWeight(.bold)
                    .foregroundColor(preferences.theme.primaryColor)

                Text(release.band.name)
                    .fontWeight(.semibold)
                    .foregroundColor(preferences.theme.secondaryColor)

                Text(release.year) +
                    Text(" • ") +
                    Text(release.type.description)
                    .foregroundColor(release.type.titleForegroundColor(preferences.theme))

                Text(release.catalog)
                    .font(.callout)
                Text(release.format)
                    .font(.callout)
                if let description = release.description {
                    Text(description)
                        .font(.callout)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
}
