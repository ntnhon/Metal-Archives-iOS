//
//  BandView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 26/06/2021.
//

import Kingfisher
import SwiftUI

struct BandView: View {
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
                                discography: discography)
                .environmentObject(viewModel)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.fetchBandAndDiscography()
        }
    }
}

private struct BandContentView: View {
    @EnvironmentObject private var preferences: Preferences
    @Environment(\.selectedPhoto) private var selectedPhoto
    @StateObject private var reviewsViewModel: BandReviewsViewModel
    @State private var selectedSection: BandSection = .discography
    @State private var titleViewAlpha = 0.0
    @State private var showingShareSheet = false
    @State private var topSectionSize: CGSize = .zero
    let apiService: APIServiceProtocol
    let band: Band
    let discography: Discography

    init(band: Band, apiService: APIServiceProtocol, discography: Discography) {
        self.band = band
        self.apiService = apiService
        self.discography = discography
        _reviewsViewModel = .init(wrappedValue: .init(band: band,
                                                      apiService: apiService,
                                                      discography: discography))
    }

    var body: some View {
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
                    VStack {
                        BandHeaderView(band: band) { selectedImage in
                            let photo = Photo(image: selectedImage,
                                              description: band.name)
                            selectedPhoto.wrappedValue = photo
                        }

                        BandInfoView(viewModel: .init(band: band, discography: discography),
                                     onSelectLabel: { _ in },
                                     onSelectBand: { _ in })
                        .padding(.horizontal)

                        BandReadMoreView()

                        Color(.systemGray6)
                            .frame(height: 10)
                            .padding(.vertical)
                    }
                    .modifier(SizeModifier())
                    .onPreferenceChange(SizePreferenceKey.self) {
                        topSectionSize = $0
                    }

                    BandSectionView(selectedSection: $selectedSection)
                        .padding(.bottom)

                    let screenBounds = UIScreen.main.bounds
                    let maxSize = max(screenBounds.height, screenBounds.width)
                    let bottomSectionMinHeight = maxSize - topSectionSize.height - 250 // 🪄✨
                    Group {
                        switch selectedSection {
                        case .discography:
                            DiscographyView(apiService: apiService,
                                            discography: discography)
                            .padding(.horizontal)

                        case .members:
                            BandLineUpView(apiService: apiService, band: band)
                                .padding(.horizontal)

                        case .reviews:
                            BandReviewsView(viewModel: reviewsViewModel)

                        case .similarArtists:
                            SimilarArtistsView(apiService: apiService)

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
