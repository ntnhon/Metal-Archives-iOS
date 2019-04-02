//
//  ReleaseLite.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 30/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class ReleaseLite: Thumbnailable {
    let title: String
    let type: ReleaseType
    let year: Int
    let numberOfReviews: Int?
    let averagePoint: Int?
    let reviewsURLString: String?
    
    init?(urlString: String, type: ReleaseType, title: String, year: Int, numberOfReviews: Int?, averagePoint: Int?, reviewsURLString: String?) {
        self.title = title
        self.year = year
        self.type = type
        self.numberOfReviews = numberOfReviews
        self.averagePoint = averagePoint
        self.reviewsURLString = reviewsURLString
        super.init(urlString: urlString, imageType: .release)
    }
}
