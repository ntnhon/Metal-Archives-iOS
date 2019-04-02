//
//  StatisticTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 14/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class StatisticTableViewCell: BaseTableViewCell, RegisterableCell {
    @IBOutlet private weak var statisticLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        self.statisticLabel.textColor = Settings.currentTheme.bodyTextColor
        self.statisticLabel.font = Settings.currentFontSize.bodyTextFont
    }

    func fill(with statistic: String) {
        self.statisticLabel.text = statistic
    }
}
