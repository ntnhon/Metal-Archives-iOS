//
//  BrowseView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/06/2021.
//

import SwiftUI

struct BrowseView: View {
    @EnvironmentObject private var preferences: Preferences
    @State private var randomBandUrlString = "https://www.metal-archives.com/band/random"

    var body: some View {
        let primaryColor = preferences.theme.primaryColor
        NavigationView {
            Form {
                Section(header: Text("News & statistics")) {
                    NavigationLink(destination: Text("News archives")) {
                        HStack {
                            Image(systemName: "newspaper.fill")
                                .foregroundColor(primaryColor)
                            Text("News archives")
                        }
                    }

                    NavigationLink(destination: Text("Stats")) {
                        HStack {
                            Image(systemName: "chart.pie.fill")
                                .foregroundColor(primaryColor)
                            Text("Statistics")
                        }
                    }
                }

                // Hall of fame
                Section(header: Text("Hall of Fame")) {
                    NavigationLink(destination: Top100BandsView()) {
                        HStack {
                            Image(systemName: "person.3.fill")
                                .foregroundColor(primaryColor)
                            Text("Top 100 bands")
                        }
                    }

                    NavigationLink(destination: Top100AlbumsView()) {
                        HStack {
                            Image(systemName: "opticaldisc")
                                .foregroundColor(primaryColor)
                            Text("Top 100 albums")
                        }
                    }

                    NavigationLink(destination: Top100MembersView()) {
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(primaryColor)
                            Text("Top 100 members")
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
                            Image(systemName: "guitars.fill")
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
                            Image(systemName: "staroflife.fill")
                                .foregroundColor(primaryColor)
                            Text("Deceased artists")
                        }
                    }
                }

                // Random
                Section(header: Text("Random")) {
                    let bandView = BandView(bandUrlString: randomBandUrlString)
                    NavigationLink(destination: bandView) {
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
            .environment(\.colorScheme, .dark)
            .environmentObject(Preferences())
    }
}
