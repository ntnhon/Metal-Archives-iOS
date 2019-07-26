//
//  RolesInReleaseTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class RolesInReleaseTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var releaseTitleLabel: UILabel!
    @IBOutlet private weak var yearLabel: UILabel!
    @IBOutlet private weak var rolesLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        
        yearLabel.textColor = Settings.currentTheme.bodyTextColor
        yearLabel.font = Settings.currentFontSize.bodyTextFont

        releaseTitleLabel.textColor = Settings.currentTheme.secondaryTitleColor
        releaseTitleLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        rolesLabel.textColor = Settings.currentTheme.bodyTextColor
        rolesLabel.font = Settings.currentFontSize.bodyTextFont
    }
    
    func fill(with rolesInRelease: RolesInRelease) {
        releaseTitleLabel.attributedText = rolesInRelease.releaseTitleAttributedString
        yearLabel.text = "\(rolesInRelease.year ?? 0)"
        rolesLabel.text = rolesInRelease.roles
        setThumbnailImageView(with: rolesInRelease.release)
    }
}
