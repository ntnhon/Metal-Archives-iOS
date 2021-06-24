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
                NavigationLink(destination: Text("News archives")) {
                    HStack {
                        Image(systemName: "newspaper")
                            .foregroundColor(primaryColor)
                        Text("News archives")
                    }
                }

                // Stats
                Section(header: Text("Statistic")) {
                    NavigationLink(destination: Text("Stats")) {
                        HStack {
                            Image(systemName: "chart.pie")
                                .foregroundColor(primaryColor)
                            Text("Statistic")
                        }
                    }

                    NavigationLink(destination: Text("Top 100 bands")) {
                        HStack {
                            Image(systemName: "person.3")
                                .foregroundColor(primaryColor)
                            Text("Top 100 bands")
                        }
                    }

                    NavigationLink(destination: Text("Top 100 albums")) {
                        HStack {
                            Image(systemName: "opticaldisc")
                                .foregroundColor(primaryColor)
                            Text("Top 100 albums")
                        }
                    }
                }

                // Bands
                Section(header: Text("Bands")) {
                    NavigationLink(destination: AlphabetView(mode: .bands)) {
                        HStack {
                            Image(systemName: "abc")
                                .foregroundColor(primaryColor)
                            Text("Alphabetical")
                        }
                    }

                    NavigationLink(destination: CountryListView(mode: .bands)) {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(primaryColor)
                            Text("Country")
                        }
                    }

                    NavigationLink(destination: GenreListView()) {
                        HStack {
                            Image(systemName: "guitars")
                                .foregroundColor(primaryColor)
                            Text("Genre")
                        }
                    }
                }

                // Labels
                Section(header: Text("Labels")) {
                    NavigationLink(destination: AlphabetView(mode: .labels)) {
                        HStack {
                            Image(systemName: "abc")
                                .foregroundColor(primaryColor)
                            Text("Alphabetical")
                        }
                    }

                    NavigationLink(destination: CountryListView(mode: .labels)) {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(primaryColor)
                            Text("Country")
                        }
                    }
                }

                // R.I.P
                Section(header: Text("R.I.P")) {
                    NavigationLink(destination: Text("RIP")) {
                        HStack {
                            Image(systemName: "staroflife")
                                .foregroundColor(primaryColor)
                            Text("Deceased artists")
                        }
                    }
                }

                // Random
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
