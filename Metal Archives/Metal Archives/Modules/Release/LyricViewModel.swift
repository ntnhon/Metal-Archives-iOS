//
//  LyricViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 12/10/2022.
//

import Combine
import Kanna

final class LyricViewModel: ObservableObject {
    @Published private(set) var lyricFetchable = FetchableObject<String>.waiting
    private let apiService: APIServiceProtocol
    let song: Song

    var fetchedLyric: String? {
        if case let .fetched(lyric) = lyricFetchable {
            return lyric
        }
        return nil
    }

    init(apiService: APIServiceProtocol, song: Song) {
        self.apiService = apiService
        self.song = song
    }

    @MainActor
    func fetchLyric() async {
        do {
            lyricFetchable = .fetching
            let urlString = "https://www.metal-archives.com/release/ajax-view-lyrics/id/\(song.lyricId ?? "")"
            let lyric = try await apiService.getString(for: urlString)
            let htmlDoc = try Kanna.HTML(html: lyric, encoding: .utf8)
            lyricFetchable = .fetched(htmlDoc.text ?? "")
        } catch {
            lyricFetchable = .error(error)
        }
    }
}
