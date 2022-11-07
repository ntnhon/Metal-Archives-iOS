//
//  UserView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 16/10/2022.
//

import SwiftUI

struct UserView: View {
    @StateObject private var viewModel: UserViewModel

    init(apiService: APIServiceProtocol, urlString: String) {
        _viewModel = .init(wrappedValue: .init(apiService: apiService,
                                               urlString: urlString))
    }

    var body: some View {
        ZStack {
            switch viewModel.userFetchable {
            case .fetching:
                HornCircularLoader()
            case .fetched(let user):
                UserContentView(apiService: viewModel.apiService, user: user)
                    .environmentObject(viewModel)
            case .error(let error):
                VStack {
                    Text(error.userFacingMessage)
                    RetryButton {
                        Task {
                            await viewModel.fetchUser()
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.fetchUser()
        }
    }
}

private struct UserContentView: View {
    @EnvironmentObject private var viewModel: UserViewModel
    @StateObject private var tabsDatasource: UserTabsDatasource
    @StateObject private var reviewsViewModel: UserReviewsViewModel
    @State private var selectedReviewUrl: String?
    @State private var selectedBandUrl: String?
    @State private var selectedReleaseUrl: String?
    let user: User

    init(apiService: APIServiceProtocol, user: User) {
        self.user = user
        self._tabsDatasource = .init(wrappedValue: .init(user: user))
        self._reviewsViewModel = .init(wrappedValue: .init(apiService: apiService, userId: user.id))
    }

    var body: some View {
        let isShowingReviewDetail = makeIsShowingReviewDetailBinding()
        let isShowingBandDetail = makeIsShowingBandDetailBinding()
        let isShowingReleaseDetail = makeIsShowingReleaseDetailBinding()

        ZStack {
            NavigationLink(
                isActive: isShowingReviewDetail,
                destination: {
                    if let selectedReviewUrl {
                        ReviewView(apiService: viewModel.apiService, urlString: selectedReviewUrl)
                    } else {
                        EmptyView()
                    }},
                label: { EmptyView() })

            NavigationLink(
                isActive: isShowingBandDetail,
                destination: {
                    if let selectedBandUrl {
                        BandView(apiService: viewModel.apiService, bandUrlString: selectedBandUrl)
                    } else {
                        EmptyView()
                    }},
                label: { EmptyView() })

            NavigationLink(
                isActive: isShowingReleaseDetail,
                destination: {
                    if let selectedReleaseUrl {
                        ReleaseView(apiService: viewModel.apiService,
                                    urlString: selectedReleaseUrl,
                                    parentRelease: nil)
                    } else {
                        EmptyView()
                    }},
                label: { EmptyView() })

            ScrollView {
                VStack {
                    UserInfoView(user: user)

                    HorizontalTabs(datasource: tabsDatasource)
                        .padding(.vertical)
                        .background(Color(.systemBackground))

                    switch tabsDatasource.selectedTab {
                    case .comments:
                        if let comments = user.comments {
                            Text(comments)
                                .padding([.horizontal, .bottom])
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                    case .reviews:
                        UserReviewsView(viewModel: reviewsViewModel,
                                        onSelectReview: { url in selectedReviewUrl = url },
                                        onSelectBand: { url in selectedBandUrl = url },
                                        onSelectRelease: { url in selectedReleaseUrl = url })
                        .padding([.horizontal, .bottom])

                    case .albumCollection:
                        Text("Album collections")

                    case .wantedList:
                        Text("Wanted list")

                    case .tradeList:
                        Text("Trade list")

                    case .submittedBands:
                        Text("Submitted bands")

                    case .modificationHistory:
                        Text("Modification history")
                    }
                }
            }
        }
        .navigationTitle(user.username)
        .navigationBarTitleDisplayMode(.large)
    }

    private func makeIsShowingReviewDetailBinding() -> Binding<Bool> {
        .init(get: {
            selectedReviewUrl != nil
        }, set: { newValue in
            if !newValue {
                selectedReviewUrl = nil
            }
        })
    }

    private func makeIsShowingBandDetailBinding() -> Binding<Bool> {
        .init(get: {
            selectedBandUrl != nil
        }, set: { newValue in
            if !newValue {
                selectedBandUrl = nil
            }
        })
    }

    private func makeIsShowingReleaseDetailBinding() -> Binding<Bool> {
        .init(get: {
            selectedReleaseUrl != nil
        }, set: { newValue in
            if !newValue {
                selectedReleaseUrl = nil
            }
        })
    }
}
