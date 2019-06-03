//
//  RolesInReleaseTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class RolesInReleaseTableViewCell: BaseTableViewCell, RegisterableCell {
    @IBOutlet private weak var releaseTitleLabel: UILabel!
    @IBOutlet private weak var yearAndRolesLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()

        releaseTitleLabel.textColor = Settings.currentTheme.secondaryTitleColor
        releaseTitleLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        yearAndRolesLabel.textColor = Settings.currentTheme.bodyTextColor
        yearAndRolesLabel.font = Settings.currentFontSize.bodyTextFont
    }
    
    func fill(with rolesInRelease: RolesInRelease) {
        releaseTitleLabel.attributedText = rolesInRelease.releaseTitleAttributedString
        yearAndRolesLabel.text = "\(rolesInRelease.year!) • \(rolesInRelease.roles!)"
    }
}
