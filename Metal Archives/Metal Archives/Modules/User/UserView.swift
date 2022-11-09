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
    @State private var selectedReviewUrl: String?
    @State private var selectedBandUrl: String?
    @State private var selectedReleaseUrl: String?
    @State private var selectedArtistUrl: String?
    @State private var selectedLabelUrl: String?
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
        let isShowingReviewDetail = makeIsShowingReviewDetailBinding()
        let isShowingBandDetail = makeIsShowingBandDetailBinding()
        let isShowingReleaseDetail = makeIsShowingReleaseDetailBinding()
        let isShowingArtistDetail = makeIsShowingArtistDetailBinding()
        let isShowingLabelDetail = makeIsShowingLabelDetailBinding()

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

            NavigationLink(
                isActive: isShowingArtistDetail,
                destination: {
                    if let selectedArtistUrl {
                        ArtistView(apiService: viewModel.apiService, urlString: selectedArtistUrl)
                    } else {
                        EmptyView()
                    }},
                label: { EmptyView() })

            NavigationLink(
                isActive: isShowingLabelDetail,
                destination: {
                    if let selectedLabelUrl {
                        LabelView(apiService: viewModel.apiService, urlString: selectedLabelUrl)
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
                        UserReleasesView(viewModel: albumCollectionViewModel,
                                         onSelectBand: { url in selectedBandUrl = url },
                                         onSelectRelease: { url in selectedReleaseUrl = url })
                        .padding([.horizontal, .bottom])

                    case .wantedList:
                        UserReleasesView(viewModel: wantedListViewModel,
                                         onSelectBand: { url in selectedBandUrl = url },
                                         onSelectRelease: { url in selectedReleaseUrl = url })
                        .padding([.horizontal, .bottom])

                    case .tradeList:
                        UserReleasesView(viewModel: forTradeListViewModel,
                                         onSelectBand: { url in selectedBandUrl = url },
                                         onSelectRelease: { url in selectedReleaseUrl = url })
                        .padding([.horizontal, .bottom])

                    case .submittedBands:
                        UserSubmittedBandsView(viewModel: submittedBandsViewModel) { url in
                            selectedBandUrl = url
                        }
                        .padding([.horizontal, .bottom])

                    case .modificationHistory:
                        UserModificationsView(viewModel: modificationsViewModel,
                                              onSelectBand: { url in selectedBandUrl = url },
                                              onSelectArtist: { url in selectedArtistUrl = url },
                                              onSelectRelease: { url in selectedReleaseUrl = url },
                                              onSelectLabel: { url in selectedLabelUrl = url })
                        .padding([.horizontal, .bottom])
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

    private func makeIsShowingArtistDetailBinding() -> Binding<Bool> {
        .init(get: {
            selectedArtistUrl != nil
        }, set: { newValue in
            if !newValue {
                selectedArtistUrl = nil
            }
        })
    }

    private func makeIsShowingLabelDetailBinding() -> Binding<Bool> {
        .init(get: {
            selectedLabelUrl != nil
        }, set: { newValue in
            if !newValue {
                selectedLabelUrl = nil
            }
        })
    }
}
