//
//  BandViewModel.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/06/2021.
//

import SwiftUI

final class BandViewModel: ObservableObject {
    deinit { print("\(Self.self) of \(bandUrlString) is deallocated") }

    @Published private(set) var bandAndDiscographyFetchable: FetchableObject<(Band, Discography)> = .fetching
    @Published private(set) var relatedLinksFetchable: FetchableObject<[RelatedLink]> = .fetching
    private(set) var band: Band?
    private let bandUrlString: String
    private let apiService: APIServiceProtocol

    init(apiService: APIServiceProtocol, bandUrlString: String) {
        self.apiService = apiService
        self.bandUrlString = bandUrlString
    }

    @MainActor
    func fetchBandAndDiscography() async {
        if case .fetched = bandAndDiscographyFetchable { return }
        do {
            bandAndDiscographyFetchable = .fetching
            let band = try await apiService.request(forType: Band.self, urlString: bandUrlString)
            let discographyUrlString = "https://www.metal-archives.com/band/discography/id/\(band.id)/tab/all"
            let discography = try await apiService.request(forType: Discography.self,
                                                           urlString: discographyUrlString)
            self.band = band
            self.bandAndDiscographyFetchable = .fetched((band, discography))
        } catch {
            self.bandAndDiscographyFetchable = .error(error)
        }
    }

    func refreshBandAndDiscography() {
        bandAndDiscographyFetchable = .fetching
        Task { @MainActor in
            await fetchBandAndDiscography()
        }
    }
}

// MARK: - Related links
extension BandViewModel {
    func fetchRelatedLinks() {
        guard let band else {
            relatedLinksFetchable = .error(MAError.missingBand)
            return
        }

        if case .fetched = relatedLinksFetchable { return }

        let urlString = "https://www.metal-archives.com/link/ajax-list/type/band/id/\(band.id)"
        relatedLinksFetchable = .fetching
        Task { @MainActor in
            do {
                let links = try await apiService.request(forType: RelatedLinkArray.self,
                                                         urlString: urlString)
                relatedLinksFetchable = .fetched(links.content)
            } catch {
                relatedLinksFetchable = .error(error)
            }
        }
    }

    func refreshRelatedLinks() {
        relatedLinksFetchable = .fetching
        fetchRelatedLinks()
    }
}
