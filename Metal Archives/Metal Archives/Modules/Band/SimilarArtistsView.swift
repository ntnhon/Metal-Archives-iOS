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
                }

                if similarArtists.count > 20 {
                    NavigationLink(
                        destination: AllSimilarArtistsView(similarArtists: similarArtists)) {
                        HStack {
                            Text("View all similar artists")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchSimilarArtists()
        }
    }
}

struct SimilarArtistsView_Previews: PreviewProvider {
    static var previews: some View {
        SimilarArtistsView()
    }
}

struct AllSimilarArtistsView: View {
    let similarArtists: [BandSimilar]

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(similarArtists, id: \.name) {
                    BandSimilarView(bandSimilar: $0)
                }
            }
        }
    }
}
