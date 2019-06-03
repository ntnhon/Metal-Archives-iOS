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
        displayAsBodyText()
    }
    
    func inverseColors() {
        contentView.backgroundColor = Settings.currentTheme.bodyTextColor
        backgroundColor = Settings.currentTheme.bodyTextColor
        titleLabel.textColor = Settings.currentTheme.backgroundColor
    }
    
    func displayAsTitle() {
        titleLabel.textColor = Settings.currentTheme.bodyTextColor
        titleLabel.font = Settings.currentFontSize.titleFont
    }
    
    func displayAsSecondaryTitle() {
        titleLabel.textColor = Settings.currentTheme.bodyTextColor
        titleLabel.font = Settings.currentFontSize.secondaryTitleFont
    }
    
    func displayAsBodyText() {
        titleLabel.textColor = Settings.currentTheme.bodyTextColor
        titleLabel.font = Settings.currentFontSize.bodyTextFont
    }
    
    func fill(with string: String) {
        titleLabel.text = string
    }
}
