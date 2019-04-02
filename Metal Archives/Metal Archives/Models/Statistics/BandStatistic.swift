//
//  BandStatistic.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import UIKit

final class BandStatistic {
    typealias BandStatisticStatus = (description: String, count: Int, color: UIColor)
    
    let total: Int
    let active: BandStatisticStatus
    let onHold: BandStatisticStatus
    let splitUp: BandStatisticStatus
    let changedName: BandStatisticStatus
    let unknown: BandStatisticStatus
    
    init(total: Int, active: Int, onHold: Int, splitUp: Int, changedName: Int, unknown: Int) {
        self.total = total
        self.active = ("Active", active, Settings.currentTheme.activeStatusColor)
        self.onHold = ("On hold", onHold, Settings.currentTheme.onHoldStatusColor)
        self.splitUp = ("Split-up", splitUp, Settings.currentTheme.splitUpStatusColor)
        self.changedName = ("Changed name", changedName, Settings.currentTheme.changedNameStatusColor)
        self.unknown = ("Unknown", unknown, Settings.currentTheme.unknownStatusColor)
    }
}

