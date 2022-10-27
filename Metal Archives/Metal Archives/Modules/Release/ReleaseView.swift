//
//  ReleaseView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 30/07/2022.
//

import SwiftUI

struct ReleaseView: View {
    @StateObject private var viewModel: ReleaseViewModel
    private let apiService: APIServiceProtocol

    init(apiService: APIServiceProtocol,
         urlString: String,
         parentRelease: Release?) {
        self.apiService = apiService
        let vm = ReleaseViewModel(apiService: apiService,
                                  urlString: urlString,
                                  parentRelease: parentRelease)
        _viewModel = .init(wrappedValue: vm)
    }

    var body: some View {
        ZStack {
            switch viewModel.releaseFetchable {
            case .fetching:
                HornCircularLoader()
            case .fetched(let release):
                ReleaseContentView(apiService: apiService,
                                   release: release)
                .environmentObject(viewModel)
            case .error(let error):
                VStack {
                    Text(error.userFacingMessage)
                    RetryButton(onRetry: {
                        Task {
                            await viewModel.fetchRelease()
                        }
                    })
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
    @ObservedObject private var tabsDatasource = ReleaseTabsDatasource()
    @State private var titleViewAlpha = 0.0
    @State private var coverViewHeight: CGFloat = 300
    @State private var coverScaleFactor: CGFloat = 1.0
    @State private var coverOpacity: Double = 1.0
    @State private var selectedBandUrl: String?
    @State private var selectedArtistUrl: String?
    @State private var selectedReleaseUrl: String?
    @State private var selectedLabelUrl: String?
    @State private var selectedReviewUrl: String?
    @State private var selectedUserUrl: String?
    @State private var selectedLineUpMode: ReleaseLineUpMode = .bandMembers
    private let minCoverScaleFactor: CGFloat = 0.5
    private let maxCoverScaleFactor: CGFloat = 1.2
    let apiService: APIServiceProtocol
    let release: Release

    var body: some View {
        let isShowingBandDetail = makeIsShowingBandDetailBinding()
        let isShowingArtistDetail = makeIsShowingArtistDetailBinding()
        let isShowingReleaseDetail = makeIsShowingReleaseDetailBinding()
        let isShowingLabelDetail = makeIsShowingLabelDetailBinding()
        let isShowingReviewDetail = makeIsShowingReviewDetailBinding()
        let isShowingUserDetail = makeIsShowingUserDetailBinding()

        ZStack(alignment: .top) {
            NavigationLink(
                isActive: isShowingBandDetail,
                destination: {
                    if let selectedBandUrl {
                        BandView(apiService: apiService, bandUrlString: selectedBandUrl)
                    } else {
                        EmptyView()
                    }},
                label: { EmptyView() })

            NavigationLink(
                isActive: isShowingArtistDetail,
                destination: {
                    if let selectedArtistUrl {
                        ArtistView(apiService: apiService, urlString: selectedArtistUrl)
                    } else {
                        EmptyView()
                    }},
                label: { EmptyView() })

            NavigationLink(
                isActive: isShowingReleaseDetail,
                destination: {
                    if let selectedReleaseUrl {
                        ReleaseView(apiService: apiService,
                                    urlString: selectedReleaseUrl,
                                    parentRelease: viewModel.parentRelease ?? viewModel.release)
                    } else {
                        EmptyView()
                    }},
                label: { EmptyView() })

            NavigationLink(
                isActive: isShowingLabelDetail,
                destination: {
                    if let selectedLabelUrl {
                        LabelView(apiService: apiService, urlString: selectedLabelUrl)
                    } else {
                        EmptyView()
                    }},
                label: { EmptyView() })

            NavigationLink(
                isActive: isShowingReviewDetail,
                destination: {
                    if let selectedReviewUrl {
                        ReviewView(apiService: apiService, urlString: selectedReviewUrl)
                    } else {
                        EmptyView()
                    }},
                label: { EmptyView() })

            NavigationLink(
                isActive: isShowingUserDetail,
                destination: {
                    if let selectedUserUrl {
                        UserView(apiService: apiService, urlString: selectedUserUrl)
                    } else {
                        EmptyView()
                    }},
                label: { EmptyView() })

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
                    if point.y < 0,
                       abs(point.y) > (min(screenBounds.width, screenBounds.height) / 4) {
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
                                        onSelectBand: { url in selectedBandUrl = url },
                                        onSelectLabel: { url in selectedLabelUrl = url })

                        HorizontalTabs(datasource: tabsDatasource)
                            .padding(.vertical)
                            .background(Color(.systemBackground))

                        let screenBounds = UIScreen.main.bounds
                        let maxSize = max(screenBounds.height, screenBounds.width)
                        let bottomSectionMinHeight = maxSize - coverViewHeight // 🪄✨
                        ZStack {
                            switch tabsDatasource.selectedTab {
                            case .songs:
                                TracklistView(apiService: apiService,
                                              elements: release.elements)
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                            case .lineUp:
                                ReleaseLineUpView(lineUpMode: $selectedLineUpMode,
                                                  release: release,
                                                  onSelectArtist: { url in selectedArtistUrl = url })
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                            case .otherVersions:
                                OtherVersionsView(viewModel: viewModel,
                                                  onSelectRelease: { url in selectedReleaseUrl = url })
                                    .frame(maxWidth: .infinity, alignment: .leading)

                            case .reviews:
                                if release.reviews.isEmpty {
                                    Text("No reviews yet")
                                        .font(.callout.italic())
                                        .padding(.horizontal)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                } else {
                                    ReleaseReviewsView(reviews: release.reviews,
                                                       onSelectReview: { url in selectedReviewUrl = url },
                                                       onSelectUser: { url in selectedUserUrl = url })
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
                })
        }
        .modifier(IgnoreTopSafeArea(shouldIgnore: !viewModel.noCover))
        .toolbar { toolbarContent }
        .onReceive(viewModel.$noCover) { noCover in
            if noCover {
                coverViewHeight = 0
            }
        }
    }

    private func makeIsShowingBandDetailBinding() -> Binding<Bool> {
        .init(get: {
            selectedBandUrl != nil
        }, set: { newValue in
            if !newValue {
                selectedBandUrl = nil
            }
        })
    }

    private func makeIsShowingArtistDetailBinding() -> Binding<Bool> {
        .init(get: {
            selectedArtistUrl != nil
        }, set: { newValue in
            if !newValue {
                selectedArtistUrl = nil
            }
        })
    }

    private func makeIsShowingReleaseDetailBinding() -> Binding<Bool> {
        .init(get: {
            selectedReleaseUrl != nil
        }, set: { newValue in
            if !newValue {
                selectedReleaseUrl = nil
            }
        })
    }

    private func makeIsShowingLabelDetailBinding() -> Binding<Bool> {
        .init(get: {
            selectedLabelUrl != nil
        }, set: { newValue in
            if !newValue {
                selectedLabelUrl = nil
            }
        })
    }

    private func makeIsShowingReviewDetailBinding() -> Binding<Bool> {
        .init(get: {
            selectedReviewUrl != nil
        }, set: { newValue in
            if !newValue {
                selectedReviewUrl = nil
            }
        })
    }

    private func makeIsShowingUserDetailBinding() -> Binding<Bool> {
        .init(get: {
            selectedUserUrl != nil
        }, set: { newValue in
            if !newValue {
                selectedUserUrl = nil
            }
        })
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Group {
                switch viewModel.coverFetchable {
                case .fetched(let image):
                    if let image = image {
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
struct ReleaseView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ReleaseView(apiService: APIService(),
                        releaseUrlString: "https://www.metal-archives.com/albums/Death/Human/606")
        }
        .environment(\.colorScheme, .dark)
        .environmentObject(Preferences())
    }
}
*/

private struct IgnoreTopSafeArea: ViewModifier {
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
