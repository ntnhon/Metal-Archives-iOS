//
//  TopAlbumsViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 17/10/2022.
//

import Factory
import Foundation

@MainActor
final class TopAlbumsViewModel: ObservableObject {
    @Published private(set) var topReleasesFetchable = FetchableObject<TopReleases>.fetching
    @Published private(set) var releases = [TopRelease]()
    @Published var category = TopAlbumsCategory.numberOfReviews {
        didSet {
            refilter()
        }
    }

    private let apiService = resolve(\DependenciesContainer.apiService)

    var isFetched: Bool {
        if case .fetched = topReleasesFetchable {
            return true
        }
        return false
    }

    init() {}

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
        guard case let .fetched(topReleases) = topReleasesFetchable else { return }
        switch category {
        case .numberOfReviews:
            releases = topReleases.byReviews
        case .mostOwned:
            releases = topReleases.mostOwned
        case .mostWanted:
            releases = topReleases.mostWanted
        }
    }
}

enum TopAlbumsCategory: CaseIterable {
    case numberOfReviews, mostOwned, mostWanted

    var description: String {
        switch self {
        case .numberOfReviews:
            "Number of reviews"
        case .mostOwned:
            "Most owned"
        case .mostWanted:
            "Most wanted"
        }
    }
}
