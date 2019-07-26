//
//  LabelAdditionOrUpdateCollectionViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 13/05/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class LabelAdditionOrUpdateCollectionViewCell: ThumbnailableCollectionViewCell, RegisterableCell {
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var countryAndStatusLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!
    
    override func initAppearance() {
        super.initAppearance()
        nameLabel.font = Settings.currentFontSize.titleFont
        nameLabel.textColor = Settings.currentTheme.titleColor
        
        countryAndStatusLabel.font = Settings.currentFontSize.secondaryTitleFont
        countryAndStatusLabel.textColor = Settings.currentTheme.secondaryTitleColor
        
        dateLabel.font = Settings.currentFontSize.italicBodyTextFont
        dateLabel.textColor = Settings.currentTheme.bodyTextColor
        
        separatorView.backgroundColor = Settings.currentTheme.collectionViewSeparatorColor
    }
    
    func fill(with label: LabelAdditionOrUpdate) {
        nameLabel.text = label.name
        countryAndStatusLabel.attributedText = label.countryAndStatusAttributedString
        dateLabel.text = label.formattedDateString
        setThumbnailImageView(with: label)
    }
    
    func showSeparator(_ show: Bool) {
        separatorView.alpha = show ? 0 : 1
    }
}
