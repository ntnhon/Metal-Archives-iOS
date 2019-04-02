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
    @IBOutlet private weak var yearLabel: UILabel!
    @IBOutlet private weak var rolesLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        self.hideSeparator()
        self.releaseTitleLabel.textColor = Settings.currentTheme.secondaryTitleColor
        self.releaseTitleLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        self.yearLabel.textColor = Settings.currentTheme.bodyTextColor
        self.yearLabel.font = Settings.currentFontSize.bodyTextFont
        
        self.rolesLabel.textColor = Settings.currentTheme.bodyTextColor
        self.rolesLabel.font = Settings.currentFontSize.bodyTextFont
    }
    
    func fill(with rolesInRelease: RolesInRelease) {
        self.releaseTitleLabel.text = rolesInRelease.releaseTitle
        self.yearLabel.text = "\(rolesInRelease.year!)"
        self.rolesLabel.text = rolesInRelease.roles
    }
}
