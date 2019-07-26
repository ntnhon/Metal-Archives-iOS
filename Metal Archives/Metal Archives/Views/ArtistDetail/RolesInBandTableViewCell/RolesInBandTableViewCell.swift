//
//  RolesInBandTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class RolesInBandTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var bandNameLabel: UILabel!
    @IBOutlet private weak var rolesAndYearsActiveLabel: UILabel!

    override func initAppearance() {
        super.initAppearance()
        separatorView.backgroundColor = Settings.currentTheme.tableViewSeparatorColor
        
        bandNameLabel.textColor = Settings.currentTheme.titleColor
        bandNameLabel.font = Settings.currentFontSize.titleFont
        
        rolesAndYearsActiveLabel.textColor = Settings.currentTheme.bodyTextColor
        rolesAndYearsActiveLabel.font = Settings.currentFontSize.bodyTextFont
    }
    
    func fill(with rolesInBand: RolesInBand) {
        bandNameLabel.text = rolesInBand.band.name.uppercased()
        if let _ = rolesInBand.band.urlString {
            bandNameLabel.textColor = Settings.currentTheme.titleColor
        } else {
            bandNameLabel.textColor = Settings.currentTheme.bodyTextColor
        }
        
        if let _ = rolesInBand.roleAndYearsActive {
            rolesAndYearsActiveLabel.isHidden = false
            rolesAndYearsActiveLabel.attributedText = rolesInBand.roleAndYearsActiveAttributedString
        } else {
            rolesAndYearsActiveLabel.isHidden = true
        }
        
        if let thumbnailableBand = rolesInBand.thumbnailableBand {
            setThumbnailImageView(with: thumbnailableBand)
        }
    }
}
