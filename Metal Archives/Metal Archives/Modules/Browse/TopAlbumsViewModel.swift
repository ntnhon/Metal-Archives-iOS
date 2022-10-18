//
//  TopAlbumsViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 17/10/2022.
//

import Foundation

final class TopAlbumsViewModel: ObservableObject {
    @Published private(set) var topReleasesFetchable = FetchableObject<TopReleases>.fetching
    @Published private(set) var releases = [TopRelease]()
    @Published var category = TopAlbumsCategory.numberOfReviews {
        didSet {
            refilter()
        }
    }
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
            refilter()
        } catch {
            topReleasesFetchable = .error(error)
        }
    }

    private func refilter() {
        guard case .fetched(let topReleases) = topReleasesFetchable else { return }
        switch category {
        case .numberOfReviews:
            self.releases = topReleases.byReviews
        case .mostOwned:
            self.releases = topReleases.mostOwned
        case .mostWanted:
            self.releases = topReleases.mostWanted
        }
    }
}

enum TopAlbumsCategory: CaseIterable {
    case numberOfReviews, mostOwned, mostWanted

    var description: String {
        switch self {
        case .numberOfReviews: return "Number of reviews"
        case .mostOwned: return "Most owned"
        case .mostWanted: return "Most wanted"
        }
    }
}
