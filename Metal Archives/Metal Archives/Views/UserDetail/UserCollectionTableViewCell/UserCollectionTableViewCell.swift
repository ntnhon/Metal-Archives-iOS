//
//  UserCollectionTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 15/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class UserCollectionTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var bandsLabel: UILabel!
    @IBOutlet private weak var versionLabel: UILabel!
    @IBOutlet private weak var noteLabel: UILabel!
    @IBOutlet private weak var saleImageView: UIImageView!
    
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
        
        saleImageView.tintColor = Settings.currentTheme.iconTintColor
    }

    func fill(with release: UserCollection) {
        titleLabel.attributedText = release.titleAndTypeAttributedString
        bandsLabel.attributedText = release.bandsAttributedString
        versionLabel.text = release.version
        
        if let notes = release.notes {
            noteLabel.text = "📝 " + notes
        }
        noteLabel.isHidden = release.notes == nil
        
        saleImageView.isHidden = !release.forTrade
        
        setThumbnailImageView(with: release.release)
    }
}
