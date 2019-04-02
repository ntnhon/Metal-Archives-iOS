//
//  ReviewLite.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 03/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class ReviewLite {
    let urlString: String
    let releaseTitle: String
    let rating: Int
    let dateString: String
    let author: String
    
    //Iterate releases in bands in order to find a corresponding ReleaseLite
    // => set thumbnail to review cell
    private(set) var release: ReleaseLite?
    
    init?(urlString: String, releaseTitle: String, point: Int, dateString: String, author: String) {
        self.urlString = urlString
        self.releaseTitle = releaseTitle
        self.rating = point
        self.dateString = dateString
        self.author = author
    }
    
    func associateToRelease(_ release: ReleaseLite) {
        self.release = release
    }
}
