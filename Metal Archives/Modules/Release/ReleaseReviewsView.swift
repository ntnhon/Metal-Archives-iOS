//
//  ReleaseReviewsView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 11/10/2022.
//

import SwiftUI

struct ReleaseReviewsView: View {
    @EnvironmentObject private var preferences: Preferences
    @State private var selectedReview: ReviewLite?
    let reviews: [ReviewLite]
    let onSelectReview: (String) -> Void
    let onSelectUser: (String) -> Void

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
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedReview = review
                }
            }
        }
        .padding(.horizontal)
        .alert("Reviewed by \(selectedReview?.author.name ?? "")",
               isPresented: $selectedReview.mappedToBool(),
               presenting: selectedReview,
               actions: { review in
                   Button("Read review") {
                       onSelectReview(review.urlString)
                   }

                   Button("View \(review.author.name)'s profile") {
                       onSelectUser(review.author.urlString)
                   }

                   Button("Cancel", role: .cancel, action: {})
               },
               message: { review in
                   Text(review.title)
               })
    }
}
