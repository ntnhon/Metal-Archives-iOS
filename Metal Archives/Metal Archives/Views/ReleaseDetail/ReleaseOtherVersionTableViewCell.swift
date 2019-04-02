//
//  ReleaseOtherVersionTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 06/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class ReleaseOtherVersionTableViewCell: BaseTableViewCell, RegisterableCell {
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var labelLabel: UILabel!
    @IBOutlet private weak var catalogIDAndDescriptionLabel: UILabel!
    @IBOutlet private weak var formatLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        self.dateLabel.textColor = Settings.currentTheme.titleColor
        self.dateLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        self.labelLabel.textColor = Settings.currentTheme.bodyTextColor
        self.labelLabel.font = Settings.currentFontSize.bodyTextFont
    
        self.catalogIDAndDescriptionLabel.textColor = Settings.currentTheme.bodyTextColor
        self.catalogIDAndDescriptionLabel.font = Settings.currentFontSize.bodyTextFont
        
        self.formatLabel.textColor = Settings.currentTheme.bodyTextColor
        self.formatLabel.font = Settings.currentFontSize.bodyTextFont
    }

    func fill(with release: ReleaseOtherVersion) {
        //Reset background color because background color is changed for 1st other version (this version)
        self.contentView.backgroundColor = Settings.currentTheme.backgroundColor
        
        self.dateLabel.text = release.dateString + "" + release.additionalDetail
        self.labelLabel.text = release.labelName
        self.formatLabel.text = release.format
        
        
        //Workaround to make sure there is no empty new line at the 2nd row in case there is something nil between catalodID and description
        var catalogIDAndDescriptionString = ""
        if let catalogID = release.catalogID {
            if catalogIDAndDescriptionString != "" {
                catalogIDAndDescriptionString = catalogIDAndDescriptionString + "\n" + catalogID
            } else {
                catalogIDAndDescriptionString = catalogID
            }
        }
        
        if let descriptionString = release.description {
            if catalogIDAndDescriptionString != "" {
                catalogIDAndDescriptionString = catalogIDAndDescriptionString + "\n" + descriptionString
            } else {
                catalogIDAndDescriptionString = descriptionString
            }
        }
        
        self.catalogIDAndDescriptionLabel.text = catalogIDAndDescriptionString
        
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    func markAsThisVersion() {
        self.contentView.backgroundColor = Settings.currentTheme.bodyTextColor.withAlphaComponent(0.3)
    }
}
