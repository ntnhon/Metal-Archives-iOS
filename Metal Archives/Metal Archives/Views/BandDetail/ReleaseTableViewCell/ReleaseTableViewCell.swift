//
//  ReleaseTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 29/05/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class ReleaseTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var releaseTitleLabel: UILabel!
    @IBOutlet private weak var releaseDetailsLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        thumbnailImageViewHeightConstraint.constant = screenWidth / 5
    }
    
    func fill(with release: ReleaseLite) {
        releaseTitleLabel.text = release.title
        releaseDetailsLabel.attributedText = release.attributedDescription
        
        if release.type == .fullLength {
            releaseTitleLabel.textColor = Settings.currentTheme.titleColor
            releaseTitleLabel.font = Settings.currentFontSize.titleFont
        } else {
            releaseTitleLabel.textColor = Settings.currentTheme.bodyTextColor
            releaseTitleLabel.font = Settings.currentFontSize.secondaryTitleFont
        }
        
        setThumbnailImageView(with: release)
    }
}
