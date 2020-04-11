//
//  BandBookmarkTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 10/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class BandBookmarkTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var bandNameLabel: UILabel!
    @IBOutlet private weak var countryLabel: UILabel!
    @IBOutlet private weak var lastModifiedLabel: UILabel!
    @IBOutlet private weak var genreLabel: UILabel!
    @IBOutlet private weak var noteLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        bandNameLabel.textColor = Settings.currentTheme.titleColor
        bandNameLabel.font = Settings.currentFontSize.titleFont
        
        countryLabel.textColor = Settings.currentTheme.secondaryTitleColor
        countryLabel.font = Settings.currentFontSize.bodyTextFont
        
        lastModifiedLabel.textColor = Settings.currentTheme.bodyTextColor
        lastModifiedLabel.font = Settings.currentFontSize.bodyTextFont
        
        genreLabel.textColor = Settings.currentTheme.bodyTextColor
        genreLabel.font = Settings.currentFontSize.italicBodyTextFont
        
        noteLabel.textColor = Settings.currentTheme.bodyTextColor
        noteLabel.font = Settings.currentFontSize.italicBodyTextFont
    }

    func fill(with bandBookmark: BandBookmark) {
        bandNameLabel.text = bandBookmark.name
        countryLabel.text = bandBookmark.country.nameAndEmoji
        lastModifiedLabel.text = "\(bandBookmark.lastModified) 🕒"
        genreLabel.text = bandBookmark.genre
        
        if let note = bandBookmark.note {
            noteLabel.text = "📝 " + note
        }
        noteLabel.isHidden = bandBookmark.note == nil
        
        setThumbnailImageView(with: bandBookmark)
    }
}
