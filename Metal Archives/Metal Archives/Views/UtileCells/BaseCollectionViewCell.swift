//
//  BaseCollectionViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 12/05/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

class BaseCollectionViewCell: UICollectionViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initAppearance()
    }
    
    func initAppearance() {
        self.backgroundColor = Settings.currentTheme.backgroundColor
        self.tintColor = Settings.currentTheme.iconTintColor
        self.selectedBackgroundView = nil
    }
    
}
