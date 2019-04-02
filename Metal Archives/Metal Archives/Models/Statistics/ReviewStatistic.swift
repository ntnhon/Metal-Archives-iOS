//
//  ReviewStatistic.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class ReviewStatistic {
    let approvedReviews: Int
    let uniqueAlbum: Int
    
    init(approvedReviews: Int, uniqueAlbum: Int) {
        self.approvedReviews = approvedReviews
        self.uniqueAlbum = uniqueAlbum
    }
}
