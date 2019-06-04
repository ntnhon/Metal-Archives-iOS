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
    @IBOutlet private weak var countryAndNumOfReleasesLabel: UILabel!
    @IBOutlet private weak var genreLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        nameLabel.textColor = Settings.currentTheme.titleColor
        nameLabel.font = Settings.currentFontSize.titleFont
        
        countryAndNumOfReleasesLabel.textColor = Settings.currentTheme.secondaryTitleColor
        countryAndNumOfReleasesLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        genreLabel.textColor = Settings.currentTheme.bodyTextColor
        genreLabel.font = Settings.currentFontSize.bodyTextFont
    }
    
    func fill(with band: BandPastRoster) {
        nameLabel.text = band.name
        countryAndNumOfReleasesLabel.attributedText = band.countryAndNumOfReleasesAttributedString
        genreLabel.text = band.genre
        setThumbnailImageView(with: band)
    }
}
