//
//  ReleaseBookmarkTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 10/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class ReleaseBookmarkTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var bandNameLabel: UILabel!
    @IBOutlet private weak var releaseTitleLabel: UILabel!
    @IBOutlet private weak var countryLabel: UILabel!
    @IBOutlet private weak var lastModifiedLabel: UILabel!
    @IBOutlet private weak var genreLabel: UILabel!
    @IBOutlet private weak var noteLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        releaseTitleLabel.textColor = Settings.currentTheme.titleColor
        releaseTitleLabel.font = Settings.currentFontSize.titleFont
        
        bandNameLabel.textColor = Settings.currentTheme.secondaryTitleColor
        bandNameLabel.font = Settings.currentFontSize.bodyTextFont
        
        countryLabel.textColor = Settings.currentTheme.secondaryTitleColor
        countryLabel.font = Settings.currentFontSize.bodyTextFont
        
        lastModifiedLabel.textColor = Settings.currentTheme.bodyTextColor
        lastModifiedLabel.font = Settings.currentFontSize.bodyTextFont
        
        genreLabel.textColor = Settings.currentTheme.bodyTextColor
        genreLabel.font = Settings.currentFontSize.italicBodyTextFont
        
        noteLabel.textColor = Settings.currentTheme.bodyTextColor
        noteLabel.font = Settings.currentFontSize.italicBodyTextFont
    }

    func fill(with releaseBookmark: ReleaseBookmark) {
        releaseTitleLabel.text = releaseBookmark.title
        bandNameLabel.text = releaseBookmark.bandName
        countryLabel.text = releaseBookmark.country.nameAndEmoji
        lastModifiedLabel.text = "\(releaseBookmark.lastModified) 🕒"
        genreLabel.text = releaseBookmark.genre
        
        noteLabel.attributedText = releaseBookmark.note
        noteLabel.isHidden = releaseBookmark.note == nil
        
        setThumbnailImageView(with: releaseBookmark)
    }
}

