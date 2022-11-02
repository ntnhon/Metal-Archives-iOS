//
//  BrowseView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/06/2021.
//

import SwiftUI

struct BrowseView: View {
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
            NavigationLink(destination: NewsArchivesView(apiService: apiService)) {
                Label("News archives", systemImage: "newspaper.fill")
            }

            NavigationLink(destination: {
                if #available(iOS 16, *) {
                    StatsView(apiService: apiService)
                } else {
                    Text("This page requires iOS 16 or above.")
                }
            }, label: {
                Label("Statistics", systemImage: "chart.pie.fill")
            })
        }
    }

    private var topOfSection: some View {
        Section(content: {
            NavigationLink(destination: TopBandsView(apiService: apiService)) {
                Label("Top 100 bands", systemImage: "person.3.fill")
            }

            NavigationLink(destination: TopAlbumsView(apiService: apiService)) {
                Label("Top 100 albums", systemImage: "opticaldisc")
            }

            NavigationLink(destination: TopMembersView(apiService: apiService)) {
                Label("Top 100 members", systemImage: "person.fill")
            }
        }, header: {
            Text("Top of Metal Archives")
        })
    }

    private var bandsSection: some View {
        Section(header: Text("Bands")) {
            NavigationLink(destination: AlphabetView(apiService: apiService, mode: .bands)) {
                Label("Alphabetical", systemImage: "abc")
            }

            NavigationLink(destination: CountryListView(apiService: apiService, mode: .bands)) {
                Label("Country", systemImage: "globe")
            }

            NavigationLink(destination: GenreListView(apiService: apiService)) {
                Label("Genre", systemImage: "guitars.fill")
            }
        }
    }

    private var labelsSection: some View {
        Section(header: Text("Labels")) {
            NavigationLink(destination: AlphabetView(apiService: apiService, mode: .labels)) {
                Label("Alphabetical", systemImage: "abc")
            }

            NavigationLink(destination: CountryListView(apiService: apiService, mode: .labels)) {
                Label("Country", systemImage: "globe")
            }
        }
    }

    private var ripSection: some View {
        Section(header: Text("R.I.P")) {
            NavigationLink(destination: DeceasedArtistsView(apiService: apiService)) {
                Label("Deceased artists", systemImage: "staroflife.fill")
            }
        }
    }

    private var randomSection: some View {
        Section(header: Text("Random")) {
            let bandView = BandView(apiService: apiService,
                                    bandUrlString: randomBandUrlString ?? "")
            NavigationLink(destination: bandView) {
                Label("Random band", systemImage: "questionmark")
            }
        }
    }
}

struct BrowseView_Previews: PreviewProvider {
    static var previews: some View {
        BrowseView(apiService: APIService())
            .environment(\.colorScheme, .dark)
    }
}
