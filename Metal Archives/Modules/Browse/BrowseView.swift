//
//  BrowseView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/06/2021.
//

import SwiftUI

struct BrowseView: View {
    @State private var randomBandUrlString: String?

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
}

private extension BrowseView {
    var newsStatisticSection: some View {
        Section(content: {
            NavigationLink(destination: NewsArchivesView()) {
                Label("News archives", systemImage: "newspaper.fill")
            }

            NavigationLink(destination: {
                if #available(iOS 16, *) {
                    StatsView()
                } else {
                    Text("This page requires iOS 16 or above.")
                }
            }, label: {
                Label("Statistics", systemImage: "chart.pie.fill")
            })
        }, header: {
            Text("News & statistics")
        })
    }

    var topOfSection: some View {
        Section(content: {
            NavigationLink(destination: TopBandsView()) {
                Label("Top 100 bands", systemImage: "person.3.fill")
            }

            NavigationLink(destination: TopAlbumsView()) {
                Label("Top 100 albums", systemImage: "opticaldisc")
            }

            NavigationLink(destination: TopMembersView()) {
                Label("Top 100 members", systemImage: "person.fill")
            }
        }, header: {
            Text("Top of Metal Archives")
        })
    }

    var bandsSection: some View {
        Section(content: {
            NavigationLink(destination: AlphabetView(mode: .bands)) {
                Label("Alphabetical", systemImage: "abc")
            }

            NavigationLink(destination: CountryListView(mode: .bands)) {
                Label("Country", systemImage: "globe")
            }

            NavigationLink(destination: GenreListView()) {
                Label("Genre", systemImage: "guitars.fill")
            }
        }, header: {
            Text("Bands")
        })
    }

    var labelsSection: some View {
        Section(content: {
            NavigationLink(destination: AlphabetView(mode: .labels)) {
                Label("Alphabetical", systemImage: "abc")
            }

            NavigationLink(destination: CountryListView(mode: .labels)) {
                Label("Country", systemImage: "globe")
            }
        }, header: {
            Text("Labels")
        })
    }

    var ripSection: some View {
        Section(content: {
            NavigationLink(destination: DeceasedArtistsView()) {
                Label("Deceased artists", systemImage: "staroflife.fill")
            }
        }, header: {
            Text("R.I.P")
        })
    }

    var randomSection: some View {
        Section(content: {
            let bandView = BandView(bandUrlString: randomBandUrlString ?? "")
            NavigationLink(destination: bandView) {
                Label("Random band", systemImage: "questionmark")
            }
        }, header: {
            Text("Random")
        })
    }
}

#Preview {
    BrowseView()
        .environment(\.colorScheme, .dark)
}
