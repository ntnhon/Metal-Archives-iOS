//
//  ReleaseInLabelTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 25/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class ReleaseInLabelTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var bandsNameLabel: UILabel!
    @IBOutlet private weak var releaseTitleLabel: UILabel!
    @IBOutlet private weak var typeLabel: UILabel!
    @IBOutlet private weak var yearLabel: UILabel!
    @IBOutlet private weak var catalogIDLabel: UILabel!
    @IBOutlet private weak var formatLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        self.bandsNameLabel.textColor = Settings.currentTheme.titleColor
        self.bandsNameLabel.font = Settings.currentFontSize.titleFont
        
        self.releaseTitleLabel.textColor = Settings.currentTheme.secondaryTitleColor
        self.releaseTitleLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        self.typeLabel.textColor = Settings.currentTheme.bodyTextColor
        self.typeLabel.font = Settings.currentFontSize.bodyTextFont
        
        self.yearLabel.textColor =  Settings.currentTheme.bodyTextColor
        self.yearLabel.font = Settings.currentFontSize.bodyTextFont
        
        self.catalogIDLabel.textColor = Settings.currentTheme.bodyTextColor
        self.catalogIDLabel.font = Settings.currentFontSize.bodyTextFont
        
        self.formatLabel.textColor = Settings.currentTheme.bodyTextColor
        self.formatLabel.font = Settings.currentFontSize.bodyTextFont
        
        self.descriptionLabel.textColor = Settings.currentTheme.bodyTextColor
        self.descriptionLabel.font = Settings.currentFontSize.bodyTextFont
    }
    
    func fill(with release: ReleaseInLabel) {
        let bandNames = release.bands.map { (band) -> String in
            return band.name
        }
        self.bandsNameLabel.attributedText = generateAttributedStringFromStrings(bandNames, as: .title, withSeparator: " / ")
        
        self.releaseTitleLabel.text = release.release.name
        self.typeLabel.text = release.type
        
        if let year = release.year {
            self.yearLabel.text = "\(year)"
        } else {
            self.yearLabel.text = "unknown"
        }
        
        self.catalogIDLabel.text = release.catalogID
        self.formatLabel.text = release.format
        self.descriptionLabel.text = release.releaseDescription
        self.setThumbnailImageView(with: release, placeHolderImageName: Ressources.Images.vinyl)
        
    }
}
