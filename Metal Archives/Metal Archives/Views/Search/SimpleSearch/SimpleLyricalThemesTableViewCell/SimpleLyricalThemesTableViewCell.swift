//
//  SimpleLyricalThemesTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 06/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import AttributedLib

final class SimpleLyricalThemesTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var genreLabel: UILabel!
    @IBOutlet private weak var countryLabel: UILabel!
    @IBOutlet private weak var lyricalThemesLabel: UILabel!
    
    private let bandNameAttributes = Attributes {
        return $0.foreground(color: Settings.currentTheme.titleColor)
            .font(Settings.currentFontSize.titleFont)
    }
    
    private let bandAkaAttributes = Attributes {
        switch Settings.currentTheme {
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
        
        self.genreLabel.textColor = Settings.currentTheme.bodyTextColor
        self.genreLabel.font = Settings.currentFontSize.bodyTextFont
        
        self.countryLabel.textColor = Settings.currentTheme.secondaryTitleColor
        self.countryLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        self.lyricalThemesLabel.textColor = Settings.currentTheme.bodyTextColor
        self.lyricalThemesLabel.font = Settings.currentFontSize.bodyTextFont
    }
    
    func fill(with result: SimpleSearchResultLyricalThemes) {
        if let aka = result.aka {
            self.nameLabel.attributedText = result.band.name.at.attributed(with: bandNameAttributes) + " (\(aka))".at.attributed(with: bandAkaAttributes)
        } else {
            self.nameLabel.text = result.band.name
        }
        
        self.genreLabel.text = result.genre
        self.countryLabel.text = result.country.nameAndEmoji
        self.lyricalThemesLabel.text = "Lyrical themes: \(result.lyricalThemes)"
        self.setThumbnailImageView(with: result.band)
    }
}
