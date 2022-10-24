//
//  StatsViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 23/10/2022.
//

import SwiftUI

@available(iOS 16, *)
final class StatsViewModel: ObservableObject {
    @Published private(set) var statsFetchable = FetchableObject<Stats>.fetching
    private let apiService: APIServiceProtocol

    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }

    @MainActor
    func refreshStats(force: Bool) async {
        if !force, case .fetched = statsFetchable { return }
        do {
            statsFetchable = .fetching
            let urlString = "https://www.metal-archives.com/stats"
            let stats = try await apiService.request(forType: Stats.self, urlString: urlString)
            statsFetchable = .fetched(stats)
        } catch {
            statsFetchable = .error(error)
        }
    }
}
