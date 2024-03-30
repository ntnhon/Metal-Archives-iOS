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

    var selectedImageName: String { "\(imageName).fill" }
}

struct RootView: View {
    @EnvironmentObject private var preferences: Preferences
    @State private var selectedTab = HomeTab.home
    let apiService: APIServiceProtocol

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView { HomeView(apiService: apiService) }
                .tab(.home, selectedTab: selectedTab)

            NavigationView { SearchView(apiService: apiService) }
                .tab(.search, selectedTab: selectedTab)

            NavigationView { BrowseView(apiService: apiService) }
                .tab(.browse, selectedTab: selectedTab)

            NavigationView { SettingsView() }
                .tab(.settings, selectedTab: selectedTab)
        }
        .accentColor(preferences.theme.primaryColor)
    }
}

private extension View {
    func tab(_ tab: HomeTab, selectedTab: HomeTab) -> some View {
        tabItem { Label(tab.title, systemImage: tab == selectedTab ? tab.selectedImageName : tab.imageName) }
            .tag(tab)
    }
}

/*
 struct RootView_Previews: PreviewProvider {
     static var previews: some View {
         RootView(apiService: APIService())
             .environment(\.colorScheme, .dark)
             .environmentObject(Preferences())
     }
 }
 */
