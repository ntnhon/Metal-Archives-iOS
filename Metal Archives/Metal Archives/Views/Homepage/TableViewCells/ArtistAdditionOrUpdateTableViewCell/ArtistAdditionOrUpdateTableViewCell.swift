//
//  ArtistAdditionOrUpdateTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 26/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class ArtistAdditionOrUpdateTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var bandsNameLabel: UILabel!
    @IBOutlet private weak var countryAndDateLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        nameLabel.textColor = Settings.currentTheme.titleColor
        nameLabel.font = Settings.currentFontSize.titleFont
        
        bandsNameLabel.textColor = Settings.currentTheme.secondaryTitleColor
        bandsNameLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        countryAndDateLabel.textColor = Settings.currentTheme.bodyTextColor
        countryAndDateLabel.font = Settings.currentFontSize.bodyTextFont
    }

    func fill(with artist: ArtistAdditionOrUpdate) {
        if let combinedNameAttributedString = artist.combinedNameAttributedString {
            nameLabel.attributedText = combinedNameAttributedString
        } else {
            nameLabel.text = artist.nameInBand
        }
        bandsNameLabel.attributedText = artist.bandsNameAttributedString
        countryAndDateLabel.attributedText = artist.countryAndDateAttributedString
        setThumbnailImageView(with: artist)
    }
}
