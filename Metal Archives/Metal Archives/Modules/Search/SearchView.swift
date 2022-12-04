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
    @State private var selectedBandUrl: String?
    @State private var selectedReleaseUrl: String?
    @State private var selectedArtistUrl: String?
    @State private var selectedLabelUrl: String?
    @State private var selectedUserUrl: String?
    let apiService: APIServiceProtocol

    var body: some View {
        let isShowingBandDetail = makeIsShowingBandDetailBinding()
        let isShowingReleaseDetail = makeIsShowingReleaseDetailBinding()
        let isShowingArtistDetail = makeIsShowingArtistDetailBinding()
        let isShowingLabelDetail = makeIsShowingLabelDetailBinding()
        let isShowingUserDetail = makeIsShowingUserDetailBinding()

        ScrollView {
            VStack {
                NavigationLink(isActive: $isShowingResults,
                               destination: searchResultView,
                               label: emptyView)

                NavigationLink(isActive: isShowingBandDetail,
                               destination: bandDetailView,
                               label: emptyView)

                NavigationLink(isActive: isShowingReleaseDetail,
                               destination: releaseDetailView,
                               label: emptyView)

                NavigationLink(isActive: isShowingArtistDetail,
                               destination: artistDetailView,
                               label: emptyView)

                NavigationLink(isActive: isShowingLabelDetail,
                               destination: labelDetailView,
                               label: emptyView)

                NavigationLink(isActive: isShowingUserDetail,
                               destination: userDetailView,
                               label: emptyView)

                searchBar
                history
                    .padding(.horizontal)
            }
        }
        .navigationTitle(type.navigationTitle)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: AdvancedSearchView(apiService: apiService)) {
                    Text("Advanced search")
                        .fontWeight(.bold)
                }
            }
        }
        .task { await viewModel.fetchEntries() }
    }

    private var searchBar: some View {
        VStack {
            SwiftUISearchBar(term: $term,
                             placeholder: type.placeholder,
                             onSubmit: search)

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

    private func search() {
        Task {
            try await viewModel.datasource.upsertQueryEntry(term, type: type)
        }
        isShowingResults.toggle()
    }

    private func makeIsShowingBandDetailBinding() -> Binding<Bool> {
        .init(get: {
            selectedBandUrl != nil
        }, set: { newValue in
            if !newValue {
                selectedBandUrl = nil
            }
        })
    }

    @ViewBuilder
    private func bandDetailView() -> some View {
        if let selectedBandUrl {
            BandView(apiService: apiService, bandUrlString: selectedBandUrl)
        } else {
            EmptyView()
        }
    }

    private func makeIsShowingReleaseDetailBinding() -> Binding<Bool> {
        .init(get: {
            selectedReleaseUrl != nil
        }, set: { newValue in
            if !newValue {
                selectedReleaseUrl = nil
            }
        })
    }

    @ViewBuilder
    private func releaseDetailView() -> some View {
        if let selectedReleaseUrl {
            ReleaseView(apiService: apiService, urlString: selectedReleaseUrl, parentRelease: nil)
        } else {
            EmptyView()
        }
    }

    private func makeIsShowingArtistDetailBinding() -> Binding<Bool> {
        .init(get: {
            selectedArtistUrl != nil
        }, set: { newValue in
            if !newValue {
                selectedArtistUrl = nil
            }
        })
    }

    @ViewBuilder
    private func artistDetailView() -> some View {
        if let selectedArtistUrl {
            ArtistView(apiService: apiService, urlString: selectedArtistUrl)
        } else {
            EmptyView()
        }
    }

    private func makeIsShowingLabelDetailBinding() -> Binding<Bool> {
        .init(get: {
            selectedLabelUrl != nil
        }, set: { newValue in
            if !newValue {
                selectedLabelUrl = nil
            }
        })
    }

    @ViewBuilder
    private func labelDetailView() -> some View {
        if let selectedLabelUrl {
            LabelView(apiService: apiService, urlString: selectedLabelUrl)
        } else {
            EmptyView()
        }
    }

    private func makeIsShowingUserDetailBinding() -> Binding<Bool> {
        .init(get: {
            selectedUserUrl != nil
        }, set: { newValue in
            if !newValue {
                selectedUserUrl = nil
            }
        })
    }

    @ViewBuilder
    private func userDetailView() -> some View {
        if let selectedUserUrl {
            UserView(apiService: apiService, urlString: selectedUserUrl)
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    private var history: some View {
        if viewModel.isLoading, viewModel.entries.isEmpty {
            ProgressView()
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
                            case .band: selectedBandUrl = urlString
                            case .release: selectedReleaseUrl = urlString
                            case .artist: selectedArtistUrl = urlString
                            case .label: selectedLabelUrl = urlString
                            case .user: selectedUserUrl = urlString
                            default: return
                            }
                            Task {
                                try await viewModel.datasource.upsert(entry)
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
