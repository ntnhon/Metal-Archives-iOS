//
//  BandSimilar.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 03/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class BandSimilar: Thumbnailable {
    let name: String
    let country: Country
    let genre: String
    let score: Int
    
    init?(name: String, urlString: String, country: Country, genre: String, score: Int) {
        self.name = name
        self.country = country
        self.genre = genre
        self.score = score
        
        super.init(urlString: urlString, imageType: .bandLogo)
    }
}
