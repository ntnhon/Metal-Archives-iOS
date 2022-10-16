//
//  BandReadMoreViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 15/10/2022.
//

import Foundation

final class BandReadMoreViewModel: ObservableObject {
    @Published private(set) var readMoreFetchable = FetchableObject<String>.fetching

    let apiService: APIServiceProtocol
    let band: Band

    init(apiService: APIServiceProtocol, band: Band) {
        self.apiService = apiService
        self.band = band
    }

    func retry() {
        Task {
            await fetchReadMore()
        }
    }

    @MainActor
    func fetchReadMore() async {
        do {
            readMoreFetchable = .fetching
            let urlString = "https://www.metal-archives.com/band/read-more/id/\(band.id)"
            let readMore = try await apiService.getString(for: urlString, inHtmlFormat: false)
            guard let readMore = readMore else {
                throw MAError.failedToFetchReadMore(bandName: band.name)
            }
            readMoreFetchable = .fetched(readMore)
        } catch {
            readMoreFetchable = .error(error)
        }
    }
}
