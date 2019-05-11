//
//  SimpleSearchResultBandNameOrMusicGenre.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 05/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

class SimpleSearchResultBandNameOrMusicGenre: ThumbnailableObject {
    let band: BandLite
    let aka: String?
    let genre: String
    let country: Country
    
    init?(band: BandLite, aka: String?, genre: String, country: Country) {
        self.band = band
        self.aka = aka
        self.genre = genre
        self.country = country
        super.init(urlString: band.urlString, imageType: .bandLogo)
    }
}
