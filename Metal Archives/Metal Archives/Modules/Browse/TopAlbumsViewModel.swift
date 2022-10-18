//
//  TopAlbumsViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 17/10/2022.
//

import Foundation

final class TopAlbumsViewModel: ObservableObject {
    @Published private(set) var topReleasesFetchable = FetchableObject<TopReleases>.fetching
    let apiService: APIServiceProtocol

    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }

    func retry() {
        Task { @MainActor in
            await fetchTopReleases()
        }
    }

    @MainActor
    func fetchTopReleases() async {
        if case .fetched = topReleasesFetchable { return }
        do {
            topReleasesFetchable = .fetching
            let urlString = "https://www.metal-archives.com/stats/albums"
            let topReleases = try await apiService.request(forType: TopReleases.self, urlString: urlString)
            topReleasesFetchable = .fetched(topReleases)
        } catch {
            topReleasesFetchable = .error(error)
        }
    }
}
