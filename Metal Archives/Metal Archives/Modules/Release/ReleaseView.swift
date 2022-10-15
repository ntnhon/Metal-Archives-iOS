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
         releaseUrlString: String) {
        self.apiService = apiService
        let vm = ReleaseViewModel(apiService: apiService,
                                  releaseUrlString: releaseUrlString)
        _viewModel = .init(wrappedValue: vm)
    }

    var body: some View {
        ZStack {
            switch viewModel.releaseFetchable {
            case .fetching, .waiting:
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
    @State private var selectedLabelUrl: String?
    private let minCoverScaleFactor: CGFloat = 0.5
    private let maxCoverScaleFactor: CGFloat = 1.2
    let apiService: APIServiceProtocol
    let release: Release

    var body: some View {
        let isShowingBandDetail = makeIsShowingBandDetailBinding()
        let isShowingLabelDetail = makeIsShowingLabelDetailBinding()

        ZStack(alignment: .top) {
            NavigationLink(
                isActive: isShowingBandDetail,
                destination: {
                    if let selectedBandUrl = selectedBandUrl {
                        BandView(apiService: apiService, bandUrlString: selectedBandUrl)
                    } else {
                        EmptyView()
                    }},
                label: { EmptyView() })

            NavigationLink(
                isActive: isShowingLabelDetail,
                destination: {
                    if let selectedLabelUrl = selectedLabelUrl {
                        LabelView(apiService: apiService, urlString: selectedLabelUrl)
                    } else {
                        EmptyView()
                    }},
                label: { EmptyView() })

            ReleaseCoverView(scaleFactor: $coverScaleFactor,
                             opacity: $coverOpacity)
                .environmentObject(viewModel)
                .frame(height: coverViewHeight)

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
                        Color.clear
                            .frame(height: coverViewHeight)

                        ReleaseInfoView(release: release,
                                        onSelectBand: { url in selectedBandUrl = url },
                                        onSelectLabel: { url in selectedLabelUrl = url })

                        HorizontalTabs(datasource: tabsDatasource)
                            .padding(.vertical)
                            .background(Color(.systemBackground))

                        let screenBounds = UIScreen.main.bounds
                        let maxSize = max(screenBounds.height, screenBounds.width)
                        let bottomSectionMinHeight = maxSize - coverViewHeight // 🪄✨
                        Group {
                            switch tabsDatasource.selectedTab {
                            case .songs:
                                TracklistView(apiService: apiService,
                                              elements: release.elements)
                                    .padding(.horizontal)

                            case .lineUp:
                                ReleaseLineUpView()
                                    .padding(.horizontal)

                            case .otherVersions:
                                OtherVersionsView()

                            case .reviews:
                                ReleaseReviewsView(reviews: release.reviews)

                            case .additionalNotes:
                                ReleaseNoteView()
                            }
                        }
                        .frame(minHeight: bottomSectionMinHeight, alignment: .top)
                        .background(Color(.systemBackground))
                    }
                })
        }
        .edgesIgnoringSafeArea(.top)
        .toolbar { toolbarContent }
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

    private func makeIsShowingLabelDetailBinding() -> Binding<Bool> {
        .init(get: {
            selectedLabelUrl != nil
        }, set: { newValue in
            if !newValue {
                selectedLabelUrl = nil
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
