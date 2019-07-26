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
    @IBOutlet private weak var releaseTypeAndDateLabel: UILabel!
    @IBOutlet private weak var genreLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!
    
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
        
        separatorView.backgroundColor = Settings.currentTheme.collectionViewSeparatorColor
    }
    
    func fill(with upcomingAlbum: UpcomingAlbum) {
        bandsNameLabel.attributedText = upcomingAlbum.combinedBandNamesAttributedString
        releaseTitleLabel.text = upcomingAlbum.release.title
        releaseTypeAndDateLabel.attributedText = upcomingAlbum.typeAndDateAttributedString
        genreLabel.text = upcomingAlbum.genre
        setThumbnailImageView(with: upcomingAlbum.release)
    }
    
    func showSeparator(_ show: Bool) {
        separatorView.alpha = show ? 0 : 1
    }
}

