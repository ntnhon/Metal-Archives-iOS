//
//  UserView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 16/10/2022.
//

import SwiftUI

struct UserView: View {
    @StateObject private var viewModel: UserViewModel
    @Binding private var path: NavigationPath

    init(urlString: String, path: Binding<NavigationPath>) {
        _viewModel = .init(wrappedValue: .init(urlString: urlString))
        _path = path
    }

    var body: some View {
        ZStack {
            switch viewModel.userFetchable {
            case .fetching:
                MALoadingIndicator()
            case let .fetched(user):
                UserContentView(user: user, path: $path)
                    .environmentObject(viewModel)
            case let .error(error):
                VStack {
                    Text(error.userFacingMessage)
                    RetryButton {
                        await viewModel.fetchUser()
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
    @Binding private var path: NavigationPath
    let user: User

    init(user: User, path: Binding<NavigationPath>) {
        let userId = user.id
        self.user = user
        _tabsDatasource = .init(wrappedValue: .init(user: user))
        _reviewsViewModel = .init(wrappedValue: .init(userId: userId))
        _submittedBandsViewModel = .init(wrappedValue: .init(userId: userId))
        _modificationsViewModel = .init(wrappedValue: .init(userId: userId))
        _albumCollectionViewModel = .init(wrappedValue: .init(userId: userId,
                                                              type: .collection))
        _forTradeListViewModel = .init(wrappedValue: .init(userId: userId,
                                                           type: .forTrade))
        _wantedListViewModel = .init(wrappedValue: .init(userId: userId,
                                                         type: .wanted))
        _path = path
    }

    var body: some View {
        ZStack {
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
                                        user: user,
                                        onSelectReview: { url in path.append(Detail.review(url)) },
                                        onSelectBand: { url in path.append(Detail.band(url)) },
                                        onSelectRelease: { url in path.append(Detail.release(url)) })
                            .padding([.horizontal, .bottom])

                    case .albumCollection:
                        UserReleasesView(viewModel: albumCollectionViewModel,
                                         onSelectBand: { url in path.append(Detail.band(url)) },
                                         onSelectRelease: { url in path.append(Detail.release(url)) })
                            .padding([.horizontal, .bottom])

                    case .wantedList:
                        UserReleasesView(viewModel: wantedListViewModel,
                                         onSelectBand: { url in path.append(Detail.band(url)) },
                                         onSelectRelease: { url in path.append(Detail.release(url)) })
                            .padding([.horizontal, .bottom])

                    case .tradeList:
                        UserReleasesView(viewModel: forTradeListViewModel,
                                         onSelectBand: { url in path.append(Detail.band(url)) },
                                         onSelectRelease: { url in path.append(Detail.release(url)) })
                            .padding([.horizontal, .bottom])

                    case .submittedBands:
                        UserSubmittedBandsView(viewModel: submittedBandsViewModel,
                                               onSelectBand: { url in path.append(Detail.band(url)) })
                            .padding([.horizontal, .bottom])

                    case .modificationHistory:
                        UserModificationsView(viewModel: modificationsViewModel,
                                              onSelectBand: { url in path.append(Detail.band(url)) },
                                              onSelectArtist: { url in path.append(Detail.artist(url)) },
                                              onSelectRelease: { url in path.append(Detail.release(url)) },
                                              onSelectLabel: { url in path.append(Detail.label(url)) })
                            .padding([.horizontal, .bottom])
                    }
                }
            }
        }
        .navigationTitle(user.username)
        .navigationBarTitleDisplayMode(.large)
    }
}
