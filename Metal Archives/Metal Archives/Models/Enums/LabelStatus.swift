//
//  LabelStatus.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 25/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import UIKit

enum LabelStatus: CustomStringConvertible {
    case active, closed, changedName, unknown
    
    init(statusString: String) {
        let uppercasedStatusString = statusString.uppercased()
        
        if uppercasedStatusString == "active".uppercased() {
            self = .active
        } else if uppercasedStatusString == "closed".uppercased() {
            self = .closed
        } else if uppercasedStatusString == "changed name".uppercased() {
            self = .changedName
        } else {
            self = .unknown
        }
    }
    
    var color: UIColor {
        switch self {
        case .active: return Settings.currentTheme.activeStatusColor
        case .closed: return Settings.currentTheme.closedStatusColor
        case .changedName: return Settings.currentTheme.changedNameStatusColor
        case .unknown: return Settings.currentTheme.unknownStatusColor
        }
    }
    
    var description: String {
        switch self {
        case .active: return "Active"
        case .closed: return "Closed"
        case .changedName: return "Changed name"
        case .unknown: return "Unknown"
        }
    }
}
