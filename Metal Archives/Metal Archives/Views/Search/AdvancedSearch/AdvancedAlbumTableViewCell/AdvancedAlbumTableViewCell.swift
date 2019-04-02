//
//  AdvancedAlbumTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 13/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class AdvancedAlbumTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var bandsNameLabel: UILabel!
    @IBOutlet private weak var releaseLabel: UILabel!
    @IBOutlet private weak var detailsLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        self.bandsNameLabel.textColor = Settings.currentTheme.titleColor
        self.bandsNameLabel.font = Settings.currentFontSize.titleFont
        
        self.releaseLabel.textColor = Settings.currentTheme.secondaryTitleColor
        self.releaseLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        self.detailsLabel.textColor = Settings.currentTheme.bodyTextColor
        self.detailsLabel.font = Settings.currentFontSize.bodyTextFont
    }

    func fill(with result: AdvancedSearchResultAlbum) {
        let bandNames = result.bands.map { (band) -> String in
            return band.name
        }
        self.bandsNameLabel.attributedText = generateAttributedStringFromStrings(bandNames, as: .title, withSeparator: " | ")
        
        self.releaseLabel.text = result.release.name
        
        var detailsString = ""
        result.otherDetails.forEach({
            detailsString += "\($0)\n"
        })
        self.detailsLabel.text = detailsString
        
        self.setThumbnailImageView(with: result.release, placeHolderImageName: Ressources.Images.vinyl)
    }
}
