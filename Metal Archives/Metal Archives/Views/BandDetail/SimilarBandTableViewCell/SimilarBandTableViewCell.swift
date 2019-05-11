//
//  SimilarBandTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 04/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class SimilarBandTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var bandNameLabel: UILabel!
    @IBOutlet private weak var similarScoreLabel: UILabel!
    @IBOutlet private weak var countryLabel: UILabel!
    @IBOutlet private weak var genreLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        self.bandNameLabel.textColor = Settings.currentTheme.titleColor
        self.bandNameLabel.font = Settings.currentFontSize.titleFont
        
        self.similarScoreLabel.textColor = Settings.currentTheme.bodyTextColor
        self.similarScoreLabel.font = Settings.currentFontSize.bodyTextFont
        
        self.countryLabel.textColor = Settings.currentTheme.secondaryTitleColor
        self.countryLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        self.genreLabel.textColor = Settings.currentTheme.bodyTextColor
        self.genreLabel.font = Settings.currentFontSize.bodyTextFont
    }

    func bind(band: BandSimilar) {
        self.setThumbnailImageView(with: band)
        self.bandNameLabel.text = band.name
        self.similarScoreLabel.text = "\(band.score)"
        self.countryLabel.text = band.country.nameAndEmoji
        self.genreLabel.text = band.genre
    }
}
