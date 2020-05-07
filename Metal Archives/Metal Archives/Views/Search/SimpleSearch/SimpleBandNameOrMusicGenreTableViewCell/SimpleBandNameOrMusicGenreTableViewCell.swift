//
//  SimpleBandNameOrMusicGenreTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 05/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import AttributedLib

final class SimpleBandNameOrMusicGenreTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var bandNameLabel: UILabel!
    @IBOutlet private weak var countryLabel: UILabel!
    @IBOutlet private weak var genreLabel: UILabel!
    
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
        self.bandNameLabel.textColor = Settings.currentTheme.titleColor
        self.bandNameLabel.font = Settings.currentFontSize.titleFont
        
        self.countryLabel.textColor = Settings.currentTheme.secondaryTitleColor
        self.countryLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        self.genreLabel.textColor = Settings.currentTheme.bodyTextColor
        self.genreLabel.font = Settings.currentFontSize.bodyTextFont
    }
    
    func fill(with result: SimpleSearchResultBandNameOrMusicGenre) {
        if let aka = result.aka {
            self.bandNameLabel.attributedText = result.band.name.at.attributed(with: bandNameAttributes) + " (\(aka))".at.attributed(with: bandAkaAttributes)
        } else {
            self.bandNameLabel.text = result.band.name
        }
        
        self.countryLabel.text = result.country.nameAndEmoji
        self.genreLabel.text = result.genre
        
        self.setThumbnailImageView(with: result)
    }
}
