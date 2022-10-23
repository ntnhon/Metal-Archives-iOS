//
//  BrowseView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/06/2021.
//

import SwiftUI

struct BrowseView: View {
    @EnvironmentObject private var preferences: Preferences
    @State private var randomBandUrlString: String?
    let apiService: APIServiceProtocol

    var body: some View {
        Form {
            newsStatisticSection
            topOfSection
            bandsSection
            labelsSection
            ripSection
            randomSection
        }
        .navigationTitle("Browse")
        .onAppear {
            randomBandUrlString = nil
            randomBandUrlString = "https://www.metal-archives.com/band/random"
        }
    }

    private var newsStatisticSection: some View {
        Section(header: Text("News & statistics")) {
            NavigationLink(destination: {
                NewsArchivesView(apiService: apiService)
            }, label: {
                HStack {
                    Image(systemName: "newspaper.fill")
                        .foregroundColor(preferences.theme.primaryColor)
                    Text("News archives")
                }
            })

            NavigationLink(destination: {
                if #available(iOS 16, *) {
                    StatsView(apiService: apiService)
                } else {
                    Text("This page requires iOS 16 or above.")
                }
            }, label: {
                HStack {
                    Image(systemName: "chart.pie.fill")
                        .foregroundColor(preferences.theme.primaryColor)
                    Text("Statistics")
                }
            })
        }
    }

    private var topOfSection: some View {
        Section(content: {
            NavigationLink(destination: {
                TopBandsView(apiService: apiService)
            }, label: {
                Label("Top 100 bands", systemImage: "person.3.fill")
            })

            NavigationLink(destination: {
                TopAlbumsView(apiService: apiService)
            }, label: {
                Label("Top 100 albums", systemImage: "opticaldisc")
            })

            NavigationLink(destination: {
                TopMembersView(apiService: apiService)
            }, label: {
                Label("Top 100 members", systemImage: "person.fill")
            })
        }, header: {
            Text("Top of Metal Archives")
        })
    }

    private var bandsSection: some View {
        Section(header: Text("Bands")) {
            NavigationLink(destination: AlphabetView(apiService: apiService, mode: .bands)) {
                HStack {
                    Image(systemName: "abc")
                        .foregroundColor(preferences.theme.primaryColor)
                    Text("Alphabetical")
                }
            }

            NavigationLink(destination: CountryListView(apiService: apiService, mode: .bands)) {
                HStack {
                    Image(systemName: "globe")
                        .foregroundColor(preferences.theme.primaryColor)
                    Text("Country")
                }
            }

            NavigationLink(destination: GenreListView(apiService: apiService)) {
                HStack {
                    Image(systemName: "guitars.fill")
                        .foregroundColor(preferences.theme.primaryColor)
                    Text("Genre")
                }
            }
        }
    }

    private var labelsSection: some View {
        Section(header: Text("Labels")) {
            NavigationLink(destination: AlphabetView(apiService: apiService, mode: .labels)) {
                HStack {
                    Image(systemName: "abc")
                        .foregroundColor(preferences.theme.primaryColor)
                    Text("Alphabetical")
                }
            }

            NavigationLink(destination: CountryListView(apiService: apiService, mode: .labels)) {
                HStack {
                    Image(systemName: "globe")
                        .foregroundColor(preferences.theme.primaryColor)
                    Text("Country")
                }
            }
        }
    }

    private var ripSection: some View {
        Section(header: Text("R.I.P")) {
            NavigationLink(destination: {
                DeceasedArtistsView(apiService: apiService)
            }, label: {
                HStack {
                    Image(systemName: "staroflife.fill")
                        .foregroundColor(preferences.theme.primaryColor)
                    Text("Deceased artists")
                }
            })
        }
    }

    private var randomSection: some View {
        Section(header: Text("Random")) {
            let bandView = BandView(apiService: apiService,
                                    bandUrlString: randomBandUrlString ?? "")
            NavigationLink(destination: bandView) {
                HStack {
                    Image(systemName: "questionmark")
                        .foregroundColor(preferences.theme.primaryColor)
                    Text("Random band")
                }
            }
        }
    }
}

struct BrowseView_Previews: PreviewProvider {
    static var previews: some View {
        BrowseView(apiService: APIService())
            .environment(\.colorScheme, .dark)
            .environmentObject(Preferences())
    }
}
