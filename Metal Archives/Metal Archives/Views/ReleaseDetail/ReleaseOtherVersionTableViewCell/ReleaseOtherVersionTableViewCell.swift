//
//  ReleaseOtherVersionTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 06/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class ReleaseOtherVersionTableViewCell: BaseTableViewCell, RegisterableCell {
    @IBOutlet private weak var dateAndLabelNameLabel: UILabel!
    @IBOutlet private weak var formatAndCatalogIDLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        dateAndLabelNameLabel.textColor = Settings.currentTheme.bodyTextColor
        dateAndLabelNameLabel.font = Settings.currentFontSize.bodyTextFont
        
        formatAndCatalogIDLabel.textColor = Settings.currentTheme.bodyTextColor
        formatAndCatalogIDLabel.font = Settings.currentFontSize.bodyTextFont
        
        descriptionLabel.textColor = Settings.currentTheme.bodyTextColor
        descriptionLabel.font = Settings.currentFontSize.italicBodyTextFont
    }

    func fill(with release: ReleaseOtherVersion) {
        //Reset background color because background color is changed for 1st other version (this version)
        contentView.backgroundColor = Settings.currentTheme.backgroundColor
        
        dateAndLabelNameLabel.attributedText = release.dateWithAdditionalDetailAndLabelAttributedString
        formatAndCatalogIDLabel.attributedText = release.formatAndCatalogIDAttributedString
        descriptionLabel.text = release.description
    }
    
    func markAsThisVersion() {
        contentView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor.withAlphaComponent(0.7)
    }
}
