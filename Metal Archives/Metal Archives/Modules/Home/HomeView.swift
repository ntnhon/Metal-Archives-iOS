//
//  HomeView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/06/2021.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var preferences: Preferences
    @State private var selectedBandUrl: String?
    @State private var selectedReleaseUrl: String?
    @State private var selectedLabelUrl: String?
    @State private var selectedReviewUrl: String?
    @State private var selectedUserUrl: String?
    let apiService: APIServiceProtocol

    var body: some View {
        let isShowingBand = makeIsShowingBandDetailBinding()
        let isShowingRelease = makeIsShowingReleaseDetailBinding()
        let isShowingLabel = makeIsShowingLabelDetailBinding()
        let isShowingReview = makeIsShowingReviewDetailBinding()
        let isShowingUser = makeIsShowingUserDetailBinding()

        ScrollView {
            VStack {
                NavigationLink(
                    isActive: isShowingBand,
                    destination: {
                        if let selectedBandUrl {
                            BandView(apiService: apiService, bandUrlString: selectedBandUrl)
                        } else {
                            EmptyView()
                        }
                    }, label: {
                        EmptyView()
                    })

                NavigationLink(
                    isActive: isShowingRelease,
                    destination: {
                        if let selectedReleaseUrl {
                            ReleaseView(apiService: apiService,
                                        urlString: selectedReleaseUrl,
                                        parentRelease: nil)
                        } else {
                            EmptyView()
                        }
                    }, label: {
                        EmptyView()
                    })

                NavigationLink(
                    isActive: isShowingLabel,
                    destination: {
                        if let selectedLabelUrl {
                            LabelView(apiService: apiService, urlString: selectedLabelUrl)
                        } else {
                            EmptyView()
                        }
                    }, label: {
                        EmptyView()
                    })

                NavigationLink(
                    isActive: isShowingReview,
                    destination: {
                        if let selectedReviewUrl {
                            ReviewView(apiService: apiService, urlString: selectedReviewUrl)
                        } else {
                            EmptyView()
                        }
                    }, label: {
                        EmptyView()
                    })

                NavigationLink(
                    isActive: isShowingUser,
                    destination: {
                        if let selectedUserUrl {
                            UserView(apiService: apiService, urlString: selectedUserUrl)
                        } else {
                            EmptyView()
                        }
                    }, label: {
                        EmptyView()
                    })

                Text("What's news on Metal Archives today")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.bottom)

                ForEach(preferences.homeSectionOrder) { section in
                    switch section {
                    case .latestAdditions:
                        LatestAdditionsSection()
                    case .latestUpdates:
                        LatestUpdatesSection()
                    case .latestReviews:
                        LatestReviewsSection()
                    case .upcomingAlbums:
                        UpcomingAlbumsSection(apiService: apiService,
                                              onSelectBand: { url in selectedBandUrl = url },
                                              onSelectRelease: { url in selectedReleaseUrl = url })
                    }
                }
            }
        }
        .navigationTitle(Text(navigationTitle))
        .navigationBarTitleDisplayMode(.large)
    }

    private var navigationTitle: String {
        let formatter = DateFormatter(dateFormat: "EEEE, d MMM yyyy")
        return formatter.string(for: Date()) ?? "Metal Archives"
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

    private func makeIsShowingLabelDetailBinding() -> Binding<Bool> {
        .init(get: {
            selectedLabelUrl != nil
        }, set: { newValue in
            if !newValue {
                selectedLabelUrl = nil
            }
        })
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

    private func makeIsShowingUserDetailBinding() -> Binding<Bool> {
        .init(get: {
            selectedUserUrl != nil
        }, set: { newValue in
            if !newValue {
                selectedUserUrl = nil
            }
        })
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(apiService: APIService())
            .environment(\.colorScheme, .dark)
            .environmentObject(Preferences())
    }
}
