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

        let titleFont: Font
        let titleForegroundColor: Color
        let subtitleFont: Font
        switch release.type {
        case .demo:
            titleFont = .callout.italic()
            titleForegroundColor = preferences.theme.lighterPrimaryColor
            subtitleFont = .caption
        case .fullLength:
            titleFont = .title3.weight(.bold)
            titleForegroundColor = preferences.theme.darkerPrimaryColor
            subtitleFont = .body.weight(.medium)
        default:
            titleFont = .body
            titleForegroundColor = primaryColor
            subtitleFont = .caption
        }

        return HStack {
            Image(systemName: "opticaldisc")
                .font(.largeTitle)
                .foregroundColor(primaryColor)
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
                }
                .font(subtitleFont)
            }
            .padding(.vertical)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}
