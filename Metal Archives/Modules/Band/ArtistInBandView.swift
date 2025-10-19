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
    let artist: ArtistInBand
    let onSelectBand: (String) -> Void
    let onSelectArtist: (String) -> Void

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
                    .onTapGesture { onSelectArtist(artist.thumbnailInfo.urlString) }

                Text(artist.instruments)
                    .font(.body.weight(.medium))
                    .onTapGesture { onSelectArtist(artist.thumbnailInfo.urlString) }

                if let seeAlso = artist.seeAlso {
                    HighlightableText(text: seeAlso,
                                      highlights: artist.bands.map(\.name),
                                      highlightFontWeight: .regular,
                                      highlightColor: preferences.theme.primaryColor)
                        .frame(alignment: .leading)
                        .overlay {
                            Menu(content: {
                                ForEach(artist.bands, id: \.thumbnailInfo.id) { band in
                                    Button(action: {
                                        onSelectBand(band.thumbnailInfo.urlString)
                                    }, label: {
                                        Text(band.name)
                                    })
                                }
                            }, label: {
                                Color.clear
                            })
                        }
                }
            }
            Spacer()
        }
        .contentShape(Rectangle())
        .contextMenu {
            Button(action: {
                onSelectArtist(artist.thumbnailInfo.urlString)
            }, label: {
                Label("View artist detail", systemImage: "person")
            })

            Button(action: {
                showingShareSheet.toggle()
            }, label: {
                Label("Share", systemImage: "square.and.arrow.up")
            })
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
