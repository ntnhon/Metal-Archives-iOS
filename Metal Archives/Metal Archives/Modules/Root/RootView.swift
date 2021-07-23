//
//  RootView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/06/2021.
//

import SwiftUI

private enum RootViewTab {
    case home, search, browse, myAccount, settings
}

struct RootView: View {
    @EnvironmentObject private var preferences: Preferences
    @State private var selectedTab: RootViewTab = .home

    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Image(systemName: selectedTab == .home ? "house.fill" : "house")
                        Text("Home")
                    }
                    .tag(RootViewTab.home)

                BrowseView()
                    .tabItem {
                        Image(systemName: selectedTab == .browse ?
                                "tray.2.fill" : "tray.2")
                        Text("Browse")
                    }
                    .tag(RootViewTab.browse)

                SearchView()
                    .tabItem {
                        Image(systemName: selectedTab == .search ?
                                "magnifyingglass.circle.fill" : "magnifyingglass.circle")
                        Text("Search")
                    }
                    .tag(RootViewTab.search)

                MyAccountView()
                    .tabItem {
                        Image(systemName: selectedTab == .myAccount ?
                                "person.fill" : "person")
                        Text("My account")
                    }
                    .tag(RootViewTab.myAccount)

                SettingsView()
                    .tabItem {
                        Image(systemName: selectedTab == .settings ?
                                "gearshape.fill" : "gearshape")
                        Text("Settings")
                    }
                    .tag(RootViewTab.settings)
            }
            .navigationTitle(navigationTitle())
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(preferences.theme.primaryColor)
    }

    private func navigationTitle() -> String {
        switch selectedTab {
        case .home: return ""
        case .browse: return "Browse"
        case .search: return ""
        case .myAccount: return ""
        case .settings: return "Settings"
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environment(\.colorScheme, .dark)
            .environmentObject(Preferences())
    }
}
