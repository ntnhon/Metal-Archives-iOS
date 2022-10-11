//
//  TracklistView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 11/10/2022.
//

import SwiftUI

struct TracklistView: View {
    let elements: [ReleaseElement]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(0...elements.count - 1, id: \.self) { index in
                switch elements[index] {
                case .song(let song):
                    SongView(song: song)
                    Divider()

                case .disc(let title):
                    discOrSideView(title: title, isFirstElement: index == 0)
                    Divider()

                case .side(let title):
                    discOrSideView(title: title, isFirstElement: index == 0)
                    Divider()

                case .length(let length):
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
