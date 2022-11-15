//
//  SearchResultsView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 15/11/2022.
//

import SwiftUI

struct SearchResultsView<T: HashableEquatablePageElement>: View {
    @StateObject var viewModel: SearchResultsViewModel<T>
    @State private var selectedBandUrl: String?
    @State private var selectedReleaseUrl: String?
    @State private var selectedArtistUrl: String?
    @State private var selectedLabelUrl: String?
    @State private var selectedUserUrl: String?

    var body: some View {
        let isShowingBandDetail = makeIsShowingBandDetailBinding()
        let isShowingReleaseDetail = makeIsShowingReleaseDetailBinding()
        let isShowingArtistDetail = makeIsShowingArtistDetailBinding()
        let isShowingLabelDetail = makeIsShowingLabelDetailBinding()
        let isShowingUserDetail = makeIsShowingUserDetailBinding()

        ZStack {
            NavigationLink(
                isActive: isShowingBandDetail,
                destination: {
                    if let selectedBandUrl {
                        BandView(apiService: viewModel.apiService, bandUrlString: selectedBandUrl)
                    } else {
                        EmptyView()
                    }},
                label: { EmptyView() })

            NavigationLink(
                isActive: isShowingReleaseDetail,
                destination: {
                    if let selectedReleaseUrl {
                        ReleaseView(apiService: viewModel.apiService,
                                    urlString: selectedReleaseUrl,
                                    parentRelease: nil)
                    } else {
                        EmptyView()
                    }},
                label: { EmptyView() })

            NavigationLink(
                isActive: isShowingArtistDetail,
                destination: {
                    if let selectedArtistUrl {
                        ArtistView(apiService: viewModel.apiService, urlString: selectedArtistUrl)
                    } else {
                        EmptyView()
                    }},
                label: { EmptyView() })

            NavigationLink(
                isActive: isShowingLabelDetail,
                destination: {
                    if let selectedLabelUrl {
                        LabelView(apiService: viewModel.apiService, urlString: selectedLabelUrl)
                    } else {
                        EmptyView()
                    }},
                label: { EmptyView() })

            NavigationLink(
                isActive: isShowingUserDetail,
                destination: {
                    if let selectedUserUrl {
                        UserView(apiService: viewModel.apiService, urlString: selectedUserUrl)
                    } else {
                        EmptyView()
                    }},
                label: { EmptyView() })

            if let error = viewModel.error {
                VStack {
                    Text(error.userFacingMessage)
                    RetryButton {
                        Task {
                            await viewModel.getMoreResults(force: true)
                        }
                    }
                }
            } else if viewModel.isLoading && viewModel.results.isEmpty {
                HornCircularLoader()
            } else if viewModel.results.isEmpty {
                NoResultsView(query: viewModel.query)
            } else {
                resultList
            }
        }
        .task {
            await viewModel.getMoreResults(force: false)
        }
    }

    @ViewBuilder
    private var resultList: some View {
        List {
            ForEach(viewModel.results, id: \.hashValue) { result in
                view(for: result)
                .task {
                    if result == viewModel.results.last {
                        await viewModel.getMoreResults(force: true)
                    }
                }

                if result == viewModel.results.last, viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("\(viewModel.manager.total) results for \"\(viewModel.query ?? "")\"")
        .navigationBarTitleDisplayMode(.large)
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

    private func makeIsShowingReleaseDetailBinding() -> Binding<Bool> {
        .init(get: {
            selectedReleaseUrl != nil
        }, set: { newValue in
            if !newValue {
                selectedReleaseUrl = nil
            }
        })
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

    private func makeIsShowingLabelDetailBinding() -> Binding<Bool> {
        .init(get: {
            selectedLabelUrl != nil
        }, set: { newValue in
            if !newValue {
                selectedLabelUrl = nil
            }
        })
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
    private func view(for result: some HashableEquatablePageElement) -> some View {
        if let band = result as? BandSimpleSearchResult {
            BandSimpleSearchResultView(band: band)
                .onTapGesture {
                    selectedBandUrl = band.band.thumbnailInfo.urlString
                }
        } else {
            EmptyView()
        }
    }
}

private struct NoResultsView: View {
    @Environment(\.dismiss) private var dismiss
    let message: String

    init(query: String?) {
        if let query {
            message = "🤕 No results found for \"\(query)\""
        } else {
            message = "🤕 No results found"
        }
    }

    var body: some View {
        VStack {
            Text(message)
                .font(.callout.italic())
                .multilineTextAlignment(.center)
            Button(action: dismiss.callAsFunction) {
                Label("Go back", systemImage: "arrowshape.turn.up.backward.2")
            }
        }
        .padding()
    }
}

private struct BandSimpleSearchResultView: View {
    @EnvironmentObject private var preferences: Preferences
    let band: BandSimpleSearchResult

    var body: some View {
        HStack {
            ThumbnailView(thumbnailInfo: band.band.thumbnailInfo,
                          photoDescription: band.band.name)
            .font(.largeTitle)
            .foregroundColor(preferences.theme.secondaryColor)
            .frame(width: 64, height: 64)

            VStack(alignment: .leading) {
                if let note = band.note {
                    Text(band.band.name)
                        .fontWeight(.bold)
                        .foregroundColor(preferences.theme.primaryColor) +
                    Text(" (\(note))")
                } else {
                    Text(band.band.name)
                        .fontWeight(.bold)
                        .foregroundColor(preferences.theme.primaryColor)
                }

                Text(band.country.nameAndFlag)
                    .foregroundColor(preferences.theme.secondaryColor)

                Text(band.genre)
                    .font(.callout)
            }

            Spacer()
        }
        .contentShape(Rectangle())
    }
}
