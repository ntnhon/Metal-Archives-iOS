//
//  BandView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 26/06/2021.
//

import Kingfisher
import SwiftUI

struct BandView: View {
    @EnvironmentObject private var preferences: Preferences
    @StateObject private var viewModel: BandViewModel
    let apiService: APIServiceProtocol

    init(apiService: APIServiceProtocol,
         bandUrlString: String) {
        self.apiService = apiService
        let vm = BandViewModel(apiService: apiService,
                               bandUrlString: bandUrlString)
        _viewModel = .init(wrappedValue: vm)
    }

    var body: some View {
        ZStack {
            switch viewModel.bandMetadataFetchable {
            case .error(let error):
                VStack(alignment: .center, spacing: 20) {
                    Text(error.userFacingMessage)
                        .frame(maxWidth: .infinity)
                        .font(.caption)

                    RetryButton {
                        Task {
                            await viewModel.refresh(force: true)
                        }
                    }
                }

            case .fetching:
                HornCircularLoader()

            case .fetched(let metadata):
                BandContentView(metadata: metadata,
                                apiService: apiService,
                                preferences: preferences,
                                viewModel: viewModel)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.refresh(force: false)
        }
    }
}

private struct BandContentView: View {
    @Environment(\.selectedPhoto) private var selectedPhoto
    @ObservedObject private var viewModel: BandViewModel
    @ObservedObject private var tabsDatasource = BandTabsDatasource()
    @StateObject private var reviewsViewModel: BandReviewsViewModel
    @StateObject private var discographyViewModel: DiscographyViewModel
    @StateObject private var similarArtistsViewModel: SimilarArtistsViewModel
    @State private var titleViewAlpha = 0.0
    @State private var showingShareSheet = false
    @State private var topSectionSize: CGSize = .zero
    @State private var selectedBandUrl: String?
    @State private var selectedReleaseUrl: String?
    @State private var selectedLabelUrl: String?
    @State private var selectedReviewUrl: String?
    @State private var selectedUserUrl: String?
    let apiService: APIServiceProtocol
    let metadata: BandMetadata

    init(metadata: BandMetadata,
         apiService: APIServiceProtocol,
         preferences: Preferences,
         viewModel: BandViewModel) {
        self.metadata = metadata
        self.apiService = apiService
        self._discographyViewModel = .init(wrappedValue: .init(discography: metadata.discography,
                                                               discographyMode: preferences.discographyMode,
                                                               order: preferences.dateOrder))
        self._similarArtistsViewModel = .init(wrappedValue: .init(apiService: apiService,
                                                                  band: metadata.band))
        self._reviewsViewModel = .init(wrappedValue: .init(band: metadata.band,
                                                           apiService: apiService,
                                                           discography: metadata.discography))
        self._viewModel = .init(wrappedValue: viewModel)
    }

