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
