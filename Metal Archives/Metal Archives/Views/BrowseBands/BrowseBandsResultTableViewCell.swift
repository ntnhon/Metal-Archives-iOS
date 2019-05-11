//
//  BrowseBandsResultTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 16/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class BrowseBandsResultTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var bandNameLabel: UILabel!
    @IBOutlet private weak var countryOrLocationLabel: UILabel!
    @IBOutlet private weak var genreLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        self.bandNameLabel.textColor = Settings.currentTheme.titleColor
        self.bandNameLabel.font = Settings.currentFontSize.titleFont
        
        self.countryOrLocationLabel.textColor = Settings.currentTheme.secondaryTitleColor
        self.countryOrLocationLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        self.genreLabel.textColor = Settings.currentTheme.bodyTextColor
        self.genreLabel.font = Settings.currentFontSize.bodyTextFont
        
        self.statusLabel.textColor = Settings.currentTheme.bodyTextColor
        self.statusLabel.font = Settings.currentFontSize.bodyTextFont
    }
    
    func fill(with band: BandBrowse) {
        self.bandNameLabel.text = band.name
        self.countryOrLocationLabel.text = band.countryOrLocation
        self.genreLabel.text = band.genre
        
        self.statusLabel.text = band.status.description
        self.statusLabel.textColor = band.status.color
        
        self.setThumbnailImageView(with: band)
    }
}
