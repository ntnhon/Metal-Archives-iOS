//
//  TopBandsViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 17/10/2022.
//

import Foundation

@MainActor
final class TopBandsViewModel: ObservableObject {
    @Published private(set) var topBandsFetchable = FetchableObject<TopBands>.fetching
    @Published private(set) var topBands = [TopBand]()
    @Published var category = TopBandsCategory.numberOfReleases {
        didSet {
            refilter()
        }
    }

    let apiService: APIServiceProtocol

    var isFetched: Bool {
        if case .fetched = topBandsFetchable {
            return true
        }
        return false
    }

    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }

    func fetchTopBands() async {
        if case .fetched = topBandsFetchable { return }
        do {
            topBandsFetchable = .fetching
            let urlString = "https://www.metal-archives.com/stats/bands"
            let topBands = try await apiService.request(forType: TopBands.self, urlString: urlString)
            topBandsFetchable = .fetched(topBands)
            refilter()
        } catch {
            topBandsFetchable = .error(error)
        }
    }

    private func refilter() {
        guard case let .fetched(topBands) = topBandsFetchable else { return }
        switch category {
        case .numberOfReleases:
            self.topBands = topBands.byReleases
        case .numberOfFullLengths:
            self.topBands = topBands.byFullLength
        case .numberOfReviews:
            self.topBands = topBands.byReviews
        }
    }
}

enum TopBandsCategory: CaseIterable {
    case numberOfReleases, numberOfFullLengths, numberOfReviews

    var description: String {
        switch self {
        case .numberOfReleases:
            "Number of releases"
        case .numberOfFullLengths:
            "Number of full-lengths"
        case .numberOfReviews:
            "Number of reviews"
        }
    }
}
