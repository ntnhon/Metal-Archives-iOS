//
//  SimpleLabelTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 07/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import AttributedLib

final class SimpleLabelTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var labelNameLabel: UILabel!
    @IBOutlet private weak var countryLabel: UILabel!
    @IBOutlet private weak var specialisationLabel: UILabel!
    
    private let labelNameAttributes = Attributes {
        return $0.foreground(color: Settings.currentTheme.titleColor)
            .font(Settings.currentFontSize.titleFont)
    }
    
    private let labelAkaAttributes = Attributes {
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
        self.labelNameLabel.textColor = Settings.currentTheme.titleColor
        self.labelNameLabel.font = Settings.currentFontSize.titleFont
        
        self.countryLabel.textColor = Settings.currentTheme.secondaryTitleColor
        self.countryLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        self.specialisationLabel.textColor = Settings.currentTheme.bodyTextColor
        self.specialisationLabel.font = Settings.currentFontSize.bodyTextFont
    }
    
    func fill(with result: SimpleSearchResultLabelName) {
        if let aka = result.aka {
            self.labelNameLabel.attributedText = result.label.name.at.attributed(with: labelNameAttributes) + " (\(aka))".at.attributed(with: labelAkaAttributes)
        } else {
            self.labelNameLabel.text = result.label.name
        }
        
        if let country = result.country {
            self.countryLabel.text = country.nameAndEmoji
        } else {
            self.countryLabel.text = nil
        }
        
        self.specialisationLabel.text = result.specialisation
        self.setThumbnailImageView(with: result.label)
    }
}
