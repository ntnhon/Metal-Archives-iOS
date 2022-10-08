//
//  ReleaseViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 30/07/2022.
//

import Combine
import Kingfisher
import UIKit

final class ReleaseViewModel: ObservableObject {
    deinit { print("\(Self.self) of \(releaseUrlString) is deallocated") }

    @Published private(set) var releaseFetchable: FetchableObject<Release> = .waiting
    @Published private(set) var coverFetchable: FetchableObject<UIImage?> = .waiting
    @Published private(set) var noCover = false
    private let apiService: APIServiceProtocol
    private let releaseUrlString: String

    init(apiService: APIServiceProtocol, releaseUrlString: String) {
        self.apiService = apiService
        self.releaseUrlString = releaseUrlString
    }

    @MainActor
    func fetchRelease() async {
        do {
            noCover = false
            releaseFetchable = .fetching
            let release = try await apiService.request(forType: Release.self,
                                                       urlString: releaseUrlString)
            releaseFetchable = .fetched(release)
            await fetchCoverImage(urlString: release.coverUrlString)
        } catch {
            releaseFetchable = .error(error)
        }
    }

    @MainActor
    private func fetchCoverImage(urlString: String?) async {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            noCover = true
            return
        }
        do {
            coverFetchable = .fetching
            let cover = try await KingfisherManager.shared.retrieveImage(with: url)
            coverFetchable = .fetched(cover)
        } catch {
            coverFetchable = .error(error)
        }
    }
}
