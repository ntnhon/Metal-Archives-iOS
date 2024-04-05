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

                case let .fetched(biography):
                    if let biography {
                        Text(biography)
                    }

                case let .error(error):
                    VStack {
                        Text(error.userFacingMessage)
                        RetryButton {
                            await viewModel.fetchBiography(forceRefresh: true)
                        }
                    }
                }
            } else if let biography = artist.biography {
                Text(biography)
            }
        }
        .task {
            await viewModel.fetchBiography(forceRefresh: false)
        }
    }
}
