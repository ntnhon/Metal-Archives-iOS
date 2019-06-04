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

    func fill(with release: ReleaseLite) {
        releaseTitleLabel.text = release.title
        releaseDetailsLabel.attributedText = release.attributedDescription
        
        switch release.type {
        case .fullLength:
            releaseTitleLabel.textColor = Settings.currentTheme.titleColor
            releaseTitleLabel.font = Settings.currentFontSize.titleFont
        case .demo:
            releaseTitleLabel.textColor = Settings.currentTheme.bodyTextColor
            releaseTitleLabel.font = Settings.currentFontSize.bodyTextFont
        default:
            releaseTitleLabel.textColor = Settings.currentTheme.secondaryTitleColor
            releaseTitleLabel.font = Settings.currentFontSize.secondaryTitleFont
        }
        
        setThumbnailImageView(with: release)
    }
}
