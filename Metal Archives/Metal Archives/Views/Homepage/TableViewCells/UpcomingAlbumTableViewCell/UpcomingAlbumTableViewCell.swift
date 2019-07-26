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
    @IBOutlet private weak var releaseTypeAndDateLabel: UILabel!
    @IBOutlet private weak var genreLabel: UILabel!

    override func initAppearance() {
        super.initAppearance()
        bandsNameLabel.textColor = Settings.currentTheme.titleColor
        bandsNameLabel.font = Settings.currentFontSize.titleFont
        
        releaseTitleLabel.textColor = Settings.currentTheme.secondaryTitleColor
        releaseTitleLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        releaseTypeAndDateLabel.textColor = Settings.currentTheme.bodyTextColor
        releaseTypeAndDateLabel.font = Settings.currentFontSize.bodyTextFont
        
        genreLabel.textColor = Settings.currentTheme.bodyTextColor
        genreLabel.font = Settings.currentFontSize.italicBodyTextFont
    }
    
    func fill(with upcomingAlbum: UpcomingAlbum) {
        bandsNameLabel.attributedText = upcomingAlbum.combinedBandNamesAttributedString
        releaseTitleLabel.text = upcomingAlbum.release.title
        releaseTypeAndDateLabel.attributedText = upcomingAlbum.typeAndDateAttributedString
        genreLabel.text = upcomingAlbum.genre
        setThumbnailImageView(with: upcomingAlbum.release)
    }
}
