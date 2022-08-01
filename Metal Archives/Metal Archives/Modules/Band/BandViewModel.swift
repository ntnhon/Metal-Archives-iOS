//
//  BandViewModel.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/06/2021.
//

import SwiftUI

final class BandViewModel: ObservableObject {
    @Published private(set) var bandAndDiscographyFetchable: FetchableObject<(Band, Discography)> = .waiting
    @Published private(set) var relatedLinksFetchable: FetchableObject<[RelatedLink]> = .waiting
    @Published private(set) var readMoreFetchable: FetchableObject<HtmlBodyText> = .waiting
    @Published private(set) var similarArtistsFetchable: FetchableObject<[BandSimilar]> = .waiting
    private(set) var band: Band?
    private let bandUrlString: String
    private let apiService: APIServiceProtocol

    deinit {
        print("\(Self.self) of \(bandUrlString) is deallocated")
    }

    init(apiService: APIServiceProtocol, bandUrlString: String) {
        self.apiService = apiService
        self.bandUrlString = bandUrlString
    }

    func fetchBandAndDiscography() {
        switch bandAndDiscographyFetchable {
        case .waiting: break
        default: return
        }
        Task { @MainActor in
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
    }

    func refreshBandAndDiscography() {
        bandAndDiscographyFetchable = .waiting
        fetchBandAndDiscography()
    }
}

// MARK: - Read more
extension BandViewModel {
    func fetchReadMore() {
        switch readMoreFetchable {
        case .waiting: break
        default: return
        }

        guard let band = band else {
            readMoreFetchable = .error(MAError.missingBand)
            return
        }

        let urlString = "https://www.metal-archives.com/band/read-more/id/\(band.id)"
        readMoreFetchable = .fetching
        Task { @MainActor in
            do {
                let readMore = try await apiService.request(forType: HtmlBodyText.self,
                                                            urlString: urlString)
                readMoreFetchable = .fetched(readMore)
            } catch {
                readMoreFetchable = .error(error)
            }
        }
    }

    func refreshReadMore() {
        readMoreFetchable = .waiting
        fetchReadMore()
    }
}

// MARK: - Similar artists
extension BandViewModel {
    func fetchSimilarArtists() {
        switch similarArtistsFetchable {
        case .waiting: break
        default: return
        }

        guard let band = band else {
            similarArtistsFetchable = .error(MAError.missingBand)
            return
        }

        let urlString = "https://www.metal-archives.com/band/ajax-recommendations/id/\(band.id)/showMoreSimilar/1"
        similarArtistsFetchable = .fetching
        Task { @MainActor in
            do {
                let similarArtists = try await apiService.request(forType: BandSimilarArray.self,
                                                                  urlString: urlString)
                similarArtistsFetchable = .fetched(similarArtists.content)
            } catch {
                similarArtistsFetchable = .error(error)
            }
        }
    }

    func refreshSimilarArtists() {
        similarArtistsFetchable = .waiting
        fetchSimilarArtists()
    }
}

// MARK: - Related links
extension BandViewModel {
    func fetchRelatedLinks() {
        switch relatedLinksFetchable {
        case .waiting: break
        default: return
        }

        guard let band = band else {
            relatedLinksFetchable = .error(MAError.missingBand)
            return
        }

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
        relatedLinksFetchable = .waiting
        fetchRelatedLinks()
    }
}
