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
        
        bandNameLabel.textColor = Settings.currentTheme.titleColor
        bandNameLabel.font = Settings.currentFontSize.titleFont
        
        similarScoreLabel.textColor = Settings.currentTheme.bodyTextColor
        similarScoreLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        countryLabel.textColor = Settings.currentTheme.secondaryTitleColor
        countryLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        genreLabel.textColor = Settings.currentTheme.bodyTextColor
        genreLabel.font = Settings.currentFontSize.bodyTextFont
    }

    func fill(with band: BandSimilar) {
        setThumbnailImageView(with: band)
        bandNameLabel.text = band.name
        
        similarScoreLabel.text = "\(band.score)"
        similarScoreLabel.textColor = UIColor.colorByRating(band.score)
        
        countryLabel.text = band.country.nameAndEmoji
        genreLabel.text = band.genre
    }
}
