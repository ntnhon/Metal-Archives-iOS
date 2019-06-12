//
//  SimpleAlbumTitleTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 06/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class SimpleAlbumTitleTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var bandsNameLabel: UILabel!
    @IBOutlet private weak var releaseTitleLabel: UILabel!
    @IBOutlet private weak var typeLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        self.bandsNameLabel.textColor = Settings.currentTheme.titleColor
        self.bandsNameLabel.font = Settings.currentFontSize.titleFont
        
        self.releaseTitleLabel.textColor = Settings.currentTheme.secondaryTitleColor
        self.releaseTitleLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        self.typeLabel.textColor = Settings.currentTheme.bodyTextColor
        self.typeLabel.font = Settings.currentFontSize.bodyTextFont
        
        self.dateLabel.textColor = Settings.currentTheme.bodyTextColor
        self.dateLabel.font = Settings.currentFontSize.bodyTextFont
    }
    
    func fill(with result: SimpleSearchResultAlbumTitle) {
        let bandNames = result.bands.map { (band) -> String in
            return band.name
        }
        
        self.bandsNameLabel.attributedText = generateAttributedStringFromStrings(bandNames, as: .title, withSeparator: " | ")
        
        self.releaseTitleLabel.text = result.release.title
        self.typeLabel.text = result.type
        self.dateLabel.text = result.dateString
        
        self.setThumbnailImageView(with: result.release)
    }
}
