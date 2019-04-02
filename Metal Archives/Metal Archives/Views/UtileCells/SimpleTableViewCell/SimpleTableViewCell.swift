//
//  NoElementTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 30/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class SimpleTableViewCell: BaseTableViewCell, RegisterableCell {
    @IBOutlet private weak var titleLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        self.displayAsBodyText()
    }
    
    func inverseColors() {
        self.contentView.backgroundColor = Settings.currentTheme.bodyTextColor
        self.backgroundColor = Settings.currentTheme.bodyTextColor
        self.titleLabel.textColor = Settings.currentTheme.backgroundColor
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
    
    func fill(with string: String) {
        self.titleLabel.text = string
    }
}
