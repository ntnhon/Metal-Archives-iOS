//
//  DeceasedArtistsView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 23/10/2022.
//

import SwiftUI

struct DeceasedArtistsView: View {
    @StateObject private var viewModel: DeceasedArtistsViewModel
    @State private var selectedBandUrlString: String?

    init(apiService: APIServiceProtocol) {
        _viewModel = .init(wrappedValue: .init(apiService: apiService))
    }

    var body: some View {
        let isShowingBand = makeShowingBandDetailBinding()
        ZStack {
            NavigationLink(
                isActive: isShowingBand,
                destination: {
                    if let selectedBandUrlString {
                        BandView(apiService: viewModel.apiService, bandUrlString: selectedBandUrlString)
                    } else {
                        EmptyView()
                    }
                }, label: {
                    EmptyView()
                })

            if let error = viewModel.error {
                VStack {
                    Text(error.userFacingMessage)
                    RetryButton {
                        Task {
                            await viewModel.getMoreArtists(force: true)
                        }
                    }
                }
            } else if viewModel.isLoading && viewModel.artists.isEmpty {
                ProgressView()
            } else if viewModel.artists.isEmpty {
                Text("No artists found")
                    .font(.callout.italic())
            } else {
                artistList
            }
        }
        .task {
            await viewModel.getMoreArtists(force: false)
        }
    }

    @ViewBuilder
    private var artistList: some View {
        List {
            ForEach(viewModel.artists, id: \.artist) { artist in
                NavigationLink(destination: {
                    ArtistView(apiService: viewModel.apiService,
                               urlString: artist.artist.thumbnailInfo.urlString)
                }, label: {
                    DeceasedArtistView(artist: artist)
                        .contextMenu {
                            if !artist.bands.isEmpty {
                                ForEach(artist.bands, id: \.self) { band in
                                    Button(action: {
                                        selectedBandUrlString = band.thumbnailInfo.urlString
                                    }, label: {
                                        Text(band.name)
                                    })
                                }
                            }
                        }
                })
                .task {
                    if artist == viewModel.artists.last {
                        await viewModel.getMoreArtists(force: true)
                    }
                }

                if artist == viewModel.artists.last, viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Deceased artists")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { toolbarContent }
    }

    private func makeShowingBandDetailBinding() -> Binding<Bool> {
        .init(get: {
            selectedBandUrlString != nil
        }, set: { newValue in
            if !newValue {
                selectedBandUrlString = nil
            }
        })
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Menu(content: {
                Button(action: {
                    viewModel.sortOption = .date(.ascending)
                }, label: {
                    view(for: .date(.ascending))
                })

                Button(action: {
                    viewModel.sortOption = .date(.descending)
                }, label: {
                    view(for: .date(.descending))
                })

                Button(action: {
                    viewModel.sortOption = .country(.ascending)
                }, label: {
                    view(for: .country(.ascending))
                })

                Button(action: {
                    viewModel.sortOption = .country(.descending)
                }, label: {
                    view(for: .country(.descending))
                })
            }, label: {
                Text(viewModel.sortOption.title)
            })
            .transaction { transaction in
                transaction.animation = nil
            }
            .opacity(viewModel.artists.isEmpty ? 0 : 1)
            .disabled(viewModel.artists.isEmpty)
        }
    }

    @ViewBuilder
    private func view(for option: DeceasedArtistPageManager.SortOption) -> some View {
        if option == viewModel.sortOption {
            Label(option.title, systemImage: "checkmark")
        } else {
            Text(option.title)
        }
    }
}

private struct DeceasedArtistView: View {
    @EnvironmentObject private var preferences: Preferences
    let artist: DeceasedArtist

    var body: some View {
        HStack {
            ThumbnailView(thumbnailInfo: artist.artist.thumbnailInfo,
                          photoDescription: artist.artist.name)
            .font(.largeTitle)
            .foregroundColor(preferences.theme.secondaryColor)
            .frame(width: 64, height: 64)

            VStack(alignment: .leading) {
                Text(artist.artist.name)
                    .fontWeight(.bold)
                    .foregroundColor(preferences.theme.primaryColor)

                Text(artist.country.nameAndFlag)

                HighlightableText(text: artist.bandsString,
                                  highlights: artist.bands.map { $0.name },
                                  highlightFontWeight: .regular,
                                  highlightColor: preferences.theme.secondaryColor)
                .font(.callout)

                Text(artist.dateOfDeath)
                    .font(.callout)

                Text(artist.causeOfDeath)
                    .font(.callout)
            }

            Spacer()
        }
    }
}
