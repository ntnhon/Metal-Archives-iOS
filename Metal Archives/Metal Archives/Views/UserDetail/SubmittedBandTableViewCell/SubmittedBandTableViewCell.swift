//
//  SubmittedBandTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 15/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class SubmittedBandTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var bandNameLabel: UILabel!
    @IBOutlet private weak var countryLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var genreLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        bandNameLabel.textColor = Settings.currentTheme.titleColor
        bandNameLabel.font = Settings.currentFontSize.titleFont
        
        countryLabel.textColor = Settings.currentTheme.secondaryTitleColor
        countryLabel.font = Settings.currentFontSize.bodyTextFont
        
        dateLabel.textColor = Settings.currentTheme.bodyTextColor
        dateLabel.font = Settings.currentFontSize.bodyTextFont
        
        genreLabel.textColor = Settings.currentTheme.bodyTextColor
        genreLabel.font = Settings.currentFontSize.italicBodyTextFont
    }

    func bind(with submittedBand: SubmittedBand) {
        bandNameLabel.text = submittedBand.band.name
        countryLabel.text = submittedBand.country.nameAndEmoji
        dateLabel.text = submittedBand.date
        genreLabel.text = submittedBand.genre
        
        setThumbnailImageView(with: submittedBand.band)
    }
}
