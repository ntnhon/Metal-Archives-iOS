//
//  TopBandsViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 17/10/2022.
//

import Foundation

final class TopBandsViewModel: ObservableObject {
    @Published private(set) var topBandsFetchable = FetchableObject<TopBands>.fetching
    let apiService: APIServiceProtocol

    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }

    func retry() {
        Task { @MainActor in
            await fetchTopBands()
        }
    }

    @MainActor
    func fetchTopBands() async {
        do {
            topBandsFetchable = .fetching
            let urlString = "https://www.metal-archives.com/stats/bands"
            let topBands = try await apiService.request(forType: TopBands.self, urlString: urlString)
            topBandsFetchable = .fetched(topBands)
        } catch {
            topBandsFetchable = .error(error)
        }
    }
}
