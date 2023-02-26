//
//  ArtistBiographyView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 02/11/2022.
//

import SwiftUI

struct ArtistBiographyView: View {
    @ObservedObject var viewModel: ArtistViewModel
    let artist: Artist

    var body: some View {
        ZStack {
            if artist.hasMoreBiography {
                switch viewModel.biographyFetchable {
                case .fetching:
                    ProgressView()

                case .fetched(let biography):
                    if let biography = biography {
                        Text(biography)
                    }

                case .error(let error):
                    VStack {
                        Text(error.userFacingMessage)
                        RetryButton {
                            Task {
                                await viewModel.fetchBiography(forceRefresh: true)
                            }
                        }
                    }
                }
            } else if let biography = artist.biography {
                Text(biography)
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchBiography(forceRefresh: false)
            }
        }
    }
}
