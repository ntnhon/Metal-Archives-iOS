//
//  ReleaseReviewsView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 11/10/2022.
//

import SwiftUI

struct ReleaseReviewsView: View {
    @EnvironmentObject private var preferences: Preferences
    let reviews: [ReviewLite]

    var body: some View {
        VStack {
            ForEach(reviews, id: \.urlString) { review in
                VStack(alignment: .leading) {
                    Text(review.title)
                        .foregroundColor(preferences.theme.primaryColor)

                    Group {
                        Text("\(review.rating)%")
                            .foregroundColor(.byRating(review.rating)) +
                        Text(" • ") +
                        Text(review.author.name)
                            .foregroundColor(preferences.theme.secondaryColor) +
                        Text(" • ") +
                        Text(review.date)
                    }
                    .font(.callout)

                    Divider()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal)
    }
}
