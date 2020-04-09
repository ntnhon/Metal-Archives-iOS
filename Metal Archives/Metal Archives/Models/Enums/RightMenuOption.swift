//
//  RightMenuOption.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 09/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

enum RightMenuOption {
    case collection, bands, artists, labels, releases, logOut
    
    var iconName: String {
        switch self {
        case .collection: return Ressources.Images.disc_collection
        case .bands: return Ressources.Images.band
        case .artists: return Ressources.Images.person
        case .labels: return Ressources.Images.labelIcon
        case .releases: return Ressources.Images.vinyl
        case .logOut: return Ressources.Images.log_out
        }
    }
    
    var title: String {
        switch self {
        case .collection: return "My collection"
        case .bands: return "Bands"
        case .artists: return "Artists"
        case .labels: return "Labels"
        case .releases: return "Releases"
        case .logOut: return "Log out"
        }
    }
}
