//
//  SimilarArtistsView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 26/07/2021.
//

import SwiftUI

struct SimilarArtistsView: View {
    @ObservedObject var viewModel: SimilarArtistsViewModel

    var body: some View {
        LazyVStack {
            switch viewModel.similarArtistsFetchable {
            case let .error(error):
                VStack(alignment: .center, spacing: 20) {
                    Text(error.userFacingMessage)
                        .frame(maxWidth: .infinity)
                        .font(.caption)

                    RetryButton {
                        await viewModel.refresh(force: true)
                    }
                }

            case .fetching:
                ProgressView()

            case let .fetched(similarArtists):
                ForEach(Array(similarArtists.prefix(20)), id: \.name) {
                    BandSimilarView(bandSimilar: $0)
                        .padding(.horizontal)
                        .padding(.vertical, 8)

                    Divider()
                }

                if similarArtists.count > 20 {
                    NavigationLink(destination: {
                        AllSimilarArtistsView(band: viewModel.band,
                                              similarArtists: similarArtists)
                    }, label: {
                        HStack {
                            Spacer()
                            Text("See all \(similarArtists.count) similar artists")
                                .font(.callout)
                                .padding(.horizontal)
                                .padding(.vertical, 6)
                                .overlay(Capsule()
                                    .stroke(Color.secondary, lineWidth: 1.0))
                            Spacer()
                        }
                        .padding()
                        .foregroundColor(.primary)
                    })
                }

                if similarArtists.isEmpty {
                    Text("No similar artists yet")
                        .font(.callout.italic())
                }
            }
        }
        .task {
            await viewModel.refresh(force: false)
        }
    }
}

struct AllSimilarArtistsView: View {
    let band: Band?
    let similarArtists: [BandSimilar]

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(similarArtists, id: \.name) {
                    BandSimilarView(bandSimilar: $0)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                }
            }
        }
        .navigationBarTitle(navigationTitle, displayMode: .large)
    }

    private var navigationTitle: String {
        guard let band else { return "" }
        return "Similar to \(band.name)"
    }
}
