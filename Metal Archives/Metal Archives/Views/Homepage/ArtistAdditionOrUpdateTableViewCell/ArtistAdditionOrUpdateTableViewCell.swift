//
//  ArtistAdditionOrUpdateTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 26/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import AttributedLib

final class ArtistAdditionOrUpdateTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var countryLabel: UILabel!
    @IBOutlet private weak var bandsNameLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    
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
        self.nameLabel.textColor = Settings.currentTheme.titleColor
        self.nameLabel.font = Settings.currentFontSize.titleFont
        
        self.countryLabel.textColor = Settings.currentTheme.secondaryTitleColor
        self.countryLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        self.bandsNameLabel.textColor = Settings.currentTheme.secondaryTitleColor
        self.bandsNameLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        self.dateLabel.textColor = Settings.currentTheme.bodyTextColor
        self.dateLabel.font = Settings.currentFontSize.bodyTextFont
    }

    func fill(with artist: ArtistAdditionOrUpdate) {
        if let realFullName = artist.realFullName {
            self.nameLabel.attributedText = artist.nameInBand.at.attributed(with: self.artistNameAttributes) + " (\(realFullName))".at.attributed(with: self.artistRealFullNameAttributes)
        } else {
            self.nameLabel.text = artist.nameInBand
        }
        
        if let country = artist.country {
            self.countryLabel.text = country.nameAndEmoji
        } else {
            self.countryLabel.text = "N/A"
        }

        let bandNames = artist.bands.map { (band) -> String in
            return band.name
        }
        self.bandsNameLabel.attributedText = generateAttributedStringFromStrings(bandNames, as: .secondaryTitle, withSeparator: ", ")
        
        let (value, unit) = artist.updatedDate.distanceFromNow()
        let agoString = "(\(value) \(unit) ago)"
        
        self.dateLabel.text = "\(defaultDateFormatter.string(from: artist.updatedDate))" + " " + agoString
        self.setThumbnailImageView(with: artist)
    }
}
