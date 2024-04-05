//
//  UserReleasesView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 09/11/2022.
//

import SwiftUI

struct UserReleasesView: View {
    @EnvironmentObject private var preferences: Preferences
    @ObservedObject var viewModel: UserReleasesViewModel
    @State private var selectedRelease: UserRelease?
    let onSelectBand: (String) -> Void
    let onSelectRelease: (String) -> Void

    var body: some View {
        let isShowingAlert: Binding<Bool> = .init(get: {
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
                Text("This list is private or empty")
                    .font(.callout.italic())
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                releaseList
            }
        }
        .task {
            await viewModel.getMoreReleases(force: false)
        }
        .confirmationDialog("",
                            isPresented: isShowingAlert)
        {
            if let selectedRelease {
                Button(action: {
                    onSelectRelease(selectedRelease.release.thumbnailInfo.urlString)
                }, label: {
                    Text("💿 \(selectedRelease.release.title)")
                })

                ForEach(selectedRelease.bands, id: \.hashValue) { band in
                    Button(action: {
                        onSelectBand(band.thumbnailInfo.urlString)
                    }, label: {
                        Text(band.name)
                    })
                }
            }
        }
    }

    @ViewBuilder
    private var releaseList: some View {
        LazyVStack {
            let entryCount = viewModel.manager.total
            if entryCount == 1 {
                Text("1 release")
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text("\(viewModel.manager.total) total releases")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            ForEach(viewModel.releases, id: \.hashValue) { release in
                UserReleaseView(release: release)
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
}

private struct UserReleaseView: View {
    @EnvironmentObject private var preferences: Preferences
    let release: UserRelease

    var body: some View {
        HStack {
            ThumbnailView(thumbnailInfo: release.release.thumbnailInfo,
                          photoDescription: release.release.title)
                .font(.largeTitle)
                .foregroundColor(preferences.theme.secondaryColor)
                .frame(width: 64, height: 64)

            VStack(alignment: .leading) {
                Text(release.release.title)
                    .fontWeight(.bold)
                    .foregroundColor(preferences.theme.primaryColor)

                HighlightableText(text: release.bands.map { $0.name }.joined(separator: " / "),
                                  highlights: release.bands.map { $0.name },
                                  highlightFontWeight: .bold,
                                  highlightColor: preferences.theme.secondaryColor)

                Text(release.version) + Text(release.releaseNote ?? "")

                if let note = release.note {
                    Text(note)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
}
