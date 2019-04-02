//
//  DetailTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 16/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class DetailTableViewCell: BaseTableViewCell, RegisterableCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        self.titleLabel.textColor = Settings.currentTheme.secondaryTitleColor
        self.titleLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        self.detailLabel.textColor = Settings.currentTheme.bodyTextColor
        self.detailLabel.font = Settings.currentFontSize.bodyTextFont
    }

    func fill(withTitle title: String, detail: String) {
        self.titleLabel.text = title
        self.detailLabel.text = detail
    }
}
