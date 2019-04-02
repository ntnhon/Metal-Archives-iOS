//
//  ViewMoreTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 16/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import UIKit

final class ViewMoreTableViewCell: BaseTableViewCell, RegisterableCell {
    @IBOutlet private weak var titleLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        self.displayAsBodyText()
    }
    
    func displayAsTitle() {
        self.titleLabel.textColor = Settings.currentTheme.bodyTextColor
        self.titleLabel.font = Settings.currentFontSize.titleFont
    }
    
    func displayAsSecondaryTitle() {
        self.titleLabel.textColor = Settings.currentTheme.bodyTextColor
        self.titleLabel.font = Settings.currentFontSize.secondaryTitleFont
    }
    
    func displayAsBodyText() {
        self.titleLabel.textColor = Settings.currentTheme.bodyTextColor
        self.titleLabel.font = Settings.currentFontSize.bodyTextFont
    }
    
    func fill(message: String) {
        self.titleLabel.text = message
    }
}
