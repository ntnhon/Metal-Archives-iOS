//
//  BandSimilarView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/07/2021.
//

import SwiftUI

struct BandSimilarView: View {
    @EnvironmentObject private var preferences: Preferences
    let bandSimilar: BandSimilar

    var body: some View {
        NavigationLink(
            destination: BandView(bandUrlString: bandSimilar.thumbnailInfo.urlString)) {
            HStack {
                ThumbnailView(thumbnailInfo: bandSimilar.thumbnailInfo,
                              photoDescription: bandSimilar.name)
                    .font(.largeTitle)
                    .foregroundColor(preferences.theme.secondaryColor)
                    .frame(width: 64, height: 64)

                VStack(alignment: .leading) {
                    Text(bandSimilar.name)
                        .fontWeight(.bold)
                        .foregroundColor(preferences.theme.primaryColor)
                    Text(bandSimilar.country.nameAndFlag)
                        .foregroundColor(preferences.theme.secondaryColor)
                    Text(bandSimilar.genre)
                        .font(.callout)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Text("\(bandSimilar.score)")
                    .fontWeight(.medium)
                    .foregroundColor(Color.byRating(bandSimilar.score))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
    }
}

struct BandSimilarView_Previews: PreviewProvider {
    // swiftlint:disable force_unwrapping
    static var previews: some View {
        BandSimilarView(bandSimilar: .init(thumbnailInfo:
                                            .init(urlString: "https://www.metal-archives.com/bands/Possessed/914",
                                                  type: .bandLogo)!,
                                           name: "Possessed",
                                           country: .init(isoCode: "US", flag: "🇺🇸", name: "United States"),
                                           genre: "Death/Thrash Metal",
                                           score: 291))
            .environmentObject(Preferences())
    }
}
