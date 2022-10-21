//
//  SimilarArtistsViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 15/10/2022.
//

import Foundation

final class SimilarArtistsViewModel: ObservableObject {
    @Published private(set) var similarArtistsFetchable: FetchableObject<[BandSimilar]> = .fetching

    let apiService: APIServiceProtocol
    let band: Band

    init(apiService: APIServiceProtocol, band: Band) {
        self.apiService = apiService
        self.band = band
    }

    @MainActor
    func refresh(force: Bool) async {
        if !force, case .fetched = similarArtistsFetchable { return }
        do {
            similarArtistsFetchable = .fetching
            // swiftlint:disable:next line_length
            let urlString = "https://www.metal-archives.com/band/ajax-recommendations/id/\(band.id)/showMoreSimilar/1"
            let similarArtists = try await apiService.request(forType: BandSimilarArray.self,
                                                              urlString: urlString)
            similarArtistsFetchable = .fetched(similarArtists.content)
        } catch {
            similarArtistsFetchable = .error(error)
        }
    }
}
