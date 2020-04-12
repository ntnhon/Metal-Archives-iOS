//
//  Floaty+ConvenienceMethods.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 12/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import Floaty

extension Floaty {
    func customizeAppearance() {
        buttonColor = Settings.currentTheme.iconTintColor
        plusColor = Settings.currentTheme.backgroundColor
        overlayColor = UIColor.black.withAlphaComponent(0.7)
    }
}
