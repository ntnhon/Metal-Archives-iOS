//
//  LatestAdditionOrUpdateTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 14/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import SDWebImage

final class BandAdditionOrUpdateTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var countryLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var genreLabel: UILabel!

    override func initAppearance() {
        super.initAppearance()
        self.titleLabel.textColor = Settings.currentTheme.titleColor
        self.titleLabel.font = Settings.currentFontSize.titleFont
        
        self.dateLabel.textColor = Settings.currentTheme.bodyTextColor
        self.dateLabel.font = Settings.currentFontSize.bodyTextFont
        
        self.countryLabel.textColor = Settings.currentTheme.secondaryTitleColor
        self.countryLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        self.genreLabel.textColor = Settings.currentTheme.bodyTextColor
        self.genreLabel.font = Settings.currentFontSize.bodyTextFont
    }

    func fill(with band: BandAdditionOrUpdate) {
        self.titleLabel.text = band.name
        self.dateLabel.text = band.updatedDateAndTimeString
        self.countryLabel.text = band.country.nameAndEmoji
        self.genreLabel.text = band.genre
        self.setThumbnailImageView(with: band)
    }
}
