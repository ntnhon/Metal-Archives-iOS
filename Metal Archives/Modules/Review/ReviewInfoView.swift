//
//  ReviewInfoView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 06/11/2022.
//

import SwiftUI

struct ReviewInfoView: View {
    @EnvironmentObject private var preferences: Preferences
    let review: Review
    let onSelectUser: (String) -> Void
    let onSelectBand: (String) -> Void
    let onSelectRelease: (String) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Text(review.title)
                .font(.title)
                .fontWeight(.bold)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .padding(.bottom)
                .background(GradientBackgroundView())

            VStack(alignment: .leading, spacing: 10) {
                ColorCustomizableLabel(title: review.band.name,
                                       systemImage: "person.3.fill",
                                       titleColor: preferences.theme.primaryColor)
                .onTapGesture {
                    onSelectBand(review.band.thumbnailInfo.urlString)
                }

                ColorCustomizableLabel(title: review.release.title,
                                       systemImage: "opticaldisc.fill",
                                       titleColor: preferences.theme.primaryColor)
                .onTapGesture {
                    onSelectRelease(review.release.thumbnailInfo.urlString)
                }

                ColorCustomizableLabel(title: "\(review.rating)%",
                                       systemImage: "quote.bubble.fill",
                                       titleColor: .byRating(review.rating))

                ColorCustomizableLabel(title: review.user.name,
                                       systemImage: "person.fill",
                                       titleColor: preferences.theme.primaryColor)
                .onTapGesture {
                    onSelectUser(review.user.urlString)
                }

                ColorCustomizableLabel(title: review.date, systemImage: "calendar")

                if let baseVersion = review.baseVersion {
                    ColorCustomizableLabel(title: baseVersion.title,
                                           systemImage: "info.circle.fill",
                                           titleColor: preferences.theme.primaryColor)
                    .onTapGesture {
                        onSelectRelease(baseVersion.thumbnailInfo.urlString)
                    }
                }

                Text(review.content)
            }
            .padding([.horizontal, .bottom])
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
        }
    }
}
