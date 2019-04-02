//
//  BandTopRelease.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

enum BandTopType: Int, CustomStringConvertible, CaseIterable {
    case release = 0, fullLength, review
    
    var description: String {
        switch self {
        case .release: return "Nº of releases"
        case .fullLength: return "Nº of full-length"
        case .review: return "Nº of reviews"
        }
    }
}

final class BandTop: Thumbnailable {
    let name: String
    let count: Int
    
    init?(urlString: String, name: String, count: Int) {
        self.name = name
        self.count = count
        super.init(urlString: urlString, imageType: .bandLogo)
    }
}
