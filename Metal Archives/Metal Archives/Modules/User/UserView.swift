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
    @StateObject private var submittedBandsViewModel: UserSubmittedBandsViewModel
    @StateObject private var modificationsViewModel: UserModificationsViewModel
    @StateObject private var albumCollectionViewModel: UserReleasesViewModel
    @StateObject private var forTradeListViewModel: UserReleasesViewModel
    @StateObject private var wantedListViewModel: UserReleasesViewModel
    @State private var detail: Detail?
    let user: User

    init(apiService: APIServiceProtocol, user: User) {
        let userId = user.id
        self.user = user
        self._tabsDatasource = .init(wrappedValue: .init(user: user))
        self._reviewsViewModel = .init(wrappedValue: .init(apiService: apiService, userId: userId))
        self._submittedBandsViewModel = .init(wrappedValue: .init(apiService: apiService, userId: userId))
        self._modificationsViewModel = .init(wrappedValue: .init(apiService: apiService, userId: userId))
        self._albumCollectionViewModel = .init(wrappedValue: .init(apiService: apiService,
                                                                   userId: userId,
                                                                   type: .collection))
        self._forTradeListViewModel = .init(wrappedValue: .init(apiService: apiService,
                                                                userId: userId,
                                                                type: .forTrade))
        self._wantedListViewModel = .init(wrappedValue: .init(apiService: apiService,
                                                              userId: userId,
                                                              type: .wanted))
    }

    var body: some View {
        ZStack {
            DetailView(detail: $detail, apiService: viewModel.apiService)

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
                                        onSelectReview: { url in detail = .review(url) },
                                        onSelectBand: { url in detail = .band(url) },
                                        onSelectRelease: { url in detail = .release(url) })
                        .padding([.horizontal, .bottom])

                    case .albumCollection:
                        UserReleasesView(viewModel: albumCollectionViewModel,
                                         onSelectBand: { url in detail = .band(url) },
                                         onSelectRelease: { url in detail = .release(url) })
                        .padding([.horizontal, .bottom])

                    case .wantedList:
                        UserReleasesView(viewModel: wantedListViewModel,
                                         onSelectBand: { url in detail = .band(url) },
                                         onSelectRelease: { url in detail = .release(url) })
                        .padding([.horizontal, .bottom])

                    case .tradeList:
                        UserReleasesView(viewModel: forTradeListViewModel,
                                         onSelectBand: { url in detail = .band(url) },
                                         onSelectRelease: { url in detail = .release(url) })
                        .padding([.horizontal, .bottom])

                    case .submittedBands:
                        UserSubmittedBandsView(viewModel: submittedBandsViewModel,
                                               onSelectBand: { url in detail = .band(url) })
                        .padding([.horizontal, .bottom])

                    case .modificationHistory:
                        UserModificationsView(viewModel: modificationsViewModel,
                                              onSelectBand: { url in detail = .band(url) },
                                              onSelectArtist: { url in detail = .artist(url) },
                                              onSelectRelease: { url in detail = .release(url) },
                                              onSelectLabel: { url in detail = .label(url) })
                        .padding([.horizontal, .bottom])
                    }
                }
            }
        }
        .navigationTitle(user.username)
        .navigationBarTitleDisplayMode(.large)
    }
}
