//
//  String+RankColor.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 14/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func rankColor() -> UIColor {
        if contains("Webmaster") {
            return Settings.currentTheme.webmasterColor
        } else if contains("Metal God") {
            return Settings.currentTheme.metalGodColor
        } else if contains("Metal lord") {
            return Settings.currentTheme.metalLordColor
        } else if contains("Metal demon") {
            return Settings.currentTheme.metalDemonColor
        } else if contains("Metal knight") {
            return Settings.currentTheme.metalKnightColor
        } else if contains("Dishonourably Discharged") {
            return Settings.currentTheme.dishonourablyDischargedColor
        } else if contains("Metal freak") {
            return Settings.currentTheme.metalFreakColor
        } else if contains("Veteran") {
            return Settings.currentTheme.veteranColor
        } else if contains("Metalhead") {
            return Settings.currentTheme.metalheadColor
        }
        
        return Settings.currentTheme.bodyTextColor
    }
}
