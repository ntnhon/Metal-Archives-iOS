//
//  BandHeaderViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 31/07/2022.
//

import Kingfisher
import SwiftUI

@MainActor
final class BandHeaderViewModel: ObservableObject {
    @Published private(set) var logoFetchable = FetchableObject<UIImage?>.fetching
    @Published private(set) var photoFetchable = FetchableObject<UIImage?>.fetching

    var logo: UIImage? {
        switch logoFetchable {
        case .fetched(let logo):
            return logo
        default:
            return nil
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

    let band: Band

    init(band: Band) {
        self.band = band
    }

    private func fetchLogo() async {
        guard let logoUrlString = band.logoUrlString,
              let logoUrl = URL(string: logoUrlString) else {
            logoFetchable = .fetched(nil)
            return
        }

        do {
            logoFetchable = .fetching
            let logo = try await KingfisherManager.shared.retrieveImage(with: logoUrl)
            logoFetchable = .fetched(logo)
        } catch {
            logoFetchable = .error(error)
        }
    }

    private func fetchPhoto() async {
        guard let photoUrlString = band.photoUrlString,
              let photoUrl = URL(string: photoUrlString) else {
            photoFetchable = .fetched(nil)
            return
        }

        do {
            photoFetchable = .fetching
            let photo = try await KingfisherManager.shared.retrieveImage(with: photoUrl)
            photoFetchable = .fetched(photo)
        } catch {
            photoFetchable = .error(error)
        }
    }

    func fetchImages() async {
        await fetchLogo()
        await fetchPhoto()
    }
}
