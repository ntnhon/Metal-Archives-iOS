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
    @IBOutlet private weak var ratingAndUserLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!

    override func initAppearance() {
        super.initAppearance()
        releaseTitleLabel.font = Settings.currentFontSize.bodyTextFont
        releaseTitleLabel.textColor = Settings.currentTheme.bodyTextColor
        
        ratingAndUserLabel.font = Settings.currentFontSize.bodyTextFont
        ratingAndUserLabel.textColor = Settings.currentTheme.bodyTextColor
        
        dateLabel.font = Settings.currentFontSize.bodyTextFont
        dateLabel.textColor = Settings.currentTheme.bodyTextColor
    }
    
    func fill(with review: ReviewLite) {
        releaseTitleLabel.text = review.releaseTitle
        
        if let release = review.release {
            switch release.type {
            case .fullLength:
                releaseTitleLabel.textColor = Settings.currentTheme.titleColor
                releaseTitleLabel.font = Settings.currentFontSize.titleFont
            case .demo:
                releaseTitleLabel.textColor = Settings.currentTheme.bodyTextColor
                releaseTitleLabel.font = Settings.currentFontSize.bodyTextFont
            default:
                releaseTitleLabel.textColor = Settings.currentTheme.secondaryTitleColor
                releaseTitleLabel.font = Settings.currentFontSize.secondaryTitleFont
            }
        }
        
        ratingAndUserLabel.attributedText = review.ratingAndUsernameAttributedString
        dateLabel.text = review.dateString
        if let release = review.release {
            self.setThumbnailImageView(with: release)
        } else {
            self.thumbnailImageView.image = UIImage(named: Ressources.Images.vinyl)
        }
    }
}
