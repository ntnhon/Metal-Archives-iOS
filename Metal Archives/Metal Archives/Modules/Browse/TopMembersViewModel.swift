//
//  TopMembersViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 17/10/2022.
//

import Foundation

final class TopMembersViewModel: ObservableObject {
    @Published private(set) var topUsersFetchable = FetchableObject<TopUsers>.fetching
    let apiService: APIServiceProtocol

    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }

    func retry() {
        Task { @MainActor in
            await fetchTopUsers()
        }
    }

    @MainActor
    func fetchTopUsers() async {
        do {
            topUsersFetchable = .fetching
            let urlString = "https://www.metal-archives.com/stats/members"
            let topUsers = try await apiService.request(forType: TopUsers.self, urlString: urlString)
            topUsersFetchable = .fetched(topUsers)
        } catch {
            topUsersFetchable = .error(error)
        }
    }
}
