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
            Section(header: Text("Song")) {
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
            }

            Section(header: Text("Band")) {
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
            }

            Section(header: Text("Release")) {
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
            }

            Section {
                Button(action: {}, label: {
                    Text("SEARCH")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                })
            }
            .listRowBackground(Color.accentColor)
        }
        .tint(preferences.theme.primaryColor)
        .navigationBarTitle("Advanced search songs", displayMode: .large)
    }
}

struct AdvancedSearchSongsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AdvancedSearchSongsView()
        }
        .environment(\.colorScheme, .dark)
        .environmentObject(Preferences())
    }
}
