//
//  BrowseLabelsAlphabeticallyResultTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 20/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class BrowseLabelsAlphabeticallyResultTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var specialisationLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var countryLabel: UILabel!
    @IBOutlet private weak var websiteLabel: UILabel!
    @IBOutlet private weak var onlineShoppingLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        self.nameLabel.textColor = Settings.currentTheme.titleColor
        self.nameLabel.font = Settings.currentFontSize.titleFont
        
        self.specialisationLabel.textColor = Settings.currentTheme.bodyTextColor
        self.specialisationLabel.font = Settings.currentFontSize.bodyTextFont
        
        self.statusLabel.textColor = Settings.currentTheme.bodyTextColor
        self.statusLabel.font = Settings.currentFontSize.bodyTextFont
        
        self.countryLabel.textColor = Settings.currentTheme.bodyTextColor
        self.countryLabel.font = Settings.currentFontSize.bodyTextFont
        
        self.websiteLabel.textColor = Settings.currentTheme.bodyTextColor
        self.websiteLabel.font = Settings.currentFontSize.bodyTextFont
        
        self.onlineShoppingLabel.textColor = Settings.currentTheme.bodyTextColor
        self.onlineShoppingLabel.font = Settings.currentFontSize.bodyTextFont
    }
    
    func fill(with label: LabelBrowseAlphabetically) {
        self.nameLabel.text = label.name
        self.specialisationLabel.text = label.specialisation
        
        self.statusLabel.text = label.status.description
        self.statusLabel.textColor = label.status.color
        
        if let country = label.country {
            self.countryLabel.text = country.nameAndEmoji
        } else {
            self.countryLabel.text = "Unknown country"
        }
        
        if let _ = label.websiteURLString {
            self.websiteLabel.text = "Website available"
            self.websiteLabel.textColor = Settings.currentTheme.secondaryTitleColor
        } else {
            self.websiteLabel.text = "Unknown website"
            self.websiteLabel.textColor = Settings.currentTheme.bodyTextColor
        }
        
        if label.onlineShopping {
            self.onlineShoppingLabel.text = "Online shopping available"
            self.onlineShoppingLabel.textColor = Settings.currentTheme.secondaryTitleColor
        } else {
            self.onlineShoppingLabel.text = "Online shopping not available"
            self.onlineShoppingLabel.textColor = Settings.currentTheme.bodyTextColor
        }
        
        self.setThumbnailImageView(with: label)
    }
}
