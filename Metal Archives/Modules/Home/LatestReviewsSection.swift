//
//  LatestReviewsSection.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 04/12/2022.
//

import SnapToScroll
import SwiftUI

typealias LatestReviewsSectionViewModel = HomeSectionViewModel<LatestReview>

struct LatestReviewsSection: View {
    @StateObject private var viewModel: LatestReviewsSectionViewModel
    @Binding var detail: Detail?

    init(detail: Binding<Detail?>) {
        _viewModel = .init(wrappedValue: .init(manager: LatestReviewPageManager()))
        _detail = detail
    }

    var body: some View {
        ZStack {
            if let error = viewModel.error {
                VStack {
                    Text(error.userFacingMessage)
                    RetryButton(onRetry: viewModel.refresh)
                }
            } else {
                VStack(spacing: 0) {
                    HStack {
                        Text("Latest reviews")
                            .font(.title2)
                            .fontWeight(.bold)

                        Spacer()

//                        if !viewModel.isLoading && !viewModel.results.isEmpty {
//                            Button(action: {
//                                print("See All")
//                            }, label: {
//                                Text("See all")
//                            })
//                        }
                    }
                    .padding(.horizontal)

                    if viewModel.isLoading && viewModel.results.isEmpty {
                        HomeSectionSkeletonView()
                    } else if viewModel.results.isEmpty {
                        Text("No latest reviews")
                            .font(.callout.italic())
                    } else {
                        resultList
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .task {
            await viewModel.getMoreResults(force: false)
        }
    }

    private var resultList: some View {
        HStackSnap(alignment: .leading(24)) {
            ForEach(viewModel.chunkedResults, id: \.hashValue) { latestReviews in
                VStack(spacing: HomeSettings.entrySpacing) {
                    ForEach(latestReviews) { review in
                        LatestReviewView(detail: $detail, review: review)
                    }
                }
                .snapAlignmentHelper(id: latestReviews.hashValue)
            }
        }
        .frame(height: HomeSettings.pageHeight)
    }
}

private struct LatestReviewView: View {
    @EnvironmentObject private var preferences: Preferences
    @State private var isShowingConfirmationDialog = false
    @Binding var detail: Detail?
    let review: LatestReview

    var body: some View {
        HStack {
            ThumbnailView(thumbnailInfo: review.release.thumbnailInfo,
                          photoDescription: review.release.title)
                .font(.largeTitle)
                .foregroundColor(preferences.theme.secondaryColor)
                .frame(width: 64, height: 64)

            VStack(alignment: .leading) {
                let texts = review.bands
                    .generateTexts(fontWeight: .bold,
                                   foregroundColor: preferences.theme.primaryColor)
                texts.reduce(into: Text("")) { partialResult, text in
                    // swiftlint:disable:next shorthand_operator
                    partialResult = partialResult + text
                }
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(2)
                .minimumScaleFactor(0.5)

                Text(review.release.title)
                    .fontWeight(.semibold)
                    .foregroundColor(preferences.theme.secondaryColor)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)

                Text(review.author.name)
                    .font(.body.italic())
                    .foregroundColor(preferences.theme.secondaryColor) +
                    Text(" • ") +
                    Text("\(review.rating)%")
                    .foregroundColor(.byRating(review.rating))

                Text("\(review.date), \(review.time)")

                Divider()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: HomeSettings.entryWidth)
        .contentShape(Rectangle())
        .onTapGesture { isShowingConfirmationDialog.toggle() }
        .confirmationDialog(
            "Review",
            isPresented: $isShowingConfirmationDialog,
            actions: {
                Button(action: {
                    detail = .review(review.urlString)
                }, label: {
                    Text("Read review by \(review.author.name) - \(review.rating)%")
                })

                Button(action: {
                    detail = .release(review.release.thumbnailInfo.urlString)
                }, label: {
                    Text("View release's detail")
                })

                ForEach(review.bands) { band in
                    Button(action: {
                        detail = .band(band.thumbnailInfo.urlString)
                    }, label: {
                        if review.bands.count == 1 {
                            Text("View band's detail")
                        } else {
                            Text(band.name)
                        }
                    })
                }

                Button(action: {
                    detail = .user(review.author.urlString)
                }, label: {
                    Text("View \(review.author.name)'s detail")
                })
            },
            message: {
                Text("\"\(review.release.title)\" by \(review.bandsName)")
            }
        )
    }
}
