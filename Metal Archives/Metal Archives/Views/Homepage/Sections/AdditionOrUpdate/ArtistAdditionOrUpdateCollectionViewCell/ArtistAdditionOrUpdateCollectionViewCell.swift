//
//  ArtistAdditionOrUpdateCollectionViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 13/05/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import AttributedLib

final class ArtistAdditionOrUpdateCollectionViewCell: ThumbnailableCollectionViewCell, RegisterableCell {
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var countryLabel: UILabel!
    @IBOutlet private weak var bandsNameLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!
    
    private let artistNameAttributes = Attributes {
        return $0.foreground(color: Settings.currentTheme.titleColor)
            .font(Settings.currentFontSize.titleFont)
    }
    
    private let artistRealFullNameAttributes = Attributes {
        switch Settings.currentTheme! {
        case .default:
            return $0.foreground(color: Settings.currentTheme.bodyTextColor)
                .font(Settings.currentFontSize.titleFont)
        default:
            return $0.foreground(color: Settings.currentTheme.secondaryTitleColor)
                .font(Settings.currentFontSize.titleFont)
        }
    }
    
    override func initAppearance() {
        super.initAppearance()
        nameLabel.font = Settings.currentFontSize.titleFont
        nameLabel.textColor = Settings.currentTheme.titleColor
        
        countryLabel.font = Settings.currentFontSize.secondaryTitleFont
        countryLabel.textColor = Settings.currentTheme.bodyTextColor
        countryLabel.lineBreakMode = .byTruncatingMiddle
        
        dateLabel.font = Settings.currentFontSize.bodyTextFont
        dateLabel.textColor = Settings.currentTheme.bodyTextColor
        
        bandsNameLabel.font = Settings.currentFontSize.secondaryTitleFont
        bandsNameLabel.textColor = Settings.currentTheme.secondaryTitleColor
        
        separatorView.backgroundColor = Settings.currentTheme.collectionViewSeparatorColor
    }
    
    func fill(with artist: ArtistAdditionOrUpdate) {
        if let realFullName = artist.realFullName {
            nameLabel.attributedText = artist.nameInBand.at.attributed(with: artistNameAttributes) + " (\(realFullName))".at.attributed(with: artistRealFullNameAttributes)
        } else {
            nameLabel.text = artist.nameInBand
        }
        
        if let country = artist.country {
            countryLabel.text = country.nameAndEmoji
        } else {
            countryLabel.text = "N/A"
        }
        
        let bandNames = artist.bands.map { (band) -> String in
            return band.name
        }
        bandsNameLabel.attributedText = generateAttributedStringFromStrings(bandNames, as: .secondaryTitle, withSeparator: ", ")
        
        let (value, unit) = artist.updatedDate.distanceFromNow()
        dateLabel.text = "\(value) \(unit) ago"
        
        setThumbnailImageView(with: artist)
    }
    
    func showSeparator(_ show: Bool) {
        separatorView.alpha = show ? 0 : 1
    }
}
