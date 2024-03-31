//
//  TracklistView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 11/10/2022.
//

import SwiftUI

struct TracklistView: View {
    @Environment(\.toastMessage) private var toastMessage
    @State private var selectedSongWithLyric: Song?
    let elements: [ReleaseElement]

    var body: some View {
        let showingLyric = Binding<Bool>(get: {
            selectedSongWithLyric != nil
        }, set: { newValue in
            if !newValue {
                selectedSongWithLyric = nil
            }
        })

        VStack(alignment: .leading, spacing: 8) {
            ForEach(0 ... elements.count - 1, id: \.self) { index in
                switch elements[index] {
                case let .song(song):
                    SongView(song: song)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if song.lyricId != nil {
                                selectedSongWithLyric = song
                            } else if song.isInstrumental {
                                toastMessage.wrappedValue = "This is an instrumental song"
                            } else {
                                toastMessage.wrappedValue = "This song has no lyric yet"
                            }
                        }
                    Divider()

                case let .disc(title):
                    discOrSideView(title: title, isFirstElement: index == 0)
                    Divider()

                case let .side(title):
                    discOrSideView(title: title, isFirstElement: index == 0)
                    Divider()

                case let .length(length):
                    HStack {
                        Text(length)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        Image(systemName: "doc.plaintext")
                            .opacity(0)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical)
        .sheet(isPresented: showingLyric) {
            if let selectedSongWithLyric {
                LyricView(song: selectedSongWithLyric)
            }
        }
    }

    private func discOrSideView(title: String, isFirstElement: Bool) -> some View {
        Text(title)
            .font(.headline)
            .fontWeight(.bold)
            .padding(.top, isFirstElement ? 0 : 24)
    }
}

private struct SongView: View {
    @EnvironmentObject private var preferences: Preferences
    let song: Song

    var body: some View {
        HStack(alignment: .top) {
            Text(song.number)
            Text(song.title)
            Spacer()
            Text(song.length)
            if song.isInstrumental {
                Image(systemName: "music.quarternote.3")
                    .foregroundColor(preferences.theme.primaryColor)
            } else if song.lyricId != nil {
                Image(systemName: "doc.plaintext.fill")
                    .foregroundColor(preferences.theme.primaryColor)
            } else {
                Image(systemName: "doc.plaintext")
                    .opacity(0)
            }
        }
    }
}
