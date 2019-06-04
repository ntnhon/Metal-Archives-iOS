//
//  BandCurrentRosterTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 25/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class BandCurrentRosterTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var genreLabel: UILabel!
    @IBOutlet private weak var countryLabel: UILabel!

    override func initAppearance() {
        super.initAppearance()
        nameLabel.textColor = Settings.currentTheme.titleColor
        nameLabel.font = Settings.currentFontSize.titleFont
        
        genreLabel.textColor = Settings.currentTheme.bodyTextColor
        genreLabel.font = Settings.currentFontSize.bodyTextFont
        
        countryLabel.textColor = Settings.currentTheme.secondaryTitleColor
        countryLabel.font = Settings.currentFontSize.secondaryTitleFont
    }
    
    func fill(with band: BandCurrentRoster) {
        nameLabel.text = band.name
        genreLabel.text = band.genre
        countryLabel.text = band.country.nameAndEmoji
        setThumbnailImageView(with: band)
    }
}
