//
//  BandMenuOption.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 01/06/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

enum BandMenuOption: Int, CustomStringConvertible, CaseIterable {
    case discography = 0, members, reviews, similarArtists, about, relatedLinks
    
    var description: String {
        switch self {
        case .discography: return "Discography"
        case .members: return "Members"
        case .reviews: return "Reviews"
        case .similarArtists: return "Similar Artists"
        case .about: return "About"
        case .relatedLinks: return "Related Links"
        }
    }
}
