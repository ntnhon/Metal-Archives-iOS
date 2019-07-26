//
//  ArtistAdditionOrUpdateCollectionViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 13/05/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class ArtistAdditionOrUpdateCollectionViewCell: ThumbnailableCollectionViewCell, RegisterableCell {
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var bandsNameLabel: UILabel!
    @IBOutlet private weak var countryAndDateLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!
    
    override func initAppearance() {
        super.initAppearance()
        nameLabel.font = Settings.currentFontSize.titleFont
        nameLabel.textColor = Settings.currentTheme.titleColor
        
        bandsNameLabel.font = Settings.currentFontSize.secondaryTitleFont
        bandsNameLabel.textColor = Settings.currentTheme.secondaryTitleColor
        
        countryAndDateLabel.font = Settings.currentFontSize.bodyTextFont
        countryAndDateLabel.textColor = Settings.currentTheme.bodyTextColor
        
        separatorView.backgroundColor = Settings.currentTheme.collectionViewSeparatorColor
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
    
    func showSeparator(_ show: Bool) {
        separatorView.alpha = show ? 0 : 1
    }
}
