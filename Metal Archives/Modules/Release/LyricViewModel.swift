//
//  LyricViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 12/10/2022.
//

import Combine
import Factory

@MainActor
final class LyricViewModel: ObservableObject {
    @Published private(set) var lyricFetchable = FetchableObject<String>.fetching
    private let apiService = resolve(\DependenciesContainer.apiService)
    let song: Song

    var fetchedLyric: String? {
        if case let .fetched(lyric) = lyricFetchable {
            return lyric
        }
        return nil
    }

    init(song: Song) {
        self.song = song
    }

    func fetchLyric() async {
        do {
            guard let lyricId = song.lyricId else {
                throw MAError.songHasNoLyric(title: song.title)
            }
            lyricFetchable = .fetching
            let urlString = "https://www.metal-archives.com/release/ajax-view-lyrics/id/\(lyricId)"
            guard let lyric = try await apiService.getString(for: urlString, inHtmlFormat: false) else {
                throw MAError.failedToFetchLyric(lyricId: lyricId)
            }
            lyricFetchable = .fetched(lyric)
        } catch {
            lyricFetchable = .error(error)
        }
    }
}
