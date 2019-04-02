//
//  BandPastRosterTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 25/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class BandPastRosterTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var countryLabel: UILabel!
    @IBOutlet private weak var numOfReleasesLabel: UILabel!
    @IBOutlet private weak var genreLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        self.nameLabel.textColor = Settings.currentTheme.titleColor
        self.nameLabel.font = Settings.currentFontSize.titleFont
        
        self.countryLabel.textColor = Settings.currentTheme.secondaryTitleColor
        self.countryLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        self.numOfReleasesLabel.textColor = Settings.currentTheme.bodyTextColor
        self.numOfReleasesLabel.font = Settings.currentFontSize.bodyTextFont
        
        self.genreLabel.textColor = Settings.currentTheme.bodyTextColor
        self.genreLabel.font = Settings.currentFontSize.bodyTextFont
    }
    
    func fill(with band: BandPastRoster) {
        self.nameLabel.text = band.name
        self.countryLabel.text = band.country.nameAndEmoji
        if band.numberOfReleases > 1 {
            self.numOfReleasesLabel.text = "\(band.numberOfReleases) releases"
        } else {
            self.numOfReleasesLabel.text = "\(band.numberOfReleases) release"
        }
        
        self.genreLabel.text = band.genre
        self.setThumbnailImageView(with: band, placeHolderImageName: Ressources.Images.band)
    }
}
