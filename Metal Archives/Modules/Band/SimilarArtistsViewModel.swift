//
//  SimilarArtistsViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 15/10/2022.
//

import Factory
import Foundation

@MainActor
final class SimilarArtistsViewModel: ObservableObject {
    @Published private(set) var similarArtistsFetchable: FetchableObject<[BandSimilar]> = .fetching

    private let apiService = resolve(\DependenciesContainer.apiService)
    let band: Band

    init(band: Band) {
        self.band = band
    }

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
