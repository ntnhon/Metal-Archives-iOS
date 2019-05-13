//
//  LatestReviewCollectionViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 13/05/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class LatestReviewCollectionViewCell: ThumbnailableCollectionViewCell, RegisterableCell {
    //MARK: - Outlets
    @IBOutlet private weak var bandNameLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var releaseTitleLabel: UILabel!
    @IBOutlet private weak var authorLabel: UILabel!
    @IBOutlet private weak var ratingLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!

    override func initAppearance() {
        super.initAppearance()
        
        bandNameLabel.textColor = Settings.currentTheme.titleColor
        bandNameLabel.font = Settings.currentFontSize.titleFont
        
        releaseTitleLabel.textColor = Settings.currentTheme.secondaryTitleColor
        releaseTitleLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        dateLabel.textColor = Settings.currentTheme.bodyTextColor
        dateLabel.font = Settings.currentFontSize.bodyTextFont
        
        ratingLabel.textColor = Settings.currentTheme.bodyTextColor
        ratingLabel.font = Settings.currentFontSize.bodyTextFont
        
        authorLabel.textColor = Settings.currentTheme.bodyTextColor
        authorLabel.font = Settings.currentFontSize.bodyTextFont
        
        separatorView.backgroundColor = Settings.currentTheme.collectionViewSeparatorColor
    }
    
    func fill(with latestReview: LatestReview) {
        bandNameLabel.text = latestReview.band.name
        releaseTitleLabel.text = latestReview.release.name
        dateLabel.text = latestReview.dateString
        
        ratingLabel.text = "\(latestReview.rating)%"
        ratingLabel.textColor = UIColor.colorByRating(latestReview.rating)
        
        authorLabel.text = "Written by \(latestReview.author.name)"
        
        setThumbnailImageView(with: latestReview.release)
    }
    
    func showSeparator(_ show: Bool) {
        separatorView.alpha = show ? 0 : 1
    }
}
