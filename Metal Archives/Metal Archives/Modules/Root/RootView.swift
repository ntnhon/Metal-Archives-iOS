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
    @State private var selectedTab: RootViewTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: selectedTab == .home ? "house.fill" : "house")
                    Text("Home")
                }
                .tag(RootViewTab.home)

            SearchView()
                .tabItem {
                    Image(systemName: selectedTab == .search ?
                            "magnifyingglass.circle.fill" : "magnifyingglass.circle")
                    Text("Search")
                }
                .tag(RootViewTab.search)

            BrowseView()
                .tabItem {
                    Image(systemName: "list.bullet.indent")
                    Text("Browse")
                }
                .tag(RootViewTab.browse)

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
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
