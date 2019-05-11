//
//  ReviewTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 03/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class ReviewTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var releaseTitleLabel: UILabel!
    @IBOutlet private weak var ratingLabel: UILabel!
    @IBOutlet private weak var authorAndDateLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        self.releaseTitleLabel.textColor = Settings.currentTheme.titleColor
        self.releaseTitleLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        self.ratingLabel.textColor = Settings.currentTheme.bodyTextColor
        self.ratingLabel.font = Settings.currentFontSize.bodyTextFont
        
        self.authorAndDateLabel.textColor = Settings.currentTheme.bodyTextColor
        self.authorAndDateLabel.font = Settings.currentFontSize.bodyTextFont
    }
    
    func fill(with review: ReviewLite) {
        self.releaseTitleLabel.text = review.releaseTitle
        
        if let release = review.release {
            self.setThumbnailImageView(with: release)
        } else {
            self.thumbnailImageView.image = UIImage(named: Ressources.Images.vinyl)
        }
        
        self.authorAndDateLabel.text = "By \(review.author) on \(review.dateString)"
        self.ratingLabel.text = "\(review.rating)%"
        self.ratingLabel.textColor = UIColor.colorByRating(review.rating)
    }
}
