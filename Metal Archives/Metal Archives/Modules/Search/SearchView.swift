//
//  SearchView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/06/2021.
//

import SwiftUI

struct SearchView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var preferences: Preferences
    @State private var showAdvancedSearch = false

    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink(destination: AdvancedSearchView(), isActive: $showAdvancedSearch) {
                    EmptyView()
                }

                Form {
                    Section(header: Text("Search History")) {

                    }
                }
            }
            .navigationTitle("Search")
            .navigationBarItems(trailing:
                                    Button(action: {
                                        showAdvancedSearch = true
                                    }, label: {
                                        Text("Advanced search")
                                    }))
        }
        .accentColor(preferences.theme.primaryColor(for: colorScheme))
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
            .environmentObject(Preferences())
    }
}
