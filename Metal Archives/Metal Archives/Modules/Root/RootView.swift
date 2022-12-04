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
    let apiService: APIServiceProtocol

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView { HomeView(apiService: apiService) }
                .tabItem {
                    Image(systemName: selectedTab == .home ? "house.fill" : "house")
                    Text("Home")
                }
                .tag(RootViewTab.home)

            NavigationView { SearchView(apiService: apiService) }
                .tabItem {
                    Image(systemName: selectedTab == .search ?
                            "magnifyingglass.circle.fill" : "magnifyingglass.circle")
                    Text("Search")
                }
                .tag(RootViewTab.search)

            NavigationView { BrowseView(apiService: apiService) }
                .tabItem {
                    Image(systemName: selectedTab == .browse ?
                            "tray.2.fill" : "tray.2")
                    Text("Browse")
                }
                .tag(RootViewTab.browse)

            /*
            NavigationView { MyAccountView() }
                .tabItem {
                    Image(systemName: selectedTab == .myAccount ?
                          "person.fill" : "person")
                    Text("My account")
                }
                .tag(RootViewTab.myAccount)
             */

            NavigationView { SettingsView() }
                .tabItem {
                    Image(systemName: selectedTab == .settings ?
                          "gearshape.fill" : "gearshape")
                    Text("Settings")
                }
                .tag(RootViewTab.settings)
        }
        .accentColor(preferences.theme.primaryColor)
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(apiService: APIService())
            .environment(\.colorScheme, .dark)
            .environmentObject(Preferences())
    }
}
