//
//  SearchView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/06/2021.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var type = SimpleSearchType.bandName
    @State private var term = ""
    @State private var isShowingResults = false
    @State private var isShowingClearHistoryConfirmation = false
    let apiService: APIServiceProtocol

    var body: some View {
        ScrollView {
            VStack {
                NavigationLink(isActive: $isShowingResults,
                               destination: searchResultView,
                               label: emptyView)
                searchBar
                history
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
        .task { await viewModel.fetchEntries() }
    }

    private var searchBar: some View {
        VStack {
            SwiftUISearchBar(term: $term, placeholder: type.placeholder) {
                Task {
                    try await viewModel.datasource.upsertQueryEntry(term, type: type)
                }
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

                Button(action: {
                    isShowingClearHistoryConfirmation.toggle()
                }, label: {
                    Text("Clear history")
                })
            }
            .padding(.horizontal)
            .alert(
                "Clear search history?",
                isPresented: $isShowingClearHistoryConfirmation,
                actions: {
                    Button("Yes, clear search history", action: viewModel.removeAllEntries)
                    Button("Cancel", role: .cancel) {}
                },
                message: {
                    Text("Please confirm")
                })
        }
    }

    @ViewBuilder
    private func searchResultView() -> some View {
        switch type {
        case .bandName:
            let manager = BandSimpleSearchResultPageManager(apiService: apiService, query: term)
            SearchResultsView(viewModel: .init(apiService: apiService,
                                               manager: manager,
                                               query: term,
                                               datasource: viewModel.datasource))
        case .musicGenre:
            let manager = MusicGenreSimpleSearchResultPageManager(apiService: apiService, query: term)
            SearchResultsView(viewModel: .init(apiService: apiService,
                                               manager: manager,
                                               query: term,
                                               datasource: viewModel.datasource))
        case .lyricalThemes:
            let manager = LyricalSimpleSearchResultPageManager(apiService: apiService, query: term)
            SearchResultsView(viewModel: .init(apiService: apiService,
                                               manager: manager,
                                               query: term,
                                               datasource: viewModel.datasource))
        case .albumTitle:
            let manager = ReleaseSimpleSearchResultPageManager(apiService: apiService, query: term)
            SearchResultsView(viewModel: .init(apiService: apiService,
                                               manager: manager,
                                               query: term,
                                               datasource: viewModel.datasource))
        case .songTitle:
            let manager = SongSimpleSearchResultPageManager(apiService: apiService, query: term)
            SearchResultsView(viewModel: .init(apiService: apiService,
                                               manager: manager,
                                               query: term,
                                               datasource: viewModel.datasource))
        case .label:
            let manager = LabelSimpleSearchResultPageManager(apiService: apiService, query: term)
            SearchResultsView(viewModel: .init(apiService: apiService,
                                               manager: manager,
                                               query: term,
                                               datasource: viewModel.datasource))
        case .artist:
            let manager = ArtistSimpleSearchResultPageManager(apiService: apiService, query: term)
            SearchResultsView(viewModel: .init(apiService: apiService,
                                               manager: manager,
                                               query: term,
                                               datasource: viewModel.datasource))
        case .user:
            let manager = UserSimpleSearchResultPageManager(apiService: apiService, query: term)
            SearchResultsView(viewModel: .init(apiService: apiService,
                                               manager: manager,
                                               query: term,
                                               datasource: viewModel.datasource))
        }
    }

    private func emptyView() -> some View {
        EmptyView()
    }

    @ViewBuilder
    private var history: some View {
        if viewModel.isLoading {
            ProgressView()
        } else {
            ForEach(viewModel.entries, id: \.hashValue) { entry in
                Text(String(describing: entry))
            }
        }
    }
}
