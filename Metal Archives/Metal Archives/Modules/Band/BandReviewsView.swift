//
//  BandReviewsView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 26/07/2021.
//

import SwiftUI

struct BandReviewsView: View {
    @StateObject private var viewModel: BandReviewsViewModel

    init(viewModel: BandReviewsViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }

    var body: some View {
        LazyVStack {
            if let error = viewModel.error {
                Text(error.userFacingMessage)
                RetryButton {
                    Task {
                        await viewModel.getMoreReviews()
                    }
                }
            } else {
                reviewList
            }
        }
        .task {
            await viewModel.getMoreReviews()
        }
    }

    @ViewBuilder
    private var reviewList: some View {
        ForEach(viewModel.reviews, id: \.urlString) { review in
            ReviewLiteView(review: review,
                           release: viewModel.release(for: review))
            .task {
                if review.urlString == viewModel.reviews.last?.urlString {
                    await viewModel.getMoreReviews()
                }
            }
            Divider()
        }

        if viewModel.isLoading {
            ProgressView()
        } else if viewModel.reviews.isEmpty {
            Text("No reviews yet")
                .font(.callout.italic())
        }
    }
}

private struct ReviewLiteView: View {
    @EnvironmentObject private var preferences: Preferences
    let review: ReviewLite
    let release: ReleaseInBand

    var body: some View {
        HStack {
            ThumbnailView(thumbnailInfo: release.thumbnailInfo,
                          photoDescription: release.photoDescription)
            .font(.largeTitle)
            .foregroundColor(preferences.theme.secondaryColor)
            .frame(width: 64, height: 64)

            VStack(alignment: .leading) {
                Text(release.title)
                    .font(release.type.titleFont)
                    .foregroundColor(release.type.titleForegroundColor(preferences.theme))
                    .fixedSize(horizontal: false, vertical: true)

                Group {
                    Text(verbatim: "\(release.year) • ") +
                    Text("\(release.type.description) • ") +
                    Text("\(review.rating)%")
                        .foregroundColor(Color.byRating(review.rating))
                }
                .font(release.type.subtitleFont)

                Group {
                    Text("\(review.author.name) • ")
                        .foregroundColor(preferences.theme.secondaryColor) +
                    Text(review.date)
                }
                .font(.callout)
            }
            .padding(.vertical)

            Spacer()
        }
        .contentShape(Rectangle())
    }
}
