//
//  ReleaseReviewTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 06/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class ReleaseReviewTableViewCell: BaseTableViewCell, RegisterableCell {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var authorAndDateLabel: UILabel!
    @IBOutlet private var ratingLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        self.titleLabel.textColor = Settings.currentTheme.titleColor
        self.titleLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        self.authorAndDateLabel.textColor = Settings.currentTheme.bodyTextColor
        self.authorAndDateLabel.font = Settings.currentFontSize.bodyTextFont
        
        self.ratingLabel.font = Settings.currentFontSize.bodyTextFont
    }
    
    func full(with review: ReviewLiteInRelease) {
        self.titleLabel.text = review.title
        self.authorAndDateLabel.text = "Written by \(review.author) on \(review.dateString)"
        self.ratingLabel.text = "\(review.rating)%"
        self.ratingLabel.textColor = UIColor.colorByRating(review.rating)
    }
}
