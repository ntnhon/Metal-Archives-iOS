//
//  UserReviewsView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 07/11/2022.
//

import SwiftUI

struct UserReviewsView: View {
    @EnvironmentObject private var preferences: Preferences
    @ObservedObject var viewModel: UserReviewsViewModel
    @State private var selectedReview: UserReview?
    let onSelectReview: (String) -> Void
    let onSelectBand: (String) -> Void
    let onSelectRelease: (String) -> Void

    var body: some View {
        let isShowingAlert = Binding<Bool>(get: {
            selectedReview != nil
        }, set: { newValue in
            if !newValue {
                selectedReview = nil
            }
        })
        ZStack {
            if let error = viewModel.error {
                VStack {
                    Text(error.userFacingMessage)
                    RetryButton(onRetry: viewModel.refresh)
                }
            } else if viewModel.manager.isLoading, viewModel.reviews.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else if viewModel.reviews.isEmpty {
                Text("No reviews")
                    .font(.callout.italic())
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                reviewList
            }
        }
        .task {
            await viewModel.getMoreReviews(force: false)
        }
        .confirmationDialog(
            "",
            isPresented:
                isShowingAlert,
            actions: {
                if let selectedReview {
                    Button(action: {
                        onSelectReview(selectedReview.urlString)
                    }, label: {
                        Text("Read review")
                    })

                    Button(action: {
                        onSelectRelease(selectedReview.release.thumbnailInfo.urlString)
                    }, label: {
                        Text("View release's detail")
                    })

                    Button(action: {
                        onSelectBand(selectedReview.band.thumbnailInfo.urlString)
                    }, label: {
                        Text("View band's detail")
                    })
                }
            },
            message: {
                if let selectedReview {
                    Text("\(selectedReview.title)\n") +
                    Text("\"\(selectedReview.release.title)\" by \(selectedReview.band.name)")
                }
            })
    }

    @ViewBuilder
    private var reviewList: some View {
        LazyVStack {
            HStack {
                let entryCount = viewModel.manager.total
                if entryCount == 1 {
                    Text("1 review")
                } else {
                    Text("\(viewModel.manager.total) total reviews")
                }
                Spacer()
                sortOptions
            }
            ForEach(viewModel.reviews, id: \.hashValue) { review in
                UserReviewView(review: review)
                    .onTapGesture {
                        selectedReview = review
                    }
                    .task {
                        if review == viewModel.reviews.last {
                            await viewModel.getMoreReviews(force: true)
                        }
                    }

                Divider()

                if review == viewModel.reviews.last, viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .listStyle(.plain)
    }

    private var sortOptions: some View {
        Menu(content: {
            Button(action: {
                viewModel.sortOption = .date(.ascending)
            }, label: {
                view(for: .date(.ascending))
            })

            Button(action: {
                viewModel.sortOption = .date(.descending)
            }, label: {
                view(for: .date(.descending))
            })

            Button(action: {
                viewModel.sortOption = .band(.ascending)
            }, label: {
                view(for: .band(.ascending))
            })

            Button(action: {
                viewModel.sortOption = .band(.descending)
            }, label: {
                view(for: .band(.descending))
            })

            Button(action: {
                viewModel.sortOption = .release(.ascending)
            }, label: {
                view(for: .release(.ascending))
            })

            Button(action: {
                viewModel.sortOption = .release(.descending)
            }, label: {
                view(for: .release(.descending))
            })

            Button(action: {
                viewModel.sortOption = .title(.ascending)
            }, label: {
                view(for: .title(.ascending))
            })

            Button(action: {
                viewModel.sortOption = .title(.descending)
            }, label: {
                view(for: .title(.descending))
            })

            Button(action: {
                viewModel.sortOption = .rating(.ascending)
            }, label: {
                view(for: .rating(.ascending))
            })

            Button(action: {
                viewModel.sortOption = .rating(.descending)
            }, label: {
                view(for: .rating(.descending))
            })
        }, label: {
            Text(viewModel.sortOption.title)
                .padding(8)
                .background(preferences.theme.primaryColor)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        })
        .transaction { transaction in
            transaction.animation = nil
        }
        .opacity(viewModel.reviews.isEmpty ? 0 : 1)
        .disabled(viewModel.reviews.isEmpty)
    }

    @ViewBuilder
    private func view(for option: UserReviewPageManager.SortOption) -> some View {
        if option == viewModel.sortOption {
            Label(option.title, systemImage: "checkmark")
        } else {
            Text(option.title)
        }
    }
}

private struct UserReviewView: View {
    @EnvironmentObject private var preferences: Preferences
    let review: UserReview

    var body: some View {
        HStack {
            ThumbnailView(thumbnailInfo: review.release.thumbnailInfo, photoDescription: review.release.title)
                .font(.largeTitle)
                .foregroundColor(preferences.theme.secondaryColor)
                .frame(width: 64, height: 64)

            VStack(alignment: .leading) {
                Text(review.release.title)
                    .fontWeight(.bold)
                    .foregroundColor(preferences.theme.primaryColor)

                Text(review.band.name)
                    .fontWeight(.semibold)
                    .foregroundColor(preferences.theme.secondaryColor)

                Text(review.title)

                Text(review.date) +
                Text(" • ") +
                Text("\(review.rating)%")
                    .foregroundColor(.byRating(review.rating))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
}
