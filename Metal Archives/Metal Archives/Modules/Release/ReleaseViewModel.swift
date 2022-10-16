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

    @Published private(set) var releaseFetchable: FetchableObject<Release> = .fetching
    @Published private(set) var coverFetchable: FetchableObject<UIImage?> = .fetching
    @Published private(set) var noCover = false
    private let apiService: APIServiceProtocol
    private let releaseUrlString: String

    var release: Release? {
        switch releaseFetchable {
        case .fetched(let release):
            return release
        default:
            return nil
        }
    }

    var isFetchingCover: Bool {
        switch coverFetchable {
        case .fetching:
            return true
        default:
            return false
        }
    }

    var cover: UIImage? {
        switch coverFetchable {
        case .fetched(let cover):
            return cover
        default:
            return nil
        }
    }

    init(apiService: APIServiceProtocol, releaseUrlString: String) {
        self.apiService = apiService
        self.releaseUrlString = releaseUrlString
    }

    @MainActor
    func fetchRelease() async {
        if case .fetched = releaseFetchable { return }
        do {
            noCover = false
            releaseFetchable = .fetching
            let release = try await apiService.request(forType: Release.self,
                                                       urlString: releaseUrlString)
            releaseFetchable = .fetched(release)
            await fetchCoverImage()
        } catch {
            releaseFetchable = .error(error)
        }
    }

    @MainActor
    func fetchCoverImage() async {
        guard let urlString = release?.coverUrlString,
              let url = URL(string: urlString) else {
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

    func fetchCoverImage() {
        Task { await fetchCoverImage() }
    }
}
