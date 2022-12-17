//
//  ReviewView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 16/10/2022.
//

import SwiftUI

struct ReviewView: View {
    @StateObject private var viewModel: ReviewViewModel

    init(apiService: APIServiceProtocol, urlString: String) {
        _viewModel = .init(wrappedValue: .init(apiService: apiService,
                                               urlString: urlString))
    }

    var body: some View {
        ZStack {
            switch viewModel.reviewFetchable {
            case .fetching:
                HornCircularLoader()
            case .fetched(let review):
                ReviewContentView(apiService: viewModel.apiService, review: review)
                    .environmentObject(viewModel)
            case .error(let error):
                VStack {
                    Text(error.userFacingMessage)
                    RetryButton {
                        Task {
                            await viewModel.fetchRelease()
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.fetchRelease()
        }
    }
}

private struct ReviewContentView: View {
    @EnvironmentObject private var preferences: Preferences
    @EnvironmentObject private var viewModel: ReviewViewModel
    @Environment(\.selectedPhoto) private var selectedPhoto
    @State private var titleViewAlpha = 0.0
    @State private var coverScaleFactor: CGFloat = 1.0
    @State private var coverOpacity: Double = 1.0
    @State private var detail: Detail?
    private let coverViewHeight: CGFloat
    private let minCoverScaleFactor: CGFloat = 0.5
    private let maxCoverScaleFactor: CGFloat = 1.2
    let apiService: APIServiceProtocol
    let review: Review

    init(apiService: APIServiceProtocol, review: Review) {
        self.apiService = apiService
        self.review = review
        self.coverViewHeight = review.coverPhotoUrlString != nil ? 300 : 0
    }

    var body: some View {
        ZStack(alignment: .top) {
            DetailView(detail: $detail, apiService: apiService)

            ReviewCoverView(scaleFactor: $coverScaleFactor, opacity: $coverOpacity)
                .environmentObject(viewModel)
                .frame(height: coverViewHeight)
                .opacity(review.coverPhotoUrlString != nil ? 1 : 0)

            OffsetAwareScrollView(
                axes: .vertical,
                showsIndicator: true,
                onOffsetChanged: { point in
                    /// Calculate `titleViewAlpha`
                    let screenBounds = UIScreen.main.bounds
                    if point.y < 0,
                       abs(point.y) > (min(screenBounds.width, screenBounds.height) / 4) {
                        titleViewAlpha = (abs(point.y) + 300) / min(screenBounds.width, screenBounds.height)
                    } else {
                        titleViewAlpha = 0.0
                    }

                    if point.y < 0 {
                        var factor = min(1.0, 70 / abs(point.y))
                        factor = factor < minCoverScaleFactor ? minCoverScaleFactor : factor
                        coverScaleFactor = factor
                        coverOpacity = (factor - minCoverScaleFactor) / minCoverScaleFactor
                    } else {
                        var factor = max(1.0, point.y / 70)
                        factor = factor > maxCoverScaleFactor ? maxCoverScaleFactor : factor
                        coverScaleFactor = factor
                    }
                },
                content: {
                    VStack(alignment: .leading, spacing: 0) {
                        Color.gray
                            .opacity(0.001)
                            .frame(height: coverViewHeight)
                            .onTapGesture {
                                if let coverImage = viewModel.cover {
                                    selectedPhoto.wrappedValue = .init(image: coverImage,
                                                                       description: review.release.title)
                                }
                            }

                        ReviewInfoView(review: review,
                                       onSelectUser: { url in detail = .user(url) },
                                       onSelectBand: { url in detail = .band(url) },
                                       onSelectRelease: { url in detail = .release(url) })
                    }
                })
        }
        .toolbar { toolbarContent }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Group {
                switch viewModel.coverFetchable {
                case .fetched(let image):
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50)
                            .padding(.vertical, 4)
                    }
                default:
                    EmptyView()
                }
            }
            .opacity(titleViewAlpha)
        }

        ToolbarItem(placement: .principal) {
            Text(review.title)
                .font(.title2)
                .fontWeight(.bold)
                .textSelection(.enabled)
                .minimumScaleFactor(0.5)
                .opacity(titleViewAlpha)
        }
    }
}
