//
//  LatestReviewTableViewCell.swift
//  Metal Archives Widget
//
//  Created by Thanh-Nhon Nguyen on 21/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class LatestReviewTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var bandNameLabel: UILabel!
    @IBOutlet private weak var albumNameLabel: UILabel!
    @IBOutlet private weak var dateAndTimeLabel: UILabel!
    @IBOutlet private weak var ratingLabel: UILabel!
    @IBOutlet private weak var authorLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initAppearance()
    }
    
    private func initAppearance() {
        self.bandNameLabel.textColor = Theme.light.titleColor
        self.bandNameLabel.font = FontSize.default.titleFont
        
        self.albumNameLabel.textColor = Theme.light.bodyTextColor
        self.albumNameLabel.font = FontSize.default.secondaryTitleFont
        
        self.dateAndTimeLabel.textColor = Theme.light.bodyTextColor
        self.dateAndTimeLabel.font = FontSize.default.bodyTextFont
        
        self.ratingLabel.textColor = Theme.light.bodyTextColor
        self.ratingLabel.font = FontSize.default.bodyTextFont
        
        self.authorLabel.textColor = Theme.light.bodyTextColor
        self.authorLabel.font = FontSize.default.bodyTextFont
    }

    func fill(with latestReview: LatestReview) {
        self.bandNameLabel.text = latestReview.band.name
        self.albumNameLabel.text = latestReview.release.title
        self.dateAndTimeLabel.text = "\(latestReview.dateString), \(latestReview.timeString)"
        
        self.ratingLabel.text = "\(latestReview.rating)%"
        self.ratingLabel.textColor = self.colorByRating(latestReview.rating)
        
        self.authorLabel.text = "Written by \(latestReview.author.name)"
        
        self.setThumbnailImageView(with: latestReview.release)
    }
    
    private func colorByRating(_ rating: Int) -> UIColor {
        if rating >= 0 && rating < 25 {
            return Theme.default.splitUpStatusColor
        } else if rating >= 25 && rating < 50 {
            return Theme.default.onHoldStatusColor
        } else if rating >= 50 && rating < 75 {
            return Theme.default.changedNameStatusColor
        }
        
        return Theme.default.activeStatusColor
    }
}
