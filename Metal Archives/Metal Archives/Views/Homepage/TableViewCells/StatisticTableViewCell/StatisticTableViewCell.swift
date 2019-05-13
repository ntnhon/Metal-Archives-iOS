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
    @IBOutlet private weak var separatorView: UIView!
    
    override func initAppearance() {
        super.initAppearance()
        statisticLabel.textColor = Settings.currentTheme.bodyTextColor
        statisticLabel.font = Settings.currentFontSize.bodyTextFont
        separatorView.backgroundColor = Settings.currentTheme.collectionViewSeparatorColor
    }

    func fill(with statisticString: NSAttributedString) {
        statisticLabel.attributedText = statisticString
    }
}
