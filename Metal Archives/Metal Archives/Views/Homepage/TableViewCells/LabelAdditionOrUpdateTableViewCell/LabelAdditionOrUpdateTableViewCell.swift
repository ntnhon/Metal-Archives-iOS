//
//  LabelAdditionOrUpdateTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 26/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class LabelAdditionOrUpdateTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var countryAndStatusLabel: UILabel!
    @IBOutlet private var dateLabel: UILabel!

    override func initAppearance() {
        super.initAppearance()
        nameLabel.textColor = Settings.currentTheme.titleColor
        nameLabel.font = Settings.currentFontSize.titleFont
        
        countryAndStatusLabel.textColor = Settings.currentTheme.secondaryTitleColor
        countryAndStatusLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        dateLabel.textColor = Settings.currentTheme.bodyTextColor
        dateLabel.font = Settings.currentFontSize.italicBodyTextFont
    }
    
    func fill(with label: LabelAdditionOrUpdate) {
        nameLabel.text = label.name
        countryAndStatusLabel.attributedText = label.countryAndStatusAttributedString
        dateLabel.text = label.formattedDateString
        setThumbnailImageView(with: label)
    }
}
