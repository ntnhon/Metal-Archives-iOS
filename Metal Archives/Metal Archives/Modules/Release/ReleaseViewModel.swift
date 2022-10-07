//
//  ReleaseViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 30/07/2022.
//

import Combine

final class ReleaseViewModel: ObservableObject {
    deinit { print("\(Self.self) of \(releaseUrlString) is deallocated") }

    @Published private(set) var releaseFetchable: FetchableObject<Release> = .waiting
    private let apiService: APIServiceProtocol
    private let releaseUrlString: String

    init(apiService: APIServiceProtocol, releaseUrlString: String) {
        self.apiService = apiService
        self.releaseUrlString = releaseUrlString
    }

    @MainActor
    func fetchRelease() async {
        do {
            releaseFetchable = .fetching
            let release = try await apiService.request(forType: Release.self,
                                                       urlString: releaseUrlString)
            releaseFetchable = .fetched(release)
        } catch {
            releaseFetchable = .error(error)
        }
    }
}
