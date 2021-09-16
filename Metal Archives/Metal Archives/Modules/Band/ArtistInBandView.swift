//
//  ArtistInBandView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 07/09/2021.
//

import SwiftUI

struct ArtistInBandView: View {
    @EnvironmentObject private var preferences: Preferences
    let artist: ArtistInBand

    var body: some View {
        HStack(alignment: .top) {
            ThumbnailView(thumbnailInfo: artist.thumbnailInfo)
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
        }
    }
}

struct ArtistInBandView_Previews: PreviewProvider {
    static var previews: some View {
        ArtistInBandView(artist: .chuck)
            .environmentObject(Preferences())
    }
}
