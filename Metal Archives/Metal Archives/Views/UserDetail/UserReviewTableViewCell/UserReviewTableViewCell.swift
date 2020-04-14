//
//  UserReviewTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 15/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class UserReviewTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var reviewTitleLabel: UILabel!
    @IBOutlet private weak var bandNamesLabel: UILabel!
    @IBOutlet private weak var releaseTitleLabel: UILabel!
    @IBOutlet private weak var ratingAndDateLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        reviewTitleLabel.textColor = Settings.currentTheme.bodyTextColor
        reviewTitleLabel.font = Settings.currentFontSize.italicBodyTextFont
        
        releaseTitleLabel.textColor = Settings.currentTheme.secondaryTitleColor
        releaseTitleLabel.font = Settings.currentFontSize.secondaryTitleFont
    }
    
    func bind(with userReview: UserReview) {
        reviewTitleLabel.text = userReview.title
        bandNamesLabel.attributedText = userReview.bandsAttributedString
        releaseTitleLabel.text = userReview.release.title
        ratingAndDateLabel.attributedText = userReview.ratingAndDateAttributedString
        setThumbnailImageView(with: userReview.release)
    }
}
