//
//  AdvancedSongTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 13/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class AdvancedSongTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var bandNameLabel: UILabel!
    @IBOutlet private weak var releaseLabel: UILabel!
    @IBOutlet private weak var detailsLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        self.bandNameLabel.textColor = Settings.currentTheme.titleColor
        self.bandNameLabel.font = Settings.currentFontSize.titleFont
        
        self.releaseLabel.textColor = Settings.currentTheme.secondaryTitleColor
        self.releaseLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        self.detailsLabel.textColor = Settings.currentTheme.bodyTextColor
        self.detailsLabel.font = Settings.currentFontSize.bodyTextFont
    }
    
    func fill(with result: AdvancedSearchResultSong) {
        self.bandNameLabel.text = result.band.name
        self.releaseLabel.text = result.release.name
        
        var detailsString = ""
        result.otherDetails.forEach({
            detailsString += "\($0)\n"
        })
        self.detailsLabel.text = detailsString
        
        self.setThumbnailImageView(with: result.release, placeHolderImageName: Ressources.Images.vinyl)
    }

}
