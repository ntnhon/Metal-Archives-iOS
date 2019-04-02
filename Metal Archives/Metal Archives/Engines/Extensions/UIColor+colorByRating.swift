//
//  UIColor+colorByRating.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 03/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    static func colorByRating(_ rating: Int) -> UIColor {
        if rating >= 0 && rating < 25 {
            return Settings.currentTheme.splitUpStatusColor
        } else if rating >= 25 && rating < 50 {
            return Settings.currentTheme.onHoldStatusColor
        } else if rating >= 50 && rating < 75 {
            return Settings.currentTheme.changedNameStatusColor
        }
        
        return Settings.currentTheme.activeStatusColor
    }
}
