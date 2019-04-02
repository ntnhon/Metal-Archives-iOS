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
    @IBOutlet private weak var ratingLabel: UILabel!
    @IBOutlet private weak var authorLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        self.bandNameLabel.textColor = Settings.currentTheme.titleColor
        self.bandNameLabel.font = Settings.currentFontSize.titleFont
        
        self.albumNameLabel.textColor = Settings.currentTheme.secondaryTitleColor
        self.albumNameLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        self.dateAndTimeLabel.textColor = Settings.currentTheme.bodyTextColor
        self.dateAndTimeLabel.font = Settings.currentFontSize.bodyTextFont
        
        self.ratingLabel.textColor = Settings.currentTheme.bodyTextColor
        self.ratingLabel.font = Settings.currentFontSize.bodyTextFont
        
        self.authorLabel.textColor = Settings.currentTheme.bodyTextColor
        self.authorLabel.font = Settings.currentFontSize.bodyTextFont
    }

    func fill(with latestReview: LatestReview) {
        self.bandNameLabel.text = latestReview.band.name
        self.albumNameLabel.text = latestReview.release.name
        self.dateAndTimeLabel.text = "\(latestReview.dateString), \(latestReview.timeString)"
        
        self.ratingLabel.text = "\(latestReview.rating)%"
        self.ratingLabel.textColor = UIColor.colorByRating(latestReview.rating)
        
        self.authorLabel.text = "Written by \(latestReview.author)"
        
        self.setThumbnailImageView(with: latestReview, placeHolderImageName: Ressources.Images.vinyl)
    }
}
