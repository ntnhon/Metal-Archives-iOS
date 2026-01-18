//
//  ReleaseView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 30/07/2022.
//

import SwiftUI

struct ReleaseView: View {
    @StateObject private var viewModel: ReleaseViewModel
    @Binding private var path: NavigationPath

    init(urlString: String,
         parentRelease: Release?,
         path: Binding<NavigationPath>) {
        let vm = ReleaseViewModel(urlString: urlString, parentRelease: parentRelease)
        _viewModel = .init(wrappedValue: vm)
        _path = path
    }

    var body: some View {
        ZStack {
            switch viewModel.releaseFetchable {
            case .fetching:
                MALoadingIndicator()
            case let .fetched(release):
                ReleaseContentView(path: $path, release: release)
                    .environmentObject(viewModel)
            case let .error(error):
                VStack {
                    Text(error.userFacingMessage)
                    RetryButton {
                        await viewModel.fetchRelease()
                    }
                }
            }
        }
        .task {
            await viewModel.fetchRelease()
        }
    }
}

private struct ReleaseContentView: View {
    @EnvironmentObject private var preferences: Preferences
    @EnvironmentObject private var viewModel: ReleaseViewModel
    @Environment(\.selectedPhoto) private var selectedPhoto
    @StateObject private var tabsDatasource = ReleaseTabsDatasource()
    @State private var titleViewAlpha = 0.0
    @State private var coverViewHeight: CGFloat = 300
    @State private var coverScaleFactor: CGFloat = 1.0
    @State private var coverOpacity: Double = 1.0
    @Binding var path: NavigationPath
    @State private var selectedLineUpMode: ReleaseLineUpMode = .bandMembers
    private let minCoverScaleFactor: CGFloat = 0.5
    private let maxCoverScaleFactor: CGFloat = 1.2
    let release: Release

    var body: some View {
        ZStack(alignment: .top) {
            ReleaseCoverView(scaleFactor: $coverScaleFactor,
                             opacity: $coverOpacity)
                .environmentObject(viewModel)
                .frame(height: coverViewHeight)
                .opacity(viewModel.noCover ? 0 : 1)

            OffsetAwareScrollView(
                axes: .vertical,
                showsIndicator: true,
                onOffsetChanged: { point in
                    /// Calculate `titleViewAlpha`
                    let screenBounds = UIScreen.main.bounds
                    if point.y<0,
                        abs(point.y)>(min(screenBounds.width, screenBounds.height) / 4)
                    {
                        titleViewAlpha = (abs(point.y) + 300) / min(screenBounds.width, screenBounds.height)
                    } else {
                        titleViewAlpha = 0.0
                    }

                    /// Calculate `coverScaleFactor` & `coverOpacity`
                    if point.y < 0 {
                        var factor = min(1.0, 70 / abs(point.y))
                        factor = factor < minCoverScaleFactor ? minCoverScaleFactor : factor
                        coverScaleFactor = factor
                        coverOpacity = (factor - minCoverScaleFactor) / minCoverScaleFactor
                    } else {
                        var factor = max(1.0, point.y / 70)
                        factor = factor > maxCoverScaleFactor ? maxCoverScaleFactor : factor
                        coverScaleFactor = factor
                    }
                },
                content: {
                    VStack(alignment: .leading, spacing: 0) {
                        Color.gray
                            .opacity(0.001)
                            .frame(height: coverViewHeight)
                            .onTapGesture {
                                if let coverImage = viewModel.cover {
                                    selectedPhoto.wrappedValue = .init(image: coverImage,
                                                                       description: viewModel.release?.title ?? "")
                                }
                            }

                        ReleaseInfoView(release: release,
                                        onSelectBand: { url in path.append(Detail.band(url)) },
                                        onSelectLabel: { url in path.append(Detail.label(url)) })

                        HorizontalTabs(datasource: tabsDatasource)
                            .padding(.vertical)
                            .background(Color(.systemBackground))

                        let screenBounds = UIScreen.main.bounds
                        let maxSize = max(screenBounds.height, screenBounds.width)
                        let bottomSectionMinHeight = maxSize - coverViewHeight // 🪄✨
                        ZStack {
                            switch tabsDatasource.selectedTab {
                            case .songs:
                                TracklistView(elements: release.elements)
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                            case .lineUp:
                                ReleaseLineUpView(lineUpMode: $selectedLineUpMode,
                                                  release: release,
                                                  onSelectArtist: { url in path.append(Detail.artist(url)) })
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                            case .otherVersions:
                                OtherVersionsView(viewModel: viewModel,
                                                  onSelectRelease: { url in path.append(Detail.release(url)) })
                                    .frame(maxWidth: .infinity, alignment: .leading)

                            case .reviews:
                                if release.reviews.isEmpty {
                                    Text("No reviews yet")
                                        .font(.callout.italic())
                                        .padding(.horizontal)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                } else {
                                    ReleaseReviewsView(reviews: release.reviews,
                                                       onSelectReview: { url in path.append(Detail.review(url)) },
                                                       onSelectUser: { url in path.append(Detail.user(url)) })
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }

                            case .additionalNotes:
                                ReleaseNoteView(release: release)
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .frame(minHeight: bottomSectionMinHeight, alignment: .top)
                        .background(Color(.systemBackground))
                    }
                }
            )
        }
        .toolbar { toolbarContent }
        .onReceive(viewModel.$noCover) { noCover in
            if noCover {
                coverViewHeight = 0
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Group {
                switch viewModel.coverFetchable {
                case let .fetched(image):
                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50)
                            .padding(.vertical, 4)
                    }
                default:
                    EmptyView()
                }
            }
            .opacity(titleViewAlpha)
        }

        ToolbarItem(placement: .principal) {
            Text(release.title)
                .font(.title2)
                .fontWeight(.bold)
                .textSelection(.enabled)
                .minimumScaleFactor(0.5)
                .opacity(titleViewAlpha)
        }
    }
}

/*
 struct IgnoreTopSafeArea: ViewModifier {
     let shouldIgnore: Bool

     func body(content: Content) -> some View {
         if shouldIgnore {
             content
                 .ignoresSafeArea(edges: .top)
         } else {
             content
         }
     }
 }
 */
