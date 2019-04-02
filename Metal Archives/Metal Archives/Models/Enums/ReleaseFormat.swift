//
//  ReleaseFormat.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 16/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

enum ReleaseFormat: CaseIterable, CustomStringConvertible {
    case cd, cassette, vinyl, vhs, dvd, digital, bluray, other
    
    var description: String {
        switch self {
        case .cd: return "CD"
        case .cassette: return "Cassette"
        case .vinyl: return "Vinyl"
        case .vhs: return "VHS"
        case .dvd: return "DVD"
        case .digital: return "Digital"
        case .bluray: return "Blu-ray"
        case .other: return "Other"
        }
    }
    
    var parameter: String {
        switch self {
        case .cd: return "CD"
        case .cassette: return "Cassette*"
        case .vinyl: return "Vinyl*"
        case .vhs: return "VHS"
        case .dvd: return "DVD"
        case .digital: return "Digital"
        case .bluray: return "Blu-ray*"
        case .other: return "Other"
        }
    }
}
