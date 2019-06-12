//
//  UpcomingAlbumCollectionViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 13/05/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class UpcomingAlbumCollectionViewCell: ThumbnailableCollectionViewCell, RegisterableCell {
    @IBOutlet private weak var bandsNameLabel: UILabel!
    @IBOutlet private weak var releaseTitleLabel: UILabel!
    @IBOutlet private weak var releaseTypeLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var genreLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!
    
    override func initAppearance() {
        super.initAppearance()
        
        bandsNameLabel.textColor = Settings.currentTheme.titleColor
        bandsNameLabel.font = Settings.currentFontSize.titleFont
        
        releaseTitleLabel.textColor = Settings.currentTheme.secondaryTitleColor
        releaseTitleLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        releaseTypeLabel.textColor = Settings.currentTheme.bodyTextColor
        releaseTypeLabel.font = Settings.currentFontSize.bodyTextFont
        
        genreLabel.textColor = Settings.currentTheme.bodyTextColor
        genreLabel.font = Settings.currentFontSize.bodyTextFont
        
        dateLabel.textColor = Settings.currentTheme.bodyTextColor
        dateLabel.font = Settings.currentFontSize.bodyTextFont
        
        separatorView.backgroundColor = Settings.currentTheme.collectionViewSeparatorColor
    }
    
    func fill(with upcomingAlbum: UpcomingAlbum) {
        let bandNames = upcomingAlbum.bands.map { (band) -> String in
            return band.name
        }
        bandsNameLabel.attributedText = generateAttributedStringFromStrings(bandNames, as: .title, withSeparator: " / ")
        
        releaseTitleLabel.text = upcomingAlbum.release.title
        releaseTypeLabel.text = upcomingAlbum.releaseType.description
        genreLabel.text = upcomingAlbum.genre
        dateLabel.text = upcomingAlbum.date
        setThumbnailImageView(with: upcomingAlbum.release)
    }
    
    func showSeparator(_ show: Bool) {
        separatorView.alpha = show ? 0 : 1
    }
}

