//
//  RolesInBandTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class RolesInBandTableViewCell: BaseTableViewCell, RegisterableCell {
    @IBOutlet private weak var bandNameLabel: UILabel!
    @IBOutlet private weak var rolesAndYearsActiveLabel: UILabel!

    override func initAppearance() {
        super.initAppearance()
        self.hideSeparator()
        self.bandNameLabel.textColor = Settings.currentTheme.titleColor
        self.bandNameLabel.font = Settings.currentFontSize.titleFont
        
        self.rolesAndYearsActiveLabel.textColor = Settings.currentTheme.bodyTextColor
        self.rolesAndYearsActiveLabel.font = Settings.currentFontSize.bodyTextFont
    }
    
    func fill(with rolesInBand: RolesInBand) {
        self.bandNameLabel.text = rolesInBand.bandName.uppercased()
        if let roleAndYearsActive = rolesInBand.roleAndYearsActive {
            self.rolesAndYearsActiveLabel.isHidden = false
            self.rolesAndYearsActiveLabel.text = roleAndYearsActive
        } else {
            self.rolesAndYearsActiveLabel.isHidden = true
        }
    }
}
