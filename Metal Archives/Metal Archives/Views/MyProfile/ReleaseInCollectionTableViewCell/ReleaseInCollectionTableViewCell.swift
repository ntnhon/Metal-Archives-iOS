//
//  ReleaseInCollectionTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 11/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class ReleaseInCollectionTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var bandsLabel: UILabel!
    @IBOutlet private weak var versionLabel: UILabel!
    @IBOutlet private weak var noteLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        titleLabel.textColor = Settings.currentTheme.titleColor
        titleLabel.font = Settings.currentFontSize.titleFont
        
        bandsLabel.textColor = Settings.currentTheme.secondaryTitleColor
        bandsLabel.font = Settings.currentFontSize.bodyTextFont
        
        versionLabel.textColor = Settings.currentTheme.bodyTextColor
        versionLabel.font = Settings.currentFontSize.bodyTextFont
        
        noteLabel.textColor = Settings.currentTheme.bodyTextColor
        noteLabel.font = Settings.currentFontSize.italicBodyTextFont
    }

    func fill(with release: ReleaseInCollection) {
        titleLabel.text = release.release.title
        bandsLabel.attributedText = release.bandsAttributedString
        versionLabel.attributedText = release.versionAndTypeAttributedString
        
        if let note = release.note {
            noteLabel.text = "📝 " + note
        }
        noteLabel.isHidden = release.note == nil
        
        setThumbnailImageView(with: release)
    }
}
