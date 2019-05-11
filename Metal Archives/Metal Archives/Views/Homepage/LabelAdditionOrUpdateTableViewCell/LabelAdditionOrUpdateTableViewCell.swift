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
    @IBOutlet private var countryLabel: UILabel!
    @IBOutlet private var statusLabel: UILabel!
    @IBOutlet private var dateLabel: UILabel!

    override func initAppearance() {
        super.initAppearance()
        self.nameLabel.textColor = Settings.currentTheme.titleColor
        self.nameLabel.font = Settings.currentFontSize.titleFont
        
        self.countryLabel.textColor = Settings.currentTheme.secondaryTitleColor
        self.countryLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        self.statusLabel.textColor = Settings.currentTheme.bodyTextColor
        self.statusLabel.font = Settings.currentFontSize.bodyTextFont
        
        self.dateLabel.textColor = Settings.currentTheme.bodyTextColor
        self.dateLabel.font = Settings.currentFontSize.bodyTextFont
    }
    
    func fill(with label: LabelAdditionOrUpdate) {
        self.nameLabel.text = label.name
        
        if let country = label.country {
            self.countryLabel.text = country.nameAndEmoji
        } else {
            self.countryLabel.text = "Unknown country"
        }
        
        self.statusLabel.text = label.status.description
        self.statusLabel.textColor = label.status.color
        
        
        let (value, unit) = label.updatedDate.distanceFromNow()
        let agoString = "(\(value) \(unit) ago)"
        
        self.dateLabel.text = "\(defaultDateFormatter.string(from: label.updatedDate))" + " " + agoString
        
        self.setThumbnailImageView(with: label)
    }
}