    var body: some View {
        let band = metadata.band
        let isShowingBand = makeIsShowingBandDetailBinding()
        let isShowingRelease = makeIsShowingReleaseDetailBinding()
        let isShowingLabel = makeIsShowingLabelDetailBinding()
        let isShowingReview = makeIsShowingReviewDetailBinding()
        let isShowingUser = makeIsShowingUserDetailBinding()

        OffsetAwareScrollView(
            axes: .vertical,
            showsIndicator: true,
            onOffsetChanged: { point in
                let screenBounds = UIScreen.main.bounds
                if point.y < 0,
                   abs(point.y) > (min(screenBounds.width, screenBounds.height) * 2 / 3) {
                    titleViewAlpha = abs(point.y) / min(screenBounds.width, screenBounds.height)
                } else {
                    titleViewAlpha = 0.0
                }
            },
            content: {
                VStack {
                    NavigationLink(
                        isActive: isShowingBand,
                        destination: {
                            if let selectedBandUrl {
                                BandView(apiService: apiService, bandUrlString: selectedBandUrl)
                            } else {
                                EmptyView()
                            }
                        }, label: {
                            EmptyView()
                        })

                    NavigationLink(
                        isActive: isShowingRelease,
                        destination: {
                            if let selectedReleaseUrl {
                                ReleaseView(apiService: apiService,
                                            urlString: selectedReleaseUrl,
                                            parentRelease: nil)
                            } else {
                                EmptyView()
                            }
                        }, label: {
                            EmptyView()
                        })

                    NavigationLink(
                        isActive: isShowingLabel,
                        destination: {
                            if let selectedLabelUrl {
                                LabelView(apiService: apiService, urlString: selectedLabelUrl)
                            } else {
                                EmptyView()
                            }
                        }, label: {
                            EmptyView()
                        })

                    NavigationLink(
                        isActive: isShowingReview,
                        destination: {
                            if let selectedReviewUrl {
                                ReviewView(apiService: apiService, urlString: selectedReviewUrl)
                            } else {
                                EmptyView()
                            }
                        }, label: {
                            EmptyView()
                        })

                    NavigationLink(
                        isActive: isShowingUser,
                        destination: {
                            if let selectedUserUrl {
                                UserView(apiService: apiService, urlString: selectedUserUrl)
                            } else {
                                EmptyView()
                            }
                        }, label: {
                            EmptyView()
                        })

                    VStack {
                        BandHeaderView(band: band) { selectedImage in
                            let photo = Photo(image: selectedImage,
                                              description: band.name)
                            selectedPhoto.wrappedValue = photo
                        }

                        BandInfoView(viewModel: .init(band: band, discography: metadata.discography),
                                     onSelectLabel: { url in selectedLabelUrl = url },
                                     onSelectBand: { url in selectedBandUrl = url })
                        .padding(.horizontal)

                        if let readMore = metadata.readMore {
                            BandReadMoreView(band: band, readMore: readMore)
                        }

                        Color(.systemGray6)
                            .frame(height: 10)
                    }
                    .modifier(SizeModifier())
                    .onPreferenceChange(SizePreferenceKey.self) {
                        topSectionSize = $0
                    }

                    HorizontalTabs(datasource: tabsDatasource)
                        .padding(.bottom)

                    let screenBounds = UIScreen.main.bounds
                    let maxSize = max(screenBounds.height, screenBounds.width)
                    let bottomSectionMinHeight = maxSize - topSectionSize.height - 250 // 🪄✨
                    Group {
                        switch tabsDatasource.selectedTab {
                        case .discography:
                            DiscographyView(apiService: apiService,
                                            viewModel: discographyViewModel)
                            .padding(.horizontal)

                        case .members:
                            BandLineUpView(apiService: apiService, band: band)
                                .padding(.horizontal)

                        case .reviews:
                            BandReviewsView(viewModel: reviewsViewModel,
                                            onSelectReview: { url in selectedReviewUrl = url },
                                            onSelectRelease: { url in selectedReleaseUrl = url },
                                            onSelectUser: { url in selectedUserUrl = url })

                        case .similarArtists:
                            SimilarArtistsView(viewModel: similarArtistsViewModel)

                        case .relatedLinks:
                            BandRelatedLinksView(viewModel: viewModel)
                        }
                    }
                    .frame(minHeight: bottomSectionMinHeight,
                           alignment: .top)
                }
            })
        .toolbar { toolbarContent }
        .sheet(isPresented: $showingShareSheet) {
            if let url = URL(string: band.urlString) {
                ActivityView(items: [url])
            } else {
                ActivityView(items: [band.urlString])
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
        let band = metadata.band
        ToolbarItem(placement: .principal) {
            HStack {
                band.status.color
                    .frame(width: 8, height: 8)
                    .clipShape(Circle())
                Text(band.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .textSelection(.enabled)
                    .minimumScaleFactor(0.5)
            }
            .opacity(titleViewAlpha)
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            HStack {
//                Button(action: {
//                    print("Bookmark band")
//                }, label: {
//                    Image(systemName: "star")
//                })

                Menu(content: {
                    Button(action: {
                        showingShareSheet.toggle()
                    }, label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    })

                    Button(action: {
                        print("Deezer")
                    }, label: {
                        Label("Deezer this band", image: "Deezer")
                    })
                }, label: {
                    Image(systemName: "ellipsis")
                })
            }
        }
    }
}

/*
struct BandView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BandView(apiService: APIService(),
                     bandUrlString: "https://www.metal-archives.com/bands/Death/141")
        }
        .environment(\.colorScheme, .dark)
        .environmentObject(Preferences())
    }
}
*/
