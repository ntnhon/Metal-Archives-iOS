//
//  ArtistViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 30/07/2022.
//

import Combine

final class ArtistViewModel: ObservableObject {
//    deinit { print("\(Self.self) of \(urlString) is deallocated") }
    @Published private(set) var artistFetchable: FetchableObject<Artist> = .fetching
    @Published private(set) var biographyFetchable: FetchableObject<String?> = .fetching

    private let apiService: APIServiceProtocol
    private let urlString: String

    init(apiService: APIServiceProtocol, urlString: String) {
        self.apiService = apiService
        self.urlString = urlString
    }

    @MainActor
    func fetchArtist() async {
        if case .fetched = artistFetchable { return }
        do {
            artistFetchable = .fetching
            let artist = try await apiService.request(forType: Artist.self, urlString: urlString)
            artistFetchable = .fetched(artist)
        } catch {
            artistFetchable = .error(error)
        }
    }

    @MainActor
    func fetchBiography() async {
        if case .fetched = biographyFetchable { return }
        guard let id = urlString.components(separatedBy: "/").last else { return }
        do {
            biographyFetchable = .fetching
            let urlString = "https://www.metal-archives.com/artist/read-more/id/\(id)"
            let biography = try await apiService.getString(for: urlString, inHtmlFormat: false)
            print(biography)
            biographyFetchable = .fetched(biography)
        } catch {
            biographyFetchable = .error(error)
        }
    }
}
