//
//  ArtistInBandView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 07/09/2021.
//

import SwiftUI

struct ArtistInBandView: View {
    @EnvironmentObject private var preferences: Preferences
    @State private var showingShareSheet = false
    @Binding var selectedBand: BandLite?
    @Binding var selectedArtist: ArtistInBand?
    let artist: ArtistInBand

    var body: some View {
        HStack(alignment: .top) {
            ThumbnailView(thumbnailInfo: artist.thumbnailInfo,
                          photoDescription: artist.name)
            .font(.largeTitle)
            .foregroundColor(preferences.theme.secondaryColor)
            .frame(width: 64)

            VStack(alignment: .leading, spacing: 8) {
                Text(artist.name)
                    .font(.title3.weight(.bold))
                    .foregroundColor(preferences.theme.primaryColor)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(artist.instruments)
                    .font(.body.weight(.medium))
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let seeAlso = artist.seeAlso {
                    HighlightableText(text: seeAlso,
                                      highlights: artist.bands.map { $0.name })
                    .frame(
                        alignment: .leading)
                }
            }
            .overlay {
                Menu(content: {
                    Button(action: {
                        selectedArtist = artist
                    }, label: {
                        Label(artist.name, systemImage: "person.circle")
                    })

                    Divider()

                    ForEach(artist.bands, id: \.thumbnailInfo.id) { band in
                        Button(action: {
                            selectedBand = band
                        }, label: {
                            Text(band.name)
                        })
                    }

                    Divider()

                    Button(action: {
                        showingShareSheet.toggle()
                    }, label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    })
                }, label: {
                    Color.clear
                })
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = URL(string: artist.thumbnailInfo.urlString) {
                ActivityView(items: [url])
            } else {
                ActivityView(items: [artist.thumbnailInfo.urlString])
            }
        }
    }
}
