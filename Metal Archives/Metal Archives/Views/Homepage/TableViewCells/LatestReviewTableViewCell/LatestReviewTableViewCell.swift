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
    @IBOutlet private weak var dateAndTimeLabel: UILabel!
    @IBOutlet private weak var authorAndRatingLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        bandNameLabel.textColor = Settings.currentTheme.titleColor
        bandNameLabel.font = Settings.currentFontSize.titleFont
        
        albumNameLabel.textColor = Settings.currentTheme.secondaryTitleColor
        albumNameLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        dateAndTimeLabel.textColor = Settings.currentTheme.bodyTextColor
        dateAndTimeLabel.font = Settings.currentFontSize.bodyTextFont
        
        authorAndRatingLabel.textColor = Settings.currentTheme.bodyTextColor
        authorAndRatingLabel.font = Settings.currentFontSize.bodyTextFont
    }

    func fill(with latestReview: LatestReview) {
        bandNameLabel.text = latestReview.band.name
        albumNameLabel.text = latestReview.release.title
        dateAndTimeLabel.text = "\(latestReview.dateString), \(latestReview.timeString)"
        authorAndRatingLabel.attributedText = latestReview.authorAndRatingAttributedString
        setThumbnailImageView(with: latestReview.release)
    }
}
