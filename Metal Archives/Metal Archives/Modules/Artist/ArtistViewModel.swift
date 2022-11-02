//
//  ArtistViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 30/07/2022.
//

import Combine
import Kingfisher
import UIKit

final class ArtistViewModel: ObservableObject {
//    deinit { print("\(Self.self) of \(urlString) is deallocated") }
    @Published private(set) var artistFetchable: FetchableObject<Artist> = .fetching
    @Published private(set) var biographyFetchable: FetchableObject<String?> = .fetching
    @Published private(set) var photoFetchable: FetchableObject<UIImage?> = .fetching
    @Published private(set) var relatedLinksFetchable: FetchableObject<[RelatedLink]> = .fetching

    private let apiService: APIServiceProtocol
    private let urlString: String

    var artist: Artist? {
        switch artistFetchable {
        case .fetched(let artist):
            return artist
        default:
            return nil
        }
    }

    var isFetchingPhoto: Bool {
        switch photoFetchable {
        case .fetching:
            return true
        default:
            return false
        }
    }

    var photo: UIImage? {
        switch photoFetchable {
        case .fetched(let photo):
            return photo
        default:
            return nil
        }
    }

    init(apiService: APIServiceProtocol, urlString: String) {
        self.apiService = apiService
        self.urlString = urlString
    }

    @MainActor
    func fetchArtist() async {
        if case .fetched = artistFetchable { return }
        do {
            artistFetchable = .fetching
            let artist = try await apiService.request(forType: Artist.self, urlString: urlString)
            artistFetchable = .fetched(artist)
            await fetchPhoto()
        } catch {
            artistFetchable = .error(error)
        }
    }

    @MainActor
    func fetchBiography(forceRefresh: Bool) async {
        if !forceRefresh, case .fetched = biographyFetchable { return }
        guard let id = urlString.components(separatedBy: "/").last else { return }
        do {
            biographyFetchable = .fetching
            let urlString = "https://www.metal-archives.com/artist/read-more/id/\(id)"
            let biography = try await apiService.getString(for: urlString, inHtmlFormat: false)
            biographyFetchable = .fetched(biography)
        } catch {
            biographyFetchable = .error(error)
        }
    }

    @MainActor
    func fetchPhoto() async {
        guard let urlString = artist?.photoUrlString,
              let url = URL(string: urlString) else {
            return
        }
        do {
            photoFetchable = .fetching
            let photo = try await KingfisherManager.shared.retrieveImage(with: url)
            photoFetchable = .fetched(photo)
        } catch {
            photoFetchable = .error(error)
        }
    }

    @MainActor
    func fetchRelatedLinks(forceRefresh: Bool) async {
        guard let artistId = urlString.components(separatedBy: "/").last else { return }
        if !forceRefresh, case .fetched = relatedLinksFetchable { return }

        let urlString = "https://www.metal-archives.com/link/ajax-list/type/person/id/\(artistId)"
        relatedLinksFetchable = .fetching
        do {
            let links = try await apiService.request(forType: RelatedLinkArray.self,
                                                     urlString: urlString)
            relatedLinksFetchable = .fetched(links.content)
        } catch {
            relatedLinksFetchable = .error(error)
        }
    }
}
