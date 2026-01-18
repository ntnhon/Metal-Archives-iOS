//
//  HomeView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/06/2021.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var preferences: Preferences
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                LazyVStack {
                    ForEach(preferences.homeSectionOrder) { section in
                        switch section {
                        case .latestAdditions:
                            LatestAdditionsSection(path: $path)
                        case .latestUpdates:
                            LatestUpdatesSection(path: $path)
                        case .latestReviews:
                            LatestReviewsSection(path: $path)
                        case .upcomingAlbums:
                            UpcomingAlbumsSection(path: $path)
                        }
                    }
                }
            }
            .navigationTitle(Text(navigationTitle))
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: Detail.self) { detail in
                DetailView(detail: detail, path: $path)
            }
        }
    }
}

private extension HomeView {
    var navigationTitle: String {
        let formatter = DateFormatter(dateFormat: "EEEE, d MMM yyyy")
        return formatter.string(for: Date()) ?? "Metal Archives"
    }
}

#Preview {
    HomeView()
        .environment(\.colorScheme, .dark)
        .environmentObject(Preferences())
}
