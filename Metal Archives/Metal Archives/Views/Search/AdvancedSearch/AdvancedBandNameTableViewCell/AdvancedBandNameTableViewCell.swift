//
//  AdvancedBandNameTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 12/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class AdvancedBandNameTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var bandNameLabel: UILabel!
    @IBOutlet private weak var detailsLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        self.bandNameLabel.textColor = Settings.currentTheme.titleColor
        self.bandNameLabel.font = Settings.currentFontSize.titleFont
        
        self.detailsLabel.textColor = Settings.currentTheme.bodyTextColor
        self.detailsLabel.font = Settings.currentFontSize.bodyTextFont
    }
    
    func fill(with result: AdvancedSearchResultBand) {
        self.bandNameLabel.text = result.band.name
        
        var detailsString = ""
        if let aka = result.akaString {
            detailsString += "(\(aka))\n"
        }
        
        result.otherDetails.forEach({
            detailsString += "\($0)\n"
        })
        self.detailsLabel.text = detailsString
        
        self.setThumbnailImageView(with: result.band)
    }
}
