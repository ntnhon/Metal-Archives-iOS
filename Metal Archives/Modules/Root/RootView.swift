//
//  RootView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/06/2021.
//

import SwiftUI

private enum HomeTab: Int, CaseIterable {
    case home = 0, search, browse, myAccount, settings

    var title: String {
        switch self {
        case .home:
            return "Home"
        case .search:
            return "Search"
        case .browse:
            return "Browse"
        case .myAccount:
            return "My account"
        case .settings:
            return "Settings"
        }
    }

    var imageName: String {
        switch self {
        case .home:
            return "house"
        case .search:
            return "magnifyingglass.circle"
        case .browse:
            return "tray.2"
        case .myAccount:
            return "person"
        case .settings:
            return "gearshape"
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var preferences: Preferences
    @State private var selectedTab = HomeTab.home

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(HomeTab.home.title, systemImage: HomeTab.home.imageName, value: .home) {
                HomeView()
            }

            Tab(HomeTab.search.title, systemImage: HomeTab.search.imageName, value: .search, role: .search) {
                SearchView()
            }

            Tab(HomeTab.browse.title, systemImage: HomeTab.browse.imageName, value: .browse) {
                BrowseView()
            }

            Tab(HomeTab.settings.title, systemImage: HomeTab.settings.imageName, value: .settings) {
                SettingsView()
            }
        }
        .accentColor(preferences.theme.primaryColor)
    }
}

#Preview {
    RootView()
        .environment(\.colorScheme, .dark)
        .environmentObject(Preferences())
}
