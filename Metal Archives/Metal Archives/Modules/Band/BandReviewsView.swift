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
        if !viewModel.reviews.isEmpty {
            HStack {
                Text("\(viewModel.reviewCount) review\(viewModel.reviewCount > 1 ? "s" : "")")
                Spacer()
                ReviewOrderPicker(viewModel: viewModel)
            }
        }

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

private struct ReviewOrderPicker: View {
    @EnvironmentObject private var preferences: Preferences
    @ObservedObject var viewModel: BandReviewsViewModel

    var body: some View {
        Menu(content: {
            Section {
                Button(action: {
                    viewModel.albumOrder = nil
                }, label: {
                    Label("Album ↑↓",
                          systemImage: viewModel.albumOrder == nil ? "checkmark" : "")
                })

                Button(action: {
                    viewModel.albumOrder = .ascending
                }, label: {
                    Label("Album ↑",
                          systemImage: viewModel.albumOrder == .ascending ? "checkmark" : "")
                })

                Button(action: {
                    viewModel.albumOrder = .descending
                }, label: {
                    Label("Album ↓",
                          systemImage: viewModel.albumOrder == .descending ? "checkmark" : "")
                })
            }

            Section {
                Button(action: {
                    viewModel.ratingOrder = nil
                }, label: {
                    Label("Rating ↑↓",
                          systemImage: viewModel.ratingOrder == nil ? "checkmark" : "")
                })

                Button(action: {
                    viewModel.ratingOrder = .ascending
                }, label: {
                    Label("Rating ↑",
                          systemImage: viewModel.ratingOrder == .ascending ? "checkmark" : "")
                })

                Button(action: {
                    viewModel.ratingOrder = .descending
                }, label: {
                    Label("Rating ↓",
                          systemImage: viewModel.ratingOrder == .descending ? "checkmark" : "")
                })
            }

            Section {
                Button(action: {
                    viewModel.authorOrder = nil
                }, label: {
                    Label("Author ↑↓",
                          systemImage: viewModel.authorOrder == nil ? "checkmark" : "")
                })

                Button(action: {
                    viewModel.authorOrder = .ascending
                }, label: {
                    Label("Author ↑",
                          systemImage: viewModel.authorOrder == .ascending ? "checkmark" : "")
                })

                Button(action: {
                    viewModel.authorOrder = .descending
                }, label: {
                    Label("Author ↓",
                          systemImage: viewModel.authorOrder == .descending ? "checkmark" : "")
                })
            }

            Section {
                Button(action: {
                    viewModel.dateOrder = nil
                }, label: {
                    Label("Date ↑↓",
                          systemImage: viewModel.dateOrder == nil ? "checkmark" : "")
                })

                Button(action: {
                    viewModel.dateOrder = .ascending
                }, label: {
                    Label("Date ↑",
                          systemImage: viewModel.dateOrder == .ascending ? "checkmark" : "")
                })

                Button(action: {
                    viewModel.dateOrder = .descending
                }, label: {
                    Label("Date ↓",
                          systemImage: viewModel.dateOrder == .descending ? "checkmark" : "")
                })
            }
        }, label: {
            HStack {
                Text("Order")
                Image(systemName: "arrow.up.arrow.down")
            }
            .padding(8)
            .background(preferences.theme.primaryColor)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        })
        .transaction { transaction in
            transaction.animation = nil
        }
    }
}
