//
//  SimilarArtistsView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 26/07/2021.
//

import SwiftUI

struct SimilarArtistsView: View {
    @EnvironmentObject private var viewModel: BandViewModel

    var body: some View {
        Group {
            switch viewModel.similarArtistsFetchable {
            case .error(let error):
                VStack(alignment: .center, spacing: 20) {
                    Text(error.description)
                        .frame(maxWidth: .infinity)
                        .font(.caption)

                    Button(action: {
                        viewModel.refreshSimilarArtists()
                    }, label: {
                        Label("Retry", systemImage: "arrow.clockwise")
                    })
                }

            case .fetching, .waiting:
                ProgressView()

            case .fetched(let similarArtists):
                ForEach(Array(similarArtists.prefix(20)), id: \.name) {
                    BandSimilarView(bandSimilar: $0)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                }

                if similarArtists.count > 20 {
                    NavigationLink(
                        destination: AllSimilarArtistsView(band: viewModel.band, similarArtists: similarArtists)) {
                        seeAll(similarArtists: similarArtists)
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchSimilarArtists()
        }
    }

    private func seeAll(similarArtists: [BandSimilar]) -> some View {
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
    }
}

struct SimilarArtistsView_Previews: PreviewProvider {
    static var previews: some View {
        SimilarArtistsView()
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
        guard let band = band else {
            return ""
        }
        return "Similar to \(band.name)"
    }
}
