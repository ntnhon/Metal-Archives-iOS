//
//  ArtistTriviaView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 04/04/2024.
//

import SwiftUI

struct ArtistTriviaView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var preferences: Preferences
    @StateObject private var viewModel: ArtistTriviaViewModel
    let artist: Artist

    init(artist: Artist, urlString: String) {
        _viewModel = .init(wrappedValue: .init(urlString: urlString))
        self.artist = artist
    }

    var body: some View {
        NavigationView {
            ZStack {
                switch viewModel.state {
                case .loading:
                    MALoadingIndicator()
                case let .loaded(trivia):
                    ScrollView {
                        Text(trivia)
                            .padding()
                    }
                case let .error(error):
                    VStack {
                        Text(error.userFacingMessage)
                        RetryButton {
                            await viewModel.loadTrivia()
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: dismiss.callAsFunction) {
                        Image(systemName: "xmark")
                    }
                }
            }
            .if(viewModel.state.isLoaded) { view in
                view
                    .navigationTitle("\(artist.artistName)'s trivia")
            }
        }
        .navigationViewStyle(.stack)
        .animation(.default, value: viewModel.state)
        .accentColor(preferences.theme.primaryColor)
        .task {
            await viewModel.loadTrivia()
        }
    }
}
