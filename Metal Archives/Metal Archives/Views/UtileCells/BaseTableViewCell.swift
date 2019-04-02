//
//  BaseTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 02/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

class BaseTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.initAppearance()
    }
    
    func initAppearance() {
        self.backgroundColor = Settings.currentTheme.backgroundColor
        self.tintColor = Settings.currentTheme.iconTintColor
        let coloredView = UIView(frame: self.frame)
        coloredView.backgroundColor = Settings.currentTheme.tableViewCellSelectionColor
        self.selectedBackgroundView = coloredView
    }
}
