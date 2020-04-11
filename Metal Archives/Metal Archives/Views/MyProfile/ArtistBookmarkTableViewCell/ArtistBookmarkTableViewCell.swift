//
//  ArtistBookmarkTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 11/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class ArtistBookmarkTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var countryLabel: UILabel!
    @IBOutlet private weak var lastModifiedLabel: UILabel!
    @IBOutlet private weak var noteLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        nameLabel.textColor = Settings.currentTheme.titleColor
        nameLabel.font = Settings.currentFontSize.titleFont
        
        countryLabel.textColor = Settings.currentTheme.secondaryTitleColor
        countryLabel.font = Settings.currentFontSize.bodyTextFont
        
        lastModifiedLabel.textColor = Settings.currentTheme.bodyTextColor
        lastModifiedLabel.font = Settings.currentFontSize.bodyTextFont
        
        noteLabel.textColor = Settings.currentTheme.bodyTextColor
        noteLabel.font = Settings.currentFontSize.italicBodyTextFont
    }

    func fill(with artistBookmark: ArtistBookmark) {
        nameLabel.text = artistBookmark.name
        countryLabel.text = artistBookmark.country.nameAndEmoji
        lastModifiedLabel.text = "\(artistBookmark.lastModified) 🕒"
        
        noteLabel.attributedText = artistBookmark.note
        noteLabel.isHidden = artistBookmark.note == nil
        
        setThumbnailImageView(with: artistBookmark)
    }
}

