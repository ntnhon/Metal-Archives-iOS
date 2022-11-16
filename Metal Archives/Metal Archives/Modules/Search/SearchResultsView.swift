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
        if let result = result as? BandSimpleSearchResult {
            BandSimpleSearchResultView(result: result)
                .onTapGesture {
                    selectedBandUrl = result.band.thumbnailInfo.urlString
                }
        } else if let result = result as? MusicGenreSimpleSearchResult {
            BandSimpleSearchResultView(result: result)
                .onTapGesture {
                    selectedBandUrl = result.band.thumbnailInfo.urlString
                }
        } else if let result = result as? LyricalSimpleSearchResult {
            LyricalSimpleSearchResultView(result: result)
                .onTapGesture {
                    selectedBandUrl = result.band.thumbnailInfo.urlString
                }
        } else if let result = result as? ReleaseSimpleSearchResult {
            ReleaseSimpleSearchResultView(result: result,
                                          onSelectRelease: { url in selectedReleaseUrl = url },
                                          onSelectBand: { url in selectedBandUrl = url })
        } else if let result = result as? SongSimpleSearchResult {
            SongSimpleSearchResultView(result: result,
                                       onSelectRelease: { url in selectedReleaseUrl = url },
                                       onSelectBand: { url in selectedBandUrl = url })
        } else if let result = result as? LabelSimpleSearchResult {
            LabelSimpleSearchResultView(result: result)
                .onTapGesture {
                    selectedLabelUrl = result.label.thumbnailInfo?.urlString
                }
        } else if let result = result as? ArtistSimpleSearchResult {
            ArtistSimpleSearchResultView(result: result,
                                         onSelectArtist: { url in selectedArtistUrl = url },
                                         onSelectBand: { url in selectedBandUrl = url })
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
    let result: BandSimpleSearchResult

    var body: some View {
        HStack {
            ThumbnailView(thumbnailInfo: result.band.thumbnailInfo,
                          photoDescription: result.band.name)
            .font(.largeTitle)
            .foregroundColor(preferences.theme.secondaryColor)
            .frame(width: 64, height: 64)

            VStack(alignment: .leading) {
                if let note = result.note {
                    Text(result.band.name)
                        .fontWeight(.bold)
                        .foregroundColor(preferences.theme.primaryColor) +
                    Text(" (\(note))")
                } else {
                    Text(result.band.name)
                        .fontWeight(.bold)
                        .foregroundColor(preferences.theme.primaryColor)
                }

                Text(result.country.nameAndFlag)
                    .foregroundColor(preferences.theme.secondaryColor)

                Text(result.genre)
                    .font(.callout)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .contentShape(Rectangle())
    }
}

private struct LyricalSimpleSearchResultView: View {
    @EnvironmentObject private var preferences: Preferences
    let result: LyricalSimpleSearchResult

    var body: some View {
        HStack {
            ThumbnailView(thumbnailInfo: result.band.thumbnailInfo,
                          photoDescription: result.band.name)
            .font(.largeTitle)
            .foregroundColor(preferences.theme.secondaryColor)
            .frame(width: 64, height: 64)

            VStack(alignment: .leading) {
                if let note = result.note {
                    Text(result.band.name)
                        .fontWeight(.bold)
                        .foregroundColor(preferences.theme.primaryColor) +
                    Text(" (\(note))")
                } else {
                    Text(result.band.name)
                        .fontWeight(.bold)
                        .foregroundColor(preferences.theme.primaryColor)
                }

                Text(result.country.nameAndFlag)
                    .foregroundColor(preferences.theme.secondaryColor)

                Text(result.genre)
                    .font(.callout)

                Text(result.lyricalThemes)
                    .font(.callout)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .contentShape(Rectangle())
    }
}

private struct ReleaseSimpleSearchResultView: View {
    @EnvironmentObject private var preferences: Preferences
    @State private var isShowingConfirmationDialog = false
    let result: ReleaseSimpleSearchResult
    let onSelectRelease: (String) -> Void
    let onSelectBand: (String) -> Void

    var body: some View {
        HStack {
            ThumbnailView(thumbnailInfo: result.release.thumbnailInfo,
                          photoDescription: result.release.title)
            .font(.largeTitle)
            .foregroundColor(preferences.theme.secondaryColor)
            .frame(width: 64, height: 64)

            VStack(alignment: .leading) {
                Text(result.release.title)
                    .fontWeight(.bold)
                    .foregroundColor(preferences.theme.primaryColor)

                Text(result.band.name)
                    .fontWeight(.semibold)
                    .foregroundColor(preferences.theme.secondaryColor)

                Text(result.releaseType.description)
                    .font(.callout)
                    .fontWeight(.semibold) +
                Text(" • ")
                    .font(.callout) +
                Text(result.date)
                    .font(.callout)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isShowingConfirmationDialog.toggle()
        }
        .confirmationDialog(
            "",
            isPresented: $isShowingConfirmationDialog,
            actions: {
                Button(action: {
                    onSelectRelease(result.release.thumbnailInfo.urlString)
                }, label: {
                    Text("View release's detail")
                })

                Button(action: {
                    onSelectBand(result.band.thumbnailInfo.urlString)
                }, label: {
                    Text("View band's detail")
                })
            },
            message: {
                Text("\"\(result.release.title)\" by \(result.band.name)")
            })
    }
}

private struct SongSimpleSearchResultView: View {
    @EnvironmentObject private var preferences: Preferences
    @State private var isShowingConfirmationDialog = false
    let result: SongSimpleSearchResult
    let onSelectRelease: (String) -> Void
    let onSelectBand: (String) -> Void

    var body: some View {
        HStack {
            ThumbnailView(thumbnailInfo: result.release.thumbnailInfo,
                          photoDescription: result.release.title)
            .font(.largeTitle)
            .foregroundColor(preferences.theme.secondaryColor)
            .frame(width: 64, height: 64)

            VStack(alignment: .leading) {
                Text(result.release.title)
                    .fontWeight(.bold)
                    .foregroundColor(preferences.theme.primaryColor)

                Text(result.band.name)
                    .fontWeight(.semibold)
                    .foregroundColor(preferences.theme.secondaryColor)

                Text(result.releaseType.description)
                    .font(.callout)
                    .fontWeight(.semibold)

                Text(result.title)
                    .font(.callout)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isShowingConfirmationDialog.toggle()
        }
        .confirmationDialog(
            "",
            isPresented: $isShowingConfirmationDialog,
            actions: {
                Button(action: {
                    onSelectRelease(result.release.thumbnailInfo.urlString)
                }, label: {
                    Text("View release's detail")
                })

                Button(action: {
                    onSelectBand(result.band.thumbnailInfo.urlString)
                }, label: {
                    Text("View band's detail")
                })
            },
            message: {
                Text("\"\(result.release.title)\" by \(result.band.name)")
            })
    }
}

private struct LabelSimpleSearchResultView: View {
    @EnvironmentObject private var preferences: Preferences
    let result: LabelSimpleSearchResult

    var body: some View {
        HStack {
            if let thumbnailInfo = result.label.thumbnailInfo {
                ThumbnailView(thumbnailInfo: thumbnailInfo,
                              photoDescription: result.label.name)
                .font(.largeTitle)
                .foregroundColor(preferences.theme.secondaryColor)
                .frame(width: 64, height: 64)
            }

            VStack(alignment: .leading) {
                if let note = result.note {
                    Text(result.label.name)
                        .fontWeight(.bold)
                        .foregroundColor(preferences.theme.primaryColor) +
                    Text(" (\(note))")
                } else {
                    Text(result.label.name)
                        .fontWeight(.bold)
                        .foregroundColor(preferences.theme.primaryColor)
                }

                Text(result.country.nameAndFlag)
                    .foregroundColor(preferences.theme.secondaryColor)

                Text(result.specialisation)
                    .font(.callout)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .contentShape(Rectangle())
    }
}

private struct ArtistSimpleSearchResultView: View {
    @EnvironmentObject private var preferences: Preferences
    @State private var isShowingConfirmationDialog = false
    let result: ArtistSimpleSearchResult
    let onSelectArtist: (String) -> Void
    let onSelectBand: (String) -> Void

    var body: some View {
        HStack {
            ThumbnailView(thumbnailInfo: result.artist.thumbnailInfo,
                          photoDescription: result.artist.name)
            .font(.largeTitle)
            .foregroundColor(preferences.theme.secondaryColor)
            .frame(width: 64, height: 64)

            VStack(alignment: .leading) {
                if let note = result.note {
                    Text(result.artist.name)
                        .fontWeight(.bold)
                        .foregroundColor(preferences.theme.primaryColor) +
                    Text(" (\(note))")
                } else {
                    Text(result.artist.name)
                        .fontWeight(.bold)
                        .foregroundColor(preferences.theme.primaryColor)
                }

                if !result.realName.isEmpty {
                    Text(result.realName)
                }

                Text(result.country.nameAndFlag)
                    .foregroundColor(preferences.theme.secondaryColor)

                HighlightableText(text: result.bandsString,
                                  highlights: result.bands.map { $0.name },
                                  highlightFontWeight: .bold,
                                  highlightColor: preferences.theme.secondaryColor)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isShowingConfirmationDialog.toggle()
        }
        .confirmationDialog(
            "",
            isPresented: $isShowingConfirmationDialog,
            actions: {
                Button(action: {
                    onSelectArtist(result.artist.thumbnailInfo.urlString)
                }, label: {
                    Text("View artist's detail")
                })

                ForEach(result.bands, id: \.hashValue) { band in
                    Button(action: {
                        onSelectBand(band.thumbnailInfo.urlString)
                    }, label: {
                        Text(band.name)
                    })
                }
            },
            message: {
                Text(result.artist.name)
            })
    }
}
