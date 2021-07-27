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
    private var cancellables = Set<AnyCancellable>()
    private let bandUrlString: String
    private var band: Band?

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

// MARK: - Related links
extension BandViewModel {
    func fetchRelatedLinks() {
        guard let band = band else {
            relatedLinksFetchable = .error(.nullBand)
            return
        }
        let urlString = "https://www.metal-archives.com/link/ajax-list/type/band/id/\(band.id)"
        switch relatedLinksFetchable {
        case .waiting: break
        default: return
        }
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
