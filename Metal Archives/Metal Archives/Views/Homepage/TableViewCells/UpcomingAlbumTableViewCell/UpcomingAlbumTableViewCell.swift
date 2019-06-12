//
//  UpcomingAlbumTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 20/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class UpcomingAlbumTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var bandsNameLabel: UILabel!
    @IBOutlet private weak var releaseTitleLabel: UILabel!
    @IBOutlet private weak var releaseTypeLabel: UILabel!
    @IBOutlet private weak var genreLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!

    override func initAppearance() {
        super.initAppearance()
        self.bandsNameLabel.textColor = Settings.currentTheme.titleColor
        self.bandsNameLabel.font = Settings.currentFontSize.titleFont
        
        self.releaseTitleLabel.textColor = Settings.currentTheme.secondaryTitleColor
        self.releaseTitleLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        self.releaseTypeLabel.textColor = Settings.currentTheme.bodyTextColor
        self.releaseTypeLabel.font = Settings.currentFontSize.bodyTextFont
        
        self.genreLabel.textColor = Settings.currentTheme.bodyTextColor
        self.genreLabel.font = Settings.currentFontSize.bodyTextFont
        
        self.dateLabel.textColor = Settings.currentTheme.bodyTextColor
        self.dateLabel.font = Settings.currentFontSize.bodyTextFont
    }
    
    func fill(with upcomingAlbum: UpcomingAlbum) {
        let bandNames = upcomingAlbum.bands.map { (band) -> String in
            return band.name
        }
        self.bandsNameLabel.attributedText = generateAttributedStringFromStrings(bandNames, as: .title, withSeparator: " / ")
        
        self.releaseTitleLabel.text = upcomingAlbum.release.title
        self.releaseTypeLabel.text = upcomingAlbum.releaseType.description
        self.genreLabel.text = upcomingAlbum.genre
        self.dateLabel.text = upcomingAlbum.date
        self.setThumbnailImageView(with: upcomingAlbum.release)
    }
}
