//
//  HomeView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/06/2021.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var preferences: Preferences
    let apiService: APIServiceProtocol

    var body: some View {
        ScrollView {
            VStack {
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
                        UpcomingAlbumsSection(apiService: apiService)
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
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(apiService: APIService())
            .environment(\.colorScheme, .dark)
            .environmentObject(Preferences())
    }
}
