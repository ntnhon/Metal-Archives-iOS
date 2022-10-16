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
            NavigationLink(destination: Text("News archives")) {
                HStack {
                    Image(systemName: "newspaper.fill")
                        .foregroundColor(preferences.theme.primaryColor)
                    Text("News archives")
                }
            }

            NavigationLink(destination: Text("Stats")) {
                HStack {
                    Image(systemName: "chart.pie.fill")
                        .foregroundColor(preferences.theme.primaryColor)
                    Text("Statistics")
                }
            }
        }
    }

    private var topOfSection: some View {
        Section(content: {
            view(for: GroupedTopCategory.bands)
            view(for: GroupedTopCategory.albums)
            view(for: GroupedTopCategory.members)
        }, header: {
            Text("Top of Metal Archives")
        })
    }

    @ViewBuilder
    private func view(for groupedCategory: GroupedTopCategory) -> some View {
        List([groupedCategory], children: \.subCategories) { category in
            if category.subCategories == nil {
                NavigationLink(destination: {
                    destination(for: category.category)
                }, label: {
                    view(for: category.category)
                })
            } else {
                view(for: category.category)
            }
        }
    }

    @ViewBuilder
    private func view(for category: TopCategory) -> some View {
        if let icon = category.icon {
            Label(category.title, systemImage: icon)
        } else {
            Text(category.title)
        }
    }

    @ViewBuilder
    private func destination(for category: TopCategory) -> some View {
        switch category {
        case .bandsByReleases:
            TopBandsView(apiService: apiService, category: .releases)
        case .bandsByFullLengths:
            TopBandsView(apiService: apiService, category: .fullLengths)
        case .bandsByReviews:
            TopBandsView(apiService: apiService, category: .reviews)
        case .albumsByReviews:
            TopAlbumsView(apiService: apiService, category: .reviews)
        case .albumsByMostOwned:
            TopAlbumsView(apiService: apiService, category: .mostOwned)
        case .albumsByMostWanted:
            TopAlbumsView(apiService: apiService, category: .mostWanted)
        case .membersBySubmittedBands:
            TopMembersView(apiService: apiService, category: .submittedBands)
        case .membersByWrittenReviews:
            TopMembersView(apiService: apiService, category: .writtenReviews)
        case .membersBySubmittedAlbums:
            TopMembersView(apiService: apiService, category: .submittedAlbums)
        case .membersByArtistsAdded:
            TopMembersView(apiService: apiService, category: .artistsAdded)
        default:
            EmptyView()
        }
    }

    private var bandsSection: some View {
        Section(header: Text("Bands")) {
            NavigationLink(destination: AlphabetView(mode: .bands)) {
                HStack {
                    Image(systemName: "abc")
                        .foregroundColor(preferences.theme.primaryColor)
                    Text("Alphabetical")
                }
            }

            NavigationLink(destination: CountryListView(mode: .bands)) {
                HStack {
                    Image(systemName: "globe")
                        .foregroundColor(preferences.theme.primaryColor)
                    Text("Country")
                }
            }

            NavigationLink(destination: GenreListView()) {
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
            NavigationLink(destination: AlphabetView(mode: .labels)) {
                HStack {
                    Image(systemName: "abc")
                        .foregroundColor(preferences.theme.primaryColor)
                    Text("Alphabetical")
                }
            }

            NavigationLink(destination: CountryListView(mode: .labels)) {
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
            NavigationLink(destination: Text("RIP")) {
                HStack {
                    Image(systemName: "staroflife.fill")
                        .foregroundColor(preferences.theme.primaryColor)
                    Text("Deceased artists")
                }
            }
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
