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
    @IBOutlet private weak var countryLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!
    
    override func initAppearance() {
        super.initAppearance()
        nameLabel.font = Settings.currentFontSize.titleFont
        nameLabel.textColor = Settings.currentTheme.titleColor
        
        countryLabel.font = Settings.currentFontSize.secondaryTitleFont
        countryLabel.textColor = Settings.currentTheme.secondaryTitleColor
        
        dateLabel.font = Settings.currentFontSize.bodyTextFont
        dateLabel.textColor = Settings.currentTheme.bodyTextColor
        
        statusLabel.textColor = Settings.currentTheme.bodyTextColor
        statusLabel.font = Settings.currentFontSize.bodyTextFont
        
        separatorView.backgroundColor = Settings.currentTheme.collectionViewSeparatorColor
    }
    
    func fill(with label: LabelAdditionOrUpdate) {
        self.nameLabel.text = label.name
        
        if let country = label.country {
            countryLabel.text = country.nameAndEmoji
        } else {
            countryLabel.text = "Unknown country"
        }
        
        statusLabel.text = label.status.description
        statusLabel.textColor = label.status.color
        
        
        let (value, unit) = label.updatedDate.distanceFromNow()
        let agoString = "(\(value) \(unit) ago)"
        
        dateLabel.text = "\(defaultDateFormatter.string(from: label.updatedDate))" + " " + agoString
        
        setThumbnailImageView(with: label)
    }
    
    func showSeparator(_ show: Bool) {
        separatorView.alpha = show ? 0 : 1
    }
}
