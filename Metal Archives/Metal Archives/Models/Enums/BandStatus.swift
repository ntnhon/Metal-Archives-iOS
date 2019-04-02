//
//  Status.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 29/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import UIKit

enum BandStatus: Int, CustomStringConvertible, CaseIterable {
    case active = 1, onHold, splitUp, unknown, changedName, disputed
    
    init(statusString: String) {
        let uppercasedStatusString = statusString.uppercased()
        
        if uppercasedStatusString == "active".uppercased() {
            self = .active
        } else if uppercasedStatusString == "on hold".uppercased() {
            self = .onHold
        } else if uppercasedStatusString == "split-up".uppercased() || uppercasedStatusString == "split up".uppercased() {
            self = .splitUp
        } else if uppercasedStatusString == "changed name".uppercased() {
            self = .changedName
        } else if uppercasedStatusString == "Disputed".uppercased() {
            self = .disputed
        }
        else {
            self = .unknown
        }
    }
    
    var color: UIColor {
        switch self {
        case .active: return Settings.currentTheme.activeStatusColor
        case .onHold: return Settings.currentTheme.onHoldStatusColor
        case .splitUp: return Settings.currentTheme.splitUpStatusColor
        case .changedName: return Settings.currentTheme.changedNameStatusColor
        case .disputed: return Settings.currentTheme.disputedStatusColor
        case .unknown: return Settings.currentTheme.unknownStatusColor
        }
    }
    
    var description: String {
        switch self {
        case .active: return "Active"
        case .onHold: return "On hold"
        case .splitUp: return "Split-up"
        case .changedName: return "Changed name"
        case .unknown: return "Unknown"
        case .disputed: return "Disputed"
        }
    }
}
