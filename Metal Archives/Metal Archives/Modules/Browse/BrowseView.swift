//
//  BrowseView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/06/2021.
//

import SwiftUI

struct BrowseView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var preferences: Preferences

    var body: some View {
        let primaryColor = preferences.theme.primaryColor(for: colorScheme)
        NavigationView {
            Form {
                Section {
                    NavigationLink(destination: Text("News archives")) {
                        HStack {
                            Image(systemName: "newspaper")
                                .foregroundColor(primaryColor)
                            Text("News archives")
                        }
                    }

                    NavigationLink(destination: Text("Stats")) {
                        HStack {
                            Image(systemName: "number")
                                .foregroundColor(primaryColor)
                            Text("Statistic")
                        }
                    }
                }

                Section(header: Text("Bands")) {
                    NavigationLink(destination: Text("Band alphabetical")) {
                        HStack {
                            Image(systemName: "abc")
                                .foregroundColor(primaryColor)
                            Text("Alphabetical")
                        }
                    }

                    NavigationLink(destination: Text("Band by country")) {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(primaryColor)
                            Text("Country")
                        }
                    }

                    NavigationLink(destination: Text("Band by label")) {
                        HStack {
                            Image(systemName: "tag")
                                .foregroundColor(primaryColor)
                            Text("Label")
                        }
                    }
                }

                Section(header: Text("Labels")) {
                    NavigationLink(destination: Text("Label alphabetical")) {
                        HStack {
                            Image(systemName: "abc")
                                .foregroundColor(primaryColor)
                            Text("Alphabetical")
                        }
                    }

                    NavigationLink(destination: Text("Label by country")) {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(primaryColor)
                            Text("Country")
                        }
                    }
                }

                Section(header: Text("R.I.P")) {
                    NavigationLink(destination: Text("RIP")) {
                        Text("😇 Deceased artists")
                    }
                }

                Section(header: Text("Random")) {
                    NavigationLink(destination: Text("Random band")) {
                        HStack {
                            Image(systemName: "questionmark")
                                .foregroundColor(primaryColor)
                            Text("Random band")
                        }
                    }
                }
            }
            .navigationTitle("Browse")
        }
    }
}

struct BrowseView_Previews: PreviewProvider {
    static var previews: some View {
        BrowseView()
            .environmentObject(Preferences())
    }
}
