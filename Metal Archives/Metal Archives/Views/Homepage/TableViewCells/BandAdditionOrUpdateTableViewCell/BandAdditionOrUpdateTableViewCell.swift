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
    @IBOutlet private weak var countryAndDateLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var genreLabel: UILabel!

    override func initAppearance() {
        super.initAppearance()
        titleLabel.textColor = Settings.currentTheme.titleColor
        titleLabel.font = Settings.currentFontSize.titleFont
        
        countryAndDateLabel.textColor = Settings.currentTheme.secondaryTitleColor
        countryAndDateLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        genreLabel.textColor = Settings.currentTheme.bodyTextColor
        genreLabel.font = Settings.currentFontSize.italicBodyTextFont
    }

    func fill(with band: BandAdditionOrUpdate) {
        titleLabel.text = band.name
        countryAndDateLabel.attributedText = band.countryAndDateAttributedString
        genreLabel.text = band.genre
        setThumbnailImageView(with: band)
    }
}
