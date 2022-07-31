//
//  BandHeaderViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 31/07/2022.
//

import Kingfisher
import SwiftUI

final class BandHeaderViewModel: ObservableObject {
    @Published private(set) var isLoadingLogo = false
    @Published private(set) var logo: UIImage?
    @Published private(set) var isLoadingPhoto = false
    @Published private(set) var photo: UIImage?

    let band: Band

    init(band: Band) {
        self.band = band
    }

    func fetchImages() {
        if logo == nil,
           let logoUrlString = band.logoUrlString,
           let logoUrl = URL(string: logoUrlString) {
            isLoadingLogo = true
            KingfisherManager.shared.retrieveImage(with: logoUrl) { [weak self] result in
                guard let self = self else { return }
                self.isLoadingLogo = false
                switch result {
                case .success(let imageResult):
                    if let cgImage = imageResult.image.cgImage {
                        self.logo = .init(cgImage: cgImage)
                    }

                case .failure(let error):
                    Logger.log(error.userFacingMessage)
                }
            }
        }

        if photo == nil,
           let photoUrlString = band.photoUrlString,
           let photoUrl = URL(string: photoUrlString) {
            isLoadingPhoto = true
            KingfisherManager.shared.retrieveImage(with: photoUrl) { [weak self] result in
                guard let self = self else { return }
                self.isLoadingPhoto = false
                switch result {
                case .success(let imageResult):
                    if let cgImage = imageResult.image.cgImage {
                        self.photo = .init(cgImage: cgImage)
                    }

                case .failure(let error):
                    Logger.log(error.userFacingMessage)
                }
            }
        }
    }
}
