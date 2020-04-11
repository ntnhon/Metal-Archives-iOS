//
//  LabelBookmarkTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 11/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class LabelBookmarkTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
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

    func fill(with labelBookmark: LabelBookmark) {
        nameLabel.text = labelBookmark.name
        countryLabel.text = labelBookmark.country.nameAndEmoji
        lastModifiedLabel.text = "\(labelBookmark.lastModified) 🕒"
        
        if let note = labelBookmark.note {
            noteLabel.text = "📝 " + note
        }
        noteLabel.isHidden = labelBookmark.note == nil
        
        setThumbnailImageView(with: labelBookmark)
    }
}


