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
        bandNameLabel.textColor = Settings.currentTheme.titleColor
        bandNameLabel.font = Settings.currentFontSize.titleFont
        
        rolesAndYearsActiveLabel.textColor = Settings.currentTheme.bodyTextColor
        rolesAndYearsActiveLabel.font = Settings.currentFontSize.bodyTextFont
    }
    
    func fill(with rolesInBand: RolesInBand) {
        bandNameLabel.text = rolesInBand.bandName.uppercased()
        if let roleAndYearsActive = rolesInBand.roleAndYearsActive {
            rolesAndYearsActiveLabel.isHidden = false
            rolesAndYearsActiveLabel.text = roleAndYearsActive
        } else {
            rolesAndYearsActiveLabel.isHidden = true
        }
    }
}
