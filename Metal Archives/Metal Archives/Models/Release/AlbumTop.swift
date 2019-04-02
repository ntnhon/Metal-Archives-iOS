//
//  AlbumTop.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

enum AlbumTopType: Int, CustomStringConvertible, CaseIterable {
    case review = 0, mostOwned, mostWanted
    
    var description: String {
        switch self {
        case .review: return "Nº of reviews"
        case .mostOwned: return "Most owned"
        case .mostWanted: return "Most wanted"
        }
    }
}

final class AlbumTop: Thumbnailable {
    let band: BandLite
    let release: ReleaseExtraLite
    let count: Int
    
    init?(band: BandLite, release: ReleaseExtraLite, count: Int) {
        self.band = band
        self.release = release
        self.count = count
        super.init(urlString: release.urlString, imageType: .release)
    }
}

//MARK: - Actionable
extension AlbumTop: Actionable {
    var actionableElements: [ActionableElement] {
        let bandElement = ActionableElement(name: self.band.name, urlString: self.band.urlString, type: .band)
        let releaseElement = ActionableElement(name: self.release.name, urlString: self.release.urlString, type: .release)
        return [bandElement, releaseElement]
    }
}
