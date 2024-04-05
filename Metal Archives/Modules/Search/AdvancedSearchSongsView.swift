//
//  AdvancedSearchSongsView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/06/2021.
//

import SwiftUI

struct AdvancedSearchSongsView: View {
    @EnvironmentObject private var preferences: Preferences
    @State private var songTitle = ""
    @State private var exactMatchSongTitle = false
    @State private var bandName = ""
    @State private var exactMatchBandName = false
    @State private var releaseTitle = ""
    @State private var exactMatchReleaseTitle = false
    @State private var lyrics = ""
    @State private var genre = ""
    @StateObject private var releaseTypeSet = ReleaseTypeSet()

    var body: some View {
        Form {
            Section(content: {
                HStack {
                    Text("Title")
                    TextField("", text: $songTitle)
                        .textFieldStyle(.roundedBorder)
                }

                Toggle("Exact match song title", isOn: $exactMatchSongTitle)

                HStack {
                    Text("Lyrics")
                    TextField("", text: $lyrics)
                        .textFieldStyle(.roundedBorder)
                }
            }, header: {
                Text("Song")
            })

            Section(content: {
                HStack {
                    Text("Name")
                    TextField("", text: $bandName)
                        .textFieldStyle(.roundedBorder)
                }

                Toggle("Exact match band name", isOn: $exactMatchBandName)

                HStack {
                    Text("Genre")
                    TextField("", text: $genre)
                        .textFieldStyle(.roundedBorder)
                }
            }, header: {
                Text("Band")
            })

            Section(content: {
                HStack {
                    Text("Title")
                    TextField("", text: $releaseTitle)
                        .textFieldStyle(.roundedBorder)
                }

                Toggle("Exact match release title", isOn: $exactMatchReleaseTitle)

                NavigationLink(destination: ReleaseTypeListView(releaseTypeSet: releaseTypeSet)) {
                    HStack {
                        Text("Release type")
                        Spacer()
                        Text(releaseTypeSet.detail)
                            .font(.callout)
                            .foregroundColor(.gray)
                    }
                }
            }, header: {
                Text("Release")
            })

            Section {
                NavigationLink(
                    destination: {
                        AdvancedSearchResultView(viewModel: .init(manager: makePageManager()))
                    },
                    label: {
                        Text("SEARCH")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                )
            }
            .listRowBackground(Color.accentColor)
        }
        .tint(preferences.theme.primaryColor)
        .navigationBarTitle("Advanced search songs", displayMode: .large)
    }

    private func makePageManager() -> SongAdvancedSearchResultPageManager {
        let params = SongAdvancedSearchResultParams()
        params.songTitle = songTitle
        params.exactMatchSongTitle = exactMatchSongTitle
        params.bandName = bandName
        params.exactMatchBandName = exactMatchBandName
        params.releaseTitle = releaseTitle
        params.exactMatchReleaseTitle = exactMatchReleaseTitle
        params.lyrics = lyrics
        params.genre = genre
        params.releaseTypes = releaseTypeSet.choices
        return .init(params: params)
    }
}

#Preview {
    NavigationView {
        AdvancedSearchSongsView()
    }
    .environment(\.colorScheme, .dark)
    .environmentObject(Preferences())
}
