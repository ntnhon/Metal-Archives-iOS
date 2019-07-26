//
//  LatestReviewOrUpcomingAlbumTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 14/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import SDWebImage

final class LatestReviewTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var bandNameLabel: UILabel!
    @IBOutlet private weak var albumNameLabel: UILabel!
    @IBOutlet private weak var authorAndRatingAndDateLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        bandNameLabel.textColor = Settings.currentTheme.titleColor
        bandNameLabel.font = Settings.currentFontSize.titleFont
        
        albumNameLabel.textColor = Settings.currentTheme.secondaryTitleColor
        albumNameLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        authorAndRatingAndDateLabel.textColor = Settings.currentTheme.bodyTextColor
        authorAndRatingAndDateLabel.font = Settings.currentFontSize.bodyTextFont
    }

    func fill(with latestReview: LatestReview) {
        bandNameLabel.text = latestReview.band.name
        albumNameLabel.text = latestReview.release.title
        authorAndRatingAndDateLabel.attributedText = latestReview.authorAndRatingAndDateAttributedString
        setThumbnailImageView(with: latestReview.release)
    }
}
