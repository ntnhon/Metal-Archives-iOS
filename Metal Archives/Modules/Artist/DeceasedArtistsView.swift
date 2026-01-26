//
//  DeceasedArtistsView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 23/10/2022.
//

import SwiftUI

struct DeceasedArtistsView: View {
    @StateObject private var viewModel = DeceasedArtistsViewModel()
    @State private var selectedArtist: DeceasedArtist?
    @Binding var path: NavigationPath

    var body: some View {
        ZStack {
            if let error = viewModel.error {
                VStack {
                    Text(error.userFacingMessage)
                    RetryButton {
                        await viewModel.getMoreArtists(force: true)
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
}

private extension DeceasedArtistsView {
    var artistList: some View {
        List {
            ForEach(viewModel.artists, id: \.artist) { artist in
                DeceasedArtistView(artist: artist)
                    .contentShape(Rectangle())
                    .onTapGesture { selectedArtist = artist }
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
        .alert("R.I.P",
               isPresented: $selectedArtist.mappedToBool(),
               presenting: selectedArtist,
               actions: { artist in
                   Button(action: {
                       path.append(Detail.artist(artist.artist.thumbnailInfo.urlString))
                   }, label: {
                       Text("View artist's detail")
                   })

                   ForEach(artist.bands) { band in
                       Button(action: {
                           path.append(Detail.band(band.thumbnailInfo.urlString))
                       }, label: {
                           Text(band.name)
                       })
                   }

                   Button("Cancel", role: .cancel, action: {})
               },
               message: { artist in
                   Text(artist.artist.name)
               })
    }

    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
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
    func view(for option: DeceasedArtistPageManager.SortOption) -> some View {
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
                                  highlights: artist.bands.map(\.name),
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
