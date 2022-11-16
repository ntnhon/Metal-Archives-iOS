//
//  SearchView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/06/2021.
//

import SwiftUI

struct SearchView: View {
    @State private var type = SimpleSearchType.bandName
    @State private var term = ""
    @State private var isShowingResults = false
    let apiService: APIServiceProtocol

    var body: some View {
        ScrollView {
            VStack {
                NavigationLink(isActive: $isShowingResults,
                               destination: searchResultView,
                               label: emptyView)
                searchBar
                LazyVStack {
                    ForEach(0..<50, id: \.self) { index in
                        Text("#\(index)")
                    }
                }
            }
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: AdvancedSearchView()) {
                    Text("Advanced search")
                        .fontWeight(.bold)
                }
            }
        }
    }

    private var searchBar: some View {
        VStack {
            SwiftUISearchBar(term: $term, placeholder: type.placeholder) {
                isShowingResults.toggle()
            }

            HStack {
                Menu(content: {
                    ForEach(SimpleSearchType.allCases, id: \.self) { type in
                        Button(action: {
                            self.type = type
                        }, label: {
                            Label(title: {
                                Text(type.title)
                            }, icon: {
                                if self.type == type {
                                    Image(systemName: "checkmark")
                                }
                            })
                        })
                    }
                }, label: {
                    HStack {
                        Text("Search by: \(type.title)")
                        Image(systemName: "chevron.down")
                            .imageScale(.small)
                    }
                    .foregroundColor(.secondary)
                })
                .transaction { transaction in
                    transaction.animation = nil
                }
                Spacer()
            }
            .padding(.horizontal)
        }
    }

    @ViewBuilder
    private func searchResultView() -> some View {
        switch type {
        case .bandName:
            let manager = BandSimpleSearchResultPageManager(apiService: apiService, query: term)
            SearchResultsView(viewModel: .init(apiService: apiService, manager: manager, query: term))
        case .musicGenre:
            let manager = MusicGenreSimpleSearchResultPageManager(apiService: apiService, query: term)
            SearchResultsView(viewModel: .init(apiService: apiService, manager: manager, query: term))
        case .lyricalThemes:
            let manager = LyricalSimpleSearchResultPageManager(apiService: apiService, query: term)
            SearchResultsView(viewModel: .init(apiService: apiService, manager: manager, query: term))
        case .albumTitle:
            let manager = ReleaseSimpleSearchResultPageManager(apiService: apiService, query: term)
            SearchResultsView(viewModel: .init(apiService: apiService, manager: manager, query: term))
        case .songTitle:
            let manager = SongSimpleSearchResultPageManager(apiService: apiService, query: term)
            SearchResultsView(viewModel: .init(apiService: apiService, manager: manager, query: term))
        case .label:
            let manager = LabelSimpleSearchResultPageManager(apiService: apiService, query: term)
            SearchResultsView(viewModel: .init(apiService: apiService, manager: manager, query: term))
        default:
            let manager = BandSimpleSearchResultPageManager(apiService: apiService, query: term)
            SearchResultsView(viewModel: .init(apiService: apiService, manager: manager, query: term))
        }
    }

    private func emptyView() -> some View {
        EmptyView()
    }
}
