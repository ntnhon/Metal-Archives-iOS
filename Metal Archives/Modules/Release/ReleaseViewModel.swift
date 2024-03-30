//
//  ReleaseViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 30/07/2022.
//

import Combine
import Kingfisher
import UIKit

@MainActor
final class ReleaseViewModel: ObservableObject {
    @Published private(set) var releaseFetchable: FetchableObject<Release> = .fetching
    @Published private(set) var coverFetchable: FetchableObject<UIImage?> = .fetching
    @Published private(set) var otherVersionsFetchable: FetchableObject<[ReleaseOtherVersion]> = .fetching
    @Published private(set) var noCover = false
    private let apiService: APIServiceProtocol
    private let urlString: String
    let parentRelease: Release?

    var release: Release? {
        switch releaseFetchable {
        case let .fetched(release):
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
        case let .fetched(cover):
            return cover
        default:
            return nil
        }
    }

    init(apiService: APIServiceProtocol, urlString: String, parentRelease: Release?) {
        self.apiService = apiService
        self.urlString = urlString
        self.parentRelease = parentRelease
    }

    func fetchRelease() async {
        if case .fetched = releaseFetchable { return }
        do {
            noCover = false
            releaseFetchable = .fetching
            let release = try await apiService.request(forType: Release.self,
                                                       urlString: urlString)
            releaseFetchable = .fetched(release)
            await fetchCoverImage()
        } catch {
            releaseFetchable = .error(error)
        }
    }

    func fetchCoverImage() async {
        guard let urlString = release?.coverUrlString,
              let url = URL(string: urlString)
        else {
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

    func fetchOtherVersions() async {
        guard let release else { return }
        if case .fetched = otherVersionsFetchable { return }
        do {
            otherVersionsFetchable = .fetching
            let parentReleaseId = parentRelease?.id ?? release.id
            // swiftlint:disable:next line_length
            let urlString = "https://www.metal-archives.com/release/ajax-versions/current/\(release.id)/parent/\(parentReleaseId)"
            let data = try await apiService.getData(for: urlString)
            let otherVersions = [ReleaseOtherVersion](data: data)
            otherVersionsFetchable = .fetched(otherVersions)
        } catch {
            otherVersionsFetchable = .error(error)
        }
    }
}
