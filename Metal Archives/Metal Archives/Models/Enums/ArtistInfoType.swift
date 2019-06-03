//
//  ArtistInfoType.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 16/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

enum ArtistInfoType: CustomStringConvertible {
    case pastBands, activeBands, live, guestSession, miscStaff, biography, links
    
    var description: String {
        switch self {
        case .pastBands: return "Past Bands"
        case .activeBands: return "Active Bands"
        case .live: return "Live"
        case .guestSession: return "Guest/Session"
        case .miscStaff: return "Misc. Staff"
        case .biography: return "Biography"
        case .links: return "Links"
        }
    }
}
