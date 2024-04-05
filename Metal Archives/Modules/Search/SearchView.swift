//
//  SearchView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/06/2021.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var preferences: Preferences
    @StateObject private var viewModel = SearchViewModel()
    @State private var type = SimpleSearchType.bandName
    @State private var term = ""
    @State private var isShowingResults = false
    @State private var isShowingClearHistoryConfirmation = false
    @State private var detail: Detail?

    var body: some View {
        ScrollView {
            VStack {
                NavigationLink(isActive: $isShowingResults,
                               destination: searchResultView,
                               label: EmptyView.init)

                DetailView(detail: $detail)

                searchBar
                history
                    .padding(.horizontal)
            }
        }
        .navigationTitle(type.navigationTitle)
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $term, prompt: type.placeholder)
        .onSubmit(of: .search, search)
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
                        Label(type.title, systemImage: type.imageName)
                        Image(systemName: "chevron.down")
                            .imageScale(.small)
                    }
                    .padding(8)
                    .background(preferences.theme.primaryColor)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
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
                    Button("Yes, clear search history") {
                        viewModel.removeAllEntries()
                    }
                    Button("Cancel", role: .cancel) {}
                },
                message: {
                    Text("Please confirm")
                }
            )
        }
    }

    @ViewBuilder
    private func searchResultView() -> some View {
        switch type {
        case .bandName:
            let manager = BandSimpleSearchResultPageManager(query: term)
            SearchResultsView(viewModel: .init(manager: manager,
                                               query: term,
                                               datasource: viewModel.datasource))
        case .musicGenre:
            let manager = MusicGenreSimpleSearchResultPageManager(query: term)
            SearchResultsView(viewModel: .init(manager: manager,
                                               query: term,
                                               datasource: viewModel.datasource))
        case .lyricalThemes:
            let manager = LyricalSimpleSearchResultPageManager(query: term)
            SearchResultsView(viewModel: .init(manager: manager,
                                               query: term,
                                               datasource: viewModel.datasource))
        case .albumTitle:
            let manager = ReleaseSimpleSearchResultPageManager(query: term)
            SearchResultsView(viewModel: .init(manager: manager,
                                               query: term,
                                               datasource: viewModel.datasource))
        case .songTitle:
            let manager = SongSimpleSearchResultPageManager(query: term)
            SearchResultsView(viewModel: .init(manager: manager,
                                               query: term,
                                               datasource: viewModel.datasource))
        case .label:
            let manager = LabelSimpleSearchResultPageManager(query: term)
            SearchResultsView(viewModel: .init(manager: manager,
                                               query: term,
                                               datasource: viewModel.datasource))
        case .artist:
            let manager = ArtistSimpleSearchResultPageManager(query: term)
            SearchResultsView(viewModel: .init(manager: manager,
                                               query: term,
                                               datasource: viewModel.datasource))
        case .user:
            let manager = UserSimpleSearchResultPageManager(query: term)
            SearchResultsView(viewModel: .init(manager: manager,
                                               query: term,
                                               datasource: viewModel.datasource))
        }
    }

    private func search() {
        Task {
            do {
                try await viewModel.datasource.upsertQueryEntry(term, type: type)
            } catch {
                // TODO: Handle this
                print(error)
            }
        }
        isShowingResults.toggle()
    }

    @ViewBuilder
    private var history: some View {
        if viewModel.isLoading, viewModel.entries.isEmpty {
            MALoadingIndicator()
        } else {
            if viewModel.entries.isEmpty {
                Text("Empty search history")
                    .font(.callout.italic())
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text("Recent searches")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                ForEach(viewModel.entries, id: \.hashValue) { entry in
                    if entry.type.isQueryEntry {
                        QuerySearchEntryView(entry: entry) {
                            viewModel.remove(entry: entry)
                        }
                        .onTapGesture {
                            term = entry.primaryDetail
                            type = entry.type.toSimpleSearchType()
                            search()
                        }
                    } else {
                        EntitySearchEntryView(entry: entry) {
                            viewModel.remove(entry: entry)
                        }
                        .onTapGesture {
                            guard let urlString = entry.secondaryDetail else { return }
                            switch entry.type {
                            case .band:
                                detail = .band(urlString)
                            case .release:
                                detail = .release(urlString)
                            case .artist:
                                detail = .artist(urlString)
                            case .label:
                                detail = .label(urlString)
                            case .user:
                                detail = .user(urlString)
                            default:
                                return
                            }
                            Task {
                                do {
                                    try await viewModel.datasource.upsert(entry)
                                } catch {
                                    // TODO: Handle this
                                    print(error)
                                }
                            }
                        }
                    }
                    Divider()
                }
                .animation(.default, value: viewModel.entries.count)
            }
        }
    }
}

private struct QuerySearchEntryView: View {
    @EnvironmentObject private var preferences: Preferences
    let entry: SearchEntry
    let onRemove: () -> Void

    var body: some View {
        HStack {
            if let imageName = entry.type.placeholderSystemImageName {
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(preferences.theme.secondaryColor)
                    .frame(width: 64, height: 64)
            }

            Label("\"\(entry.primaryDetail)\"", systemImage: "magnifyingglass")
                .font(.body.italic())

            Spacer()

            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
        .background(Color.gray.opacity(0.001))
        .containerShape(Rectangle())
    }
}

private struct EntitySearchEntryView: View {
    @EnvironmentObject private var preferences: Preferences
    let entry: SearchEntry
    let onRemove: () -> Void

    var body: some View {
        HStack {
            if let thumbnailInfo = entry.thumbnailInfo {
                ThumbnailView(thumbnailInfo: thumbnailInfo,
                              photoDescription: entry.primaryDetail)
                    .font(.largeTitle)
                    .foregroundColor(preferences.theme.secondaryColor)
                    .frame(width: 64, height: 64)
            } else if entry.type == .user {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(preferences.theme.secondaryColor)
                    .frame(width: 64, height: 64)
            }

            Text(entry.primaryDetail)
                .fontWeight(.semibold)
                .foregroundColor(preferences.theme.primaryColor)

            Spacer()

            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
        .background(Color.gray.opacity(0.001))
        .containerShape(Rectangle())
    }
}
