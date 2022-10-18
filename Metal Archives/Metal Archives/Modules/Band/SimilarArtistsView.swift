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
            case .error(let error):
                VStack(alignment: .center, spacing: 20) {
                    Text(error.userFacingMessage)
                        .frame(maxWidth: .infinity)
                        .font(.caption)

                    RetryButton(onRetry: viewModel.retry)
                }

            case .fetching:
                ProgressView()

            case .fetched(let similarArtists):
                ForEach(Array(similarArtists.prefix(20)), id: \.name) {
                    BandSimilarView(apiService: viewModel.apiService, bandSimilar: $0)
                        .padding(.horizontal)
                        .padding(.vertical, 8)

                    Divider()
                }

                if similarArtists.count > 20 {
                    NavigationLink(destination: {
                        AllSimilarArtistsView(apiService: viewModel.apiService,
                                              band: viewModel.band,
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
            await viewModel.fetchSimilarArtists()
        }
    }
}

struct AllSimilarArtistsView: View {
    let apiService: APIServiceProtocol
    let band: Band?
    let similarArtists: [BandSimilar]

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(similarArtists, id: \.name) {
                    BandSimilarView(apiService: apiService, bandSimilar: $0)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                }
            }
        }
        .navigationBarTitle(navigationTitle, displayMode: .large)
    }

    private var navigationTitle: String {
        guard let band  else { return "" }
        return "Similar to \(band.name)"
    }
}
