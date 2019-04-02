//
//  ArtistRIPTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit


final class ArtistRIPTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var countryLabel: UILabel!
    @IBOutlet private weak var bandsNameLabel: UILabel!
    @IBOutlet private weak var dateOfDeathLabel: UILabel!
    @IBOutlet private weak var causeOfDeathLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        self.nameLabel.textColor = Settings.currentTheme.titleColor
        self.nameLabel.font = Settings.currentFontSize.titleFont
        
        self.countryLabel.textColor = Settings.currentTheme.bodyTextColor
        self.countryLabel.font = Settings.currentFontSize.bodyTextFont
        
        self.bandsNameLabel.textColor = Settings.currentTheme.secondaryTitleColor
        self.bandsNameLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        self.dateOfDeathLabel.textColor = Settings.currentTheme.bodyTextColor
        self.dateOfDeathLabel.font = Settings.currentFontSize.bodyTextFont
        
        self.causeOfDeathLabel.textColor = Settings.currentTheme.bodyTextColor
        self.causeOfDeathLabel.font = Settings.currentFontSize.bodyTextFont
    }
    
    func fill(with artist: ArtistRIP) {
        self.nameLabel.text = artist.name
        
        if let country = artist.country {
            self.countryLabel.text = country.nameAndEmoji
        } else {
            self.countryLabel.text = "Unknown country"
        }
        
        let bandNames = artist.bands.map { (band) -> String in
            return band.name
        }
        
        self.bandsNameLabel.attributedText = generateAttributedStringFromStrings(bandNames, as: .secondaryTitle, withSeparator: ", ")
        
        self.dateOfDeathLabel.text = "R.I.P: \(artist.dateOfDeath)"
        self.causeOfDeathLabel.text = artist.causeOfDeath
        
        self.setThumbnailImageView(with: artist, placeHolderImageName: Ressources.Images.person)
    }
}
