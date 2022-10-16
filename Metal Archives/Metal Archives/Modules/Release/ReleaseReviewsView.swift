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
        let isShowingConfirmationDialog = makeIsShowingConfirmationDialogBinding()
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
        .confirmationDialog(
            "",
            isPresented: isShowingConfirmationDialog,
            actions: {
                if let selectedReview = selectedReview {
                    Button("💬 Read review") {
                        onSelectReview(selectedReview.urlString)
                    }

                    Button("View \(selectedReview.author.name)'s profile") {
                        onSelectUser(selectedReview.author.urlString)
                    }
                }
            },
            message: {
                Text("\"\(selectedReview?.title ?? "")\" review by \(selectedReview?.author.name ?? "")")
            })
    }

    private func makeIsShowingConfirmationDialogBinding() -> Binding<Bool> {
        .init(get: {
            selectedReview != nil
        }, set: { newValue in
            if !newValue {
                selectedReview = nil
            }
        })
    }
}
