//
//  AdvancedSearchView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/06/2021.
//

import SwiftUI

// swiftlint:disable line_length
private let kQuickTips = """

    Tip 1️⃣: to search for part of a word, use * as wildcards (e.g. searching "hel*" will return results containing "hell" or "helm").

    Tip 2️⃣: to exclude terms, use the - symbol (e.g. searching "death -melodic" will return results that do not contain the word "melodic").
    """
// swiftlint:enable line_length

struct AdvancedSearchView: View {
    @State private var showTips = false
    var body: some View {
        Form {
            Section(footer: Text(kQuickTips)) {
                NavigationLink(destination: AdvancedSearchBandsView()) {
                    Text("Advanced search bands")
                }

                NavigationLink(destination: AdvancedSearchAlbumsView()) {
                    Text("Advanced search albums")
                }

                NavigationLink(destination: AdvancedSearchSongsView()) {
                    Text("Advanced search songs")
                }
            }
        }
        .navigationTitle("Advanced search")
        .sheet(isPresented: $showTips) {
            AdvancedSearchTipsView()
        }
        .navigationBarItems(trailing:
                                Button(action: {
                                    showTips = true
                                }, label: {
                                    Text("More tips 💡")
                                }))
    }
}

struct AdvancedSearchView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AdvancedSearchView()
        }
    }
}
