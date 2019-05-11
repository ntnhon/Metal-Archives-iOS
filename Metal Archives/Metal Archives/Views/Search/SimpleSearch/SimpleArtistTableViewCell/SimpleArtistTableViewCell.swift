//
//  SimpleArtistTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 07/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import AttributedLib

final class SimpleArtistTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var artistNameLabel: UILabel!
    @IBOutlet private weak var realNameLabel: UILabel!
    @IBOutlet private weak var countryLabel: UILabel!
    @IBOutlet private weak var bandsNameLabel: UILabel!
    
    private let artistNameAttributes = Attributes {
        return $0.foreground(color: Settings.currentTheme.titleColor)
                .font(Settings.currentFontSize.titleFont)
    }
    
    private let artistAkaAttributes = Attributes {
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
        self.artistNameLabel.textColor = Settings.currentTheme.titleColor
        self.artistNameLabel.font = Settings.currentFontSize.titleFont
        
        self.realNameLabel.textColor = Settings.currentTheme.bodyTextColor
        self.realNameLabel.font = Settings.currentFontSize.bodyTextFont
        
        self.countryLabel.textColor = Settings.currentTheme.secondaryTitleColor
        self.countryLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        self.bandsNameLabel.textColor = Settings.currentTheme.secondaryTitleColor
        self.bandsNameLabel.font = Settings.currentFontSize.secondaryTitleFont
    }
    
    func fill(with result: SimpleSearchResultArtist) {
        if let aka = result.aka {
            self.artistNameLabel.attributedText = result.artist.name.at.attributed(with: self.artistNameAttributes) + " (\(aka))".at.attributed(with: self.artistAkaAttributes)
        } else {
            self.artistNameLabel.text = result.artist.name
        }
        
        self.realNameLabel.text = result.realName
        
        if let country = result.country {
            self.countryLabel.text = country.nameAndEmoji
        } else {
            self.countryLabel.text = nil
        }
        
        let bandNames = result.bands.map { (band) -> String in
            return band.name
        }
        self.bandsNameLabel.attributedText = generateAttributedStringFromStrings(bandNames, as: .secondaryTitle, withSeparator: ", ")
        
        self.setThumbnailImageView(with: result.artist)
    }
}
