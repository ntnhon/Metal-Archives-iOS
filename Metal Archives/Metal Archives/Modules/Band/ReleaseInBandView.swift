//
//  ReleaseInBandView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 09/07/2021.
//

import SwiftUI

struct ReleaseInBandView: View {
    @EnvironmentObject private var preferences: Preferences
    @EnvironmentObject private var cache: MAImageCache
    let release: ReleaseInBand

    var body: some View {
        HStack {
            ThumbnailView(thumbnailInfo: release.thumbnailInfo,
                          photoDescription: release.photoDescription,
                          cache: cache)
            .font(.largeTitle)
            .foregroundColor(preferences.theme.secondaryColor)
            .frame(width: 64, height: 64)

            VStack(alignment: .leading) {
                Text(release.title)
                    .font(release.type.titleFont)
                    .foregroundColor(release.type.titleForegroundColor(preferences.theme))
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 0) {
                    Text(verbatim: "\(release.year) • ")
                    Text(release.type.description)
                    if let rating = release.rating,
                       let reviewCount = release.reviewCount {
                        Text(" • ")
                        Text("\(reviewCount) (\(rating)%)")
                            .foregroundColor(Color.byRating(rating))
                    }
                    if release.isPlatinium {
                        Text(" 🏅")
                    }
                }
                .font(release.type.subtitleFont)
            }
            .padding(.vertical)

            Spacer()
        }
        .contentShape(Rectangle())
    }
}
