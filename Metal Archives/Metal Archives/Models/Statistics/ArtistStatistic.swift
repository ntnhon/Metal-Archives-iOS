//
//  ArtistStatistic.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class ArtistStatistic {
    let total: Int
    let stillPlaying: Int
    let quitPlaying: Int
    let deceased: Int
    let female: Int
    let male: Int
    let unknownOrEntities: Int
    
    init(total: Int, stillPlaying: Int, quitPlaying: Int, deceased: Int, female: Int, male: Int, unknownOrEntities: Int) {
        self.total = total
        self.stillPlaying = stillPlaying
        self.quitPlaying = quitPlaying
        self.deceased = deceased
        self.female = female
        self.male = male
        self.unknownOrEntities = unknownOrEntities
    }
}
