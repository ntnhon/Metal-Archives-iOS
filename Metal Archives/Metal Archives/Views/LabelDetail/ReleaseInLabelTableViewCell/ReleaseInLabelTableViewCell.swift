//
//  ReleaseInLabelTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 25/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class ReleaseInLabelTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var bandNamesLabel: UILabel!
    @IBOutlet private weak var releaseTitleLabel: UILabel!
    @IBOutlet private weak var formatAndYearLabel: UILabel!
    @IBOutlet private weak var catalogIdAndFormatLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        
        bandNamesLabel.textColor = Settings.currentTheme.titleColor
        bandNamesLabel.font = Settings.currentFontSize.titleFont
        
        releaseTitleLabel.textColor = Settings.currentTheme.secondaryTitleColor
        releaseTitleLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        formatAndYearLabel.textColor = Settings.currentTheme.bodyTextColor
        formatAndYearLabel.font = Settings.currentFontSize.bodyTextFont
        
        catalogIdAndFormatLabel.textColor = Settings.currentTheme.bodyTextColor
        catalogIdAndFormatLabel.font = Settings.currentFontSize.bodyTextFont
        
        descriptionLabel.textColor = Settings.currentTheme.bodyTextColor
        descriptionLabel.font = Settings.currentFontSize.italicBodyTextFont
    }
    
    func fill(with release: ReleaseInLabel) {
        let bandNames = release.bands.map({$0.name})
        
        bandNamesLabel.attributedText = generateAttributedStringFromStrings(bandNames, as: .title, withSeparator: " / ")
        
        releaseTitleLabel.text = release.release.title
        
        var yearString = ""
        if let year = release.year {
            yearString = "\(year)"
        } else {
            yearString = "unknown year"
        }
    
        formatAndYearLabel.text = "\(release.format) • \(yearString)"
        catalogIdAndFormatLabel.text = "\(release.catalogID) • \(release.format)"
        descriptionLabel.text = release.releaseDescription
        setThumbnailImageView(with: release)
    }
}
