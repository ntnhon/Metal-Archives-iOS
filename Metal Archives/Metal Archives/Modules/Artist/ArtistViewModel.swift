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
}
