//
//  AdvancedSearchSongsView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/06/2021.
//

import SwiftUI

struct AdvancedSearchSongsView: View {
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
        List {
            TextField("Song title", text: $songTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Toggle("Exact match song title", isOn: $exactMatchSongTitle)

            Section {
                TextField("Band name", text: $bandName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Toggle("Exact match band name", isOn: $exactMatchBandName)
            }

            Section {
                TextField("Release title", text: $releaseTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Toggle("Exact match release title", isOn: $exactMatchReleaseTitle)
            }

            Section {
                TextField("Lyrics", text: $lyrics)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Genre", text: $genre)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                NavigationLink(destination: ReleaseTypeListView(releaseTypeSet: releaseTypeSet)) {
                    HStack {
                        Text("Release type")
                        Spacer()
                        Text(releaseTypeSet.detailString)
                            .font(.callout)
                            .foregroundColor(.gray)
                    }
                }
            }

            Section {
                HStack {
                    Spacer()
                    Button(action: {}, label: {
                        Text("SEARCH")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    })
                    Spacer()
                }
            }
            .listRowBackground(Color.accentColor)
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle("Advanced search songs", displayMode: .inline)
    }
}

struct AdvancedSearchSongsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AdvancedSearchSongsView()
        }
    }
}
