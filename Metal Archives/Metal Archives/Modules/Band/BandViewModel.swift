//
//  BandViewModel.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/06/2021.
//

import Combine
import Foundation

final class BandViewModel: ObservableObject {
    @Published private(set) var bandAndDiscographyFetchable: FetchableObject<(Band, Discography)> = .waiting
    @Published private(set) var relatedLinksFetchable: FetchableObject<[RelatedLink]> = .waiting
    @Published private(set) var readMoreFetchable: FetchableObject<HtmlBodyText> = .waiting
    @Published private(set) var similarArtistsFetchable: FetchableObject<[BandSimilar]> = .waiting
    private(set) var band: Band?
    private var cancellables = Set<AnyCancellable>()
    private let bandUrlString: String

    deinit {
        print("\(Self.self) of \(bandUrlString) is deallocated")
    }

    init(bandUrlString: String) {
        self.bandUrlString = bandUrlString
    }

    func fetchBandAndDiscography() {
        switch bandAndDiscographyFetchable {
        case .waiting: break
        default: return
        }
        RequestService.request(type: Band.self, from: bandUrlString)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error): self?.bandAndDiscographyFetchable = .error(error)
                case .finished: break
                }
            }, receiveValue: { [weak self] band in
                guard let self = self else { return }
                self.band = band
                let discographyUrlString = "https://www.metal-archives.com/band/discography/id/\(band.id)/tab/all"
                RequestService.request(type: Discography.self, from: discographyUrlString)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] completion in
                        switch completion {
                        case .failure(let error): self?.bandAndDiscographyFetchable = .error(error)
                        case .finished: break
                        }
                    } receiveValue: { [weak self]  discography in
                        self?.bandAndDiscographyFetchable = .fetched((band, discography))
                    }
                    .store(in: &self.cancellables)
            })
            .store(in: &cancellables)
    }

    func refreshBandAndDiscography() {
        self.bandAndDiscographyFetchable = .waiting
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
            readMoreFetchable = .error(MAError.nullBand)
            return
        }

        let urlString = "https://www.metal-archives.com/band/read-more/id/\(band.id)"
        readMoreFetchable = .fetching
        RequestService.request(type: HtmlBodyText.self, from: urlString)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error): self?.readMoreFetchable = .error(error)
                case .finished: break
                }
            }, receiveValue: { [weak self] result in
                self?.readMoreFetchable = .fetched(result)
            })
            .store(in: &cancellables)
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
            similarArtistsFetchable = .error(MAError.nullBand)
            return
        }

        let urlString = "https://www.metal-archives.com/band/ajax-recommendations/id/\(band.id)/showMoreSimilar/1"
        similarArtistsFetchable = .fetching
        RequestService.request(type: BandSimilarArray.self, from: urlString)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error): self?.similarArtistsFetchable = .error(error)
                case .finished: break
                }
            }, receiveValue: { [weak self] array in
                self?.similarArtistsFetchable = .fetched(array.content)
            })
            .store(in: &cancellables)
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
            relatedLinksFetchable = .error(MAError.nullBand)
            return
        }

        let urlString = "https://www.metal-archives.com/link/ajax-list/type/band/id/\(band.id)"
        relatedLinksFetchable = .fetching
        RequestService.request(type: RelatedLinkArray.self, from: urlString)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error): self?.relatedLinksFetchable = .error(error)
                case .finished: break
                }
            }, receiveValue: { [weak self] array in
                self?.relatedLinksFetchable = .fetched(array.content)
            })
            .store(in: &cancellables)
    }

    func refreshRelatedLinks() {
        relatedLinksFetchable = .waiting
        fetchRelatedLinks()
    }
}
