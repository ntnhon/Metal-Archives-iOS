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
    @Environment(\.dismiss) private var dismiss
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
        Group {
            switch viewModel.bandAndDiscographyFetchable {
            case .error(let error):
                VStack(alignment: .center, spacing: 20) {
                    Text(error.userFacingMessage)
                        .frame(maxWidth: .infinity)
                        .font(.caption)

                    RetryButton(onRetry: viewModel.refreshBandAndDiscography)

                    Button(action: dismiss.callAsFunction) {
                        Label("Go back", systemImage: "arrowshape.turn.up.backward")
                    }
                }

            case .fetching, .waiting:
                HornCircularLoader()

            case .fetched(let (band, discography)):
                BandContentView(band: band,
                                apiService: apiService,
                                discography: discography,
                                preferences: preferences)
                .environmentObject(viewModel)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchBandAndDiscography()
        }
    }
}

private struct BandContentView: View {
    @Environment(\.selectedPhoto) private var selectedPhoto
    @StateObject private var reviewsViewModel: BandReviewsViewModel
    @StateObject private var discographyViewModel: DiscographyViewModel
    @StateObject private var similarArtistsViewModel: SimilarArtistsViewModel
    @ObservedObject private var tabsDatasource = BandTabsDatasource()
    @State private var titleViewAlpha = 0.0
    @State private var showingShareSheet = false
    @State private var topSectionSize: CGSize = .zero
    @State private var selectedBandUrl: String?
    @State private var selectedLabelUrl: String?
    let apiService: APIServiceProtocol
    let band: Band
    let discography: Discography

    init(band: Band,
         apiService: APIServiceProtocol,
         discography: Discography,
         preferences: Preferences) {
        self.band = band
        self.apiService = apiService
        self.discography = discography
        self._discographyViewModel = .init(wrappedValue: .init(discography: discography,
                                                               discographyMode: preferences.discographyMode,
                                                               order: preferences.dateOrder))
        self._similarArtistsViewModel = .init(wrappedValue: .init(apiService: apiService, band: band))
        _reviewsViewModel = .init(wrappedValue: .init(band: band,
                                                      apiService: apiService,
                                                      discography: discography))
    }

    var body: some View {
        let isShowingBand = makeIsShowingBandDetailBinding()
        let isShowingLabel = makeIsShowingLabelDetailBinding()

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
                            if let selectedBandUrl = selectedBandUrl {
                                BandView(apiService: apiService, bandUrlString: selectedBandUrl)
                            } else {
                                EmptyView()
                            }
                        }, label: {
                            EmptyView()
                        })

                    NavigationLink(
                        isActive: isShowingLabel,
                        destination: {
                            if let selectedLabelUrl = selectedLabelUrl {
                                LabelView(apiService: apiService, urlString: selectedLabelUrl)
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

                        BandInfoView(viewModel: .init(band: band, discography: discography),
                                     onSelectLabel: { url in selectedLabelUrl = url },
                                     onSelectBand: { url in selectedBandUrl = url })
                        .padding(.horizontal)

                        BandReadMoreView(apiService: apiService, band: band)

                        Color(.systemGray6)
                            .frame(height: 10)
                            .padding(.vertical)
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
                            BandReviewsView(viewModel: reviewsViewModel)

                        case .similarArtists:
                            SimilarArtistsView(viewModel: similarArtistsViewModel)

                        case .relatedLinks:
                            BandRelatedLinksView()
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
