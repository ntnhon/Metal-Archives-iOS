//
//  ReleaseMenuOption.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 01/06/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

enum ReleaseMenuOption: Int, CustomStringConvertible, CaseIterable {
    case trackList = 0, lineup, reviews, otherVersions, additionalNotes
    
    var description: String {
        switch self {
        case .trackList: return "Tracklist"
        case .lineup: return "Lineup"
        case .reviews: return "Reviews"
        case .otherVersions: return "Other Versions"
        case .additionalNotes: return "Additional Notes"
        }
    }
}
