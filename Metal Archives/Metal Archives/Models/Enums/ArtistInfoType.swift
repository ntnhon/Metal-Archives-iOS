//
//  ArtistInfoType.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 16/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

enum ArtistInfoType: CustomStringConvertible {
    case trivia, pastBands, activeBands, live, guestSession, miscStaff, links
    
    var description: String {
        switch self {
        case .trivia: return "Trivia"
        case .pastBands: return "Past Bands"
        case .activeBands: return "Active Bands"
        case .live: return "Live"
        case .guestSession: return "Guest/Session"
        case .miscStaff: return "Misc. Staff"
        case .links: return "Links"
        }
    }
}
