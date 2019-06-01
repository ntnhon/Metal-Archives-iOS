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
    @IBOutlet private var detailsLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        titleLabel.textColor = Settings.currentTheme.titleColor
        titleLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        detailsLabel.textColor = Settings.currentTheme.bodyTextColor
        detailsLabel.font = Settings.currentFontSize.bodyTextFont
    }
    
    func fill(with review: ReviewLiteInRelease) {
        titleLabel.text = review.title
        
        let detailsString = "\(review.rating)% • \(review.author.name) • \(review.dateString)"
        let mutableAttributedString = NSMutableAttributedString(string: detailsString)
        
        mutableAttributedString.addAttributes([.foregroundColor: Settings.currentTheme.bodyTextColor, .font: Settings.currentFontSize.bodyTextFont], range: NSRange(detailsString.startIndex..., in: detailsString))
        
        if let ratingStringRange = detailsString.range(of: "\(review.rating)%") {
            mutableAttributedString.addAttributes([.foregroundColor: UIColor.colorByRating(review.rating)], range: NSRange(ratingStringRange, in: detailsString))
        }
        
        if let authorNameRange = detailsString.range(of: "\(review.author.name)") {
            mutableAttributedString.addAttributes([.foregroundColor: Settings.currentTheme.secondaryTitleColor], range: NSRange(authorNameRange, in: detailsString))
        }
        
        detailsLabel.attributedText = mutableAttributedString
    }

}
