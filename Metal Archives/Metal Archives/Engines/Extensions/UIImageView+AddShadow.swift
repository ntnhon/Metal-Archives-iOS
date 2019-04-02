//
//  UIImageView+AddShadow.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 02/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

extension UIImageView {
    func addShadow() {
        self.layer.shadowColor = Settings.currentTheme.bodyTextColor.cgColor
        self.layer.shadowOffset = .zero
        self.layer.shadowOpacity = 0.7
        self.layer.shadowRadius = 10
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}
