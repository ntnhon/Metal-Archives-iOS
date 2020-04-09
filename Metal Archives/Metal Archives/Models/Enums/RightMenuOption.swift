//
//  RightMenuOption.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 09/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

enum RightMenuOption {
    case collection, bookmarks, logOut
    
    var iconName: String {
        switch self {
        case .collection: return Ressources.Images.disc_collection
        case .bookmarks: return Ressources.Images.bookmark
        case .logOut: return Ressources.Images.log_out
        }
    }
    
    var title: String {
        switch self {
        case .collection: return "My collection"
        case .bookmarks: return "My bookmarks"
        case .logOut: return "Log out"
        }
    }
}
