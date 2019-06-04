//
//  LabelMenuOption.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 04/06/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

enum LabelMenuOption: CustomStringConvertible {
    case subLabels, currentRoster, lastKnownRoster, pastRoster, releases, additionalNotes, links
    
    var description: String {
        switch self {
        case .subLabels: return "Sub-labels"
        case .currentRoster: return "Current Roster"
        case .lastKnownRoster: return "Last Known Roster"
        case .pastRoster: return "Past Roster"
        case .releases: return "Releases"
        case .additionalNotes: return "Additional Notes"
        case .links: return "Links"
        }
    }
}
