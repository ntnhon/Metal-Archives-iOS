//
//  BandViewModel.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/06/2021.
//

import Factory
import SwiftUI

struct BandMetadata {
    let band: Band
    let discography: Discography
    let readMore: String?
}

@MainActor
final class BandViewModel: ObservableObject {
//    deinit { print("\(Self.self) of \(bandUrlString) is deallocated") }

    @Published private(set) var bandMetadataFetchable: FetchableObject<BandMetadata> = .fetching
    @Published private(set) var relatedLinksFetchable: FetchableObject<[RelatedLink]> = .fetching
    private(set) var band: Band?
    private let bandUrlString: String
    private let apiService = resolve(\DependenciesContainer.apiService)

    init(bandUrlString: String) {
        self.bandUrlString = bandUrlString
    }

    func refresh(force: Bool) async {
        if !force, case .fetched = bandMetadataFetchable { return }
        do {
            bandMetadataFetchable = .fetching
            if let bandId = bandUrlString.components(separatedBy: "/").last, Int(bandId) != nil {
                // View band from a normal URL
                async let band = fetchBand()
                async let discopgrahy = fetchDiscography(bandId: bandId)
                async let readMore = fetchReadMore(bandId: bandId)
                bandMetadataFetchable = try .fetched(.init(band: await band,
                                                           discography: await discopgrahy,
                                                           readMore: await readMore))
            } else {
                // Random band
                let band = try await fetchBand()
                async let discopgrahy = fetchDiscography(bandId: band.id)
                async let readMore = fetchReadMore(bandId: band.id)
                bandMetadataFetchable = try .fetched(.init(band: band,
                                                           discography: await discopgrahy,
                                                           readMore: await readMore))
            }
        } catch {
            bandMetadataFetchable = .error(error)
        }
    }

    private func fetchBand() async throws -> Band {
        try await apiService.request(forType: Band.self, urlString: bandUrlString)
    }

    private func fetchDiscography(bandId: String) async throws -> Discography {
        let urlString = "https://www.metal-archives.com/band/discography/id/\(bandId)/tab/all"
        return try await apiService.request(forType: Discography.self, urlString: urlString)
    }

    private func fetchReadMore(bandId: String) async throws -> String? {
        let urlString = "https://www.metal-archives.com/band/read-more/id/\(bandId)"
        var readMore = try await apiService.getString(for: urlString, inHtmlFormat: false)
        readMore = readMore?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let readMore, !readMore.isEmpty {
            return readMore
        }
        return nil
    }
}

// MARK: - Related links

extension BandViewModel {
    func refreshRelatedLinks(force: Bool) async {
        guard case let .fetched(metadata) = bandMetadataFetchable else {
            relatedLinksFetchable = .error(MAError.missingBand)
            return
        }

        if !force, case .fetched = relatedLinksFetchable { return }

        let urlString = "https://www.metal-archives.com/link/ajax-list/type/band/id/\(metadata.band.id)"
        relatedLinksFetchable = .fetching
        do {
            let links = try await apiService.request(forType: RelatedLinkArray.self,
                                                     urlString: urlString)
            relatedLinksFetchable = .fetched(links.content)
        } catch {
            relatedLinksFetchable = .error(error)
        }
    }
}
