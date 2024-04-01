//
//  HomeView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/06/2021.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var preferences: Preferences
    @State private var detail: Detail?

    var body: some View {
        ScrollView {
            VStack {
                DetailView(detail: $detail)

                ForEach(preferences.homeSectionOrder) { section in
                    switch section {
                    case .latestAdditions:
                        LatestAdditionsSection(detail: $detail)
                    case .latestUpdates:
                        LatestUpdatesSection(detail: $detail)
                    case .latestReviews:
                        LatestReviewsSection(detail: $detail)
                    case .upcomingAlbums:
                        UpcomingAlbumsSection(detail: $detail)
                    }
                }
            }
            .padding(.top)
        }
        .navigationTitle(Text(navigationTitle))
        .navigationBarTitleDisplayMode(.large)
    }

    private var navigationTitle: String {
        let formatter = DateFormatter(dateFormat: "EEEE, d MMM yyyy")
        return formatter.string(for: Date()) ?? "Metal Archives"
    }
}

#Preview {
    HomeView()
        .environment(\.colorScheme, .dark)
        .environmentObject(Preferences())
}
