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

    init(bandUrlString: String) {
        let viewModel = BandViewModel(bandUrlString: bandUrlString)
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            switch viewModel.bandAndDiscographyFetchable {
            case .error(let error):
                VStack(alignment: .center, spacing: 20) {
                    Text(error.description)
                        .frame(maxWidth: .infinity)
                        .font(.caption)

                    Button(action: {
                        viewModel.refreshBandAndDiscography()
                    }, label: {
                        Label("Retry", systemImage: "arrow.clockwise")
                    })

                    Button(action: dismiss.callAsFunction) {
                        Label("Go back", systemImage: "arrowshape.turn.up.backward")
                    }
                }

            case .fetching, .waiting:
                ProgressView()

            case .fetched(let (band, discography)):
                BandContentView(band: band, discography: discography)
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
    @State private var selectedSection: BandSection = .discography
    @State private var titleViewAlpha = 0.0
    let band: Band
    let discography: Discography

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
                    BandHeaderView(band: band) { selectedImage in
                        selectedPhoto.wrappedValue = .init(image: selectedImage,
                                                           description: band.name)
                    }

                    BandInfoView(viewModel: .init(band: band, discography: discography),
                                 onSelectLabel: { _ in },
                                 onSelectBand: { _ in })
                    .padding(.horizontal)

                    BandReadMoreView()

                    Color(.systemGray6)
                        .frame(height: 10)
                        .padding(.vertical)

                    BandSectionView(selectedSection: $selectedSection)
                        .padding(.bottom)

                    switch selectedSection {
                    case .discography:
                        DiscographyView(discography: discography,
                                        releaseYearOrder: preferences.dateOrder)
                        .padding(.horizontal)

                    case .members:
                        BandLineUpView(band: band)
                            .padding(.horizontal)

                    case .reviews:
                        BandReviewsView()

                    case .similarArtists:
                        SimilarArtistsView()

                    case .relatedLinks:
                        BandRelatedLinksView()
                    }
                }
            })
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(band.name)
                    .font(.title2)
                    .fontWeight(.medium)
                    .opacity(titleViewAlpha)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button(action: {

                    }, label: {
                        Image(systemName: "star")
                    })

                    Menu(content: {
                        if #available(iOS 16, *) {
                            Button(action: {
                                // TODO: Use ShareLink
                            }, label: {
                                Label("Share", systemImage: "square.and.arrow.up")
                            })
                        } else {
                            Button(action: {
                                UIPasteboard.general.string = band.urlString
                            }, label: {
                                Label("Copy link", systemImage: "link")
                            })
                        }

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
}

struct BandView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BandView(bandUrlString: "https://www.metal-archives.com/bands/Death/141")
        }
        .environment(\.colorScheme, .dark)
        .environmentObject(Preferences())
    }
}
