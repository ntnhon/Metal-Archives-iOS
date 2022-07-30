//
//  ReleaseInBandView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 09/07/2021.
//

import SwiftUI

struct ReleaseInBandView: View {
    @EnvironmentObject private var preferences: Preferences
    let release: ReleaseInBand

    var body: some View {
        let primaryColor = preferences.theme.primaryColor
        let secondaryColor = preferences.theme.secondaryColor

        let titleFont: Font
        let titleForegroundColor: Color
        let subtitleFont: Font
        switch release.type {
        case .demo:
            titleFont = .callout.italic()
            titleForegroundColor = secondaryColor
            subtitleFont = .caption
        case .fullLength:
            titleFont = .title3.weight(.bold)
            titleForegroundColor = primaryColor
            subtitleFont = .body.weight(.medium)
        default:
            titleFont = .body
            titleForegroundColor = secondaryColor
            subtitleFont = .caption
        }

        return HStack {
            ThumbnailView(thumbnailInfo: release.thumbnailInfo,
                          photoDescription: release.photoDescription)
                .font(.largeTitle)
                .foregroundColor(secondaryColor)
                .frame(width: 64, height: 64)

            VStack(alignment: .leading) {
                Text(release.title)
                    .font(titleFont)
                    .foregroundColor(titleForegroundColor)
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
                .font(subtitleFont)
            }
            .padding(.vertical)

            Spacer()
        }
        .contentShape(Rectangle())
    }
}
