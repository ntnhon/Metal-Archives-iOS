//
//  TopMembersViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 17/10/2022.
//

import Factory
import Foundation

@MainActor
final class TopMembersViewModel: ObservableObject {
    @Published private(set) var topUsersFetchable = FetchableObject<TopUsers>.fetching
    @Published private(set) var topUsers = [TopUser]()
    @Published var category = TopMembersCategory.submittedBands {
        didSet {
            refilter()
        }
    }

    private let apiService = resolve(\DependenciesContainer.apiService)

    var isFetched: Bool {
        if case .fetched = topUsersFetchable {
            return true
        }
        return false
    }

    init() {}

    func fetchTopUsers() async {
        if case .fetched = topUsersFetchable { return }
        do {
            topUsersFetchable = .fetching
            let urlString = "https://www.metal-archives.com/stats/members"
            let topUsers = try await apiService.request(forType: TopUsers.self, urlString: urlString)
            topUsersFetchable = .fetched(topUsers)
            refilter()
        } catch {
            topUsersFetchable = .error(error)
        }
    }

    private func refilter() {
        guard case let .fetched(topUsers) = topUsersFetchable else { return }
        switch category {
        case .submittedBands:
            self.topUsers = topUsers.bySubmittedBands
        case .writtenReviews:
            self.topUsers = topUsers.byWrittenReviews
        case .submittedAlbums:
            self.topUsers = topUsers.bySubmittedAlbums
        case .artistsAdded:
            self.topUsers = topUsers.byArtistsAdded
        }
    }
}

enum TopMembersCategory: CaseIterable {
    case submittedBands, writtenReviews, submittedAlbums, artistsAdded

    var description: String {
        switch self {
        case .submittedBands:
            "Submitted bands"
        case .writtenReviews:
            "Written reviews"
        case .submittedAlbums:
            "submittedAlbums"
        case .artistsAdded:
            "Artists added"
        }
    }
}
