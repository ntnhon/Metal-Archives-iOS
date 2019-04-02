//
//  ReviewLiteWithTitle.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 05/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class ReviewLiteInRelease {
    let title: String
    let urlString: String
    let rating: Int
    let author: String
    let dateString: String
    
    init(title: String, urlString: String, rating: Int, author: String, dateString: String) {
        self.title = title
        self.urlString = urlString
        self.rating = rating
        self.author = author
        self.dateString = dateString
    }
}
