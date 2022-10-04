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
            }
        }
        .task {
            await viewModel.getMoreReviews()
        }
    }
}
