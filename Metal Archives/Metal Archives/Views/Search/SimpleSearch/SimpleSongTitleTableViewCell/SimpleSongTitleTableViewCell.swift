//
//  SimpleSongTitleTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 07/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class SimpleSongTitleTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var bandNameLabel: UILabel!
    @IBOutlet private weak var releaseTitleLabel: UILabel!
    @IBOutlet private weak var typeLabel: UILabel!
    @IBOutlet private weak var songTitleLabel: UILabel!
    
    
    override func initAppearance() {
        super.initAppearance()
        self.bandNameLabel.textColor = Settings.currentTheme.titleColor
        self.bandNameLabel.font = Settings.currentFontSize.titleFont
        
        self.releaseTitleLabel.textColor = Settings.currentTheme.secondaryTitleColor
        self.releaseTitleLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        self.typeLabel.textColor = Settings.currentTheme.bodyTextColor
        self.typeLabel.font = Settings.currentFontSize.bodyTextFont
        
        self.songTitleLabel.textColor = Settings.currentTheme.bodyTextColor
        self.songTitleLabel.font = Settings.currentFontSize.bodyTextFont
    }
    
    func fill(with result: SimpleSearchResultSongTitle) {
        self.bandNameLabel.text = result.band.name
        self.releaseTitleLabel.text = result.release.name
        self.typeLabel.text = result.type
        self.songTitleLabel.text = result.title
        
        if let _ = result.band.urlString {
            self.bandNameLabel.textColor = Settings.currentTheme.titleColor
        } else {
            self.bandNameLabel.textColor = Settings.currentTheme.bodyTextColor
        }
        
        self.setThumbnailImageView(with: result.release)
    }
}

