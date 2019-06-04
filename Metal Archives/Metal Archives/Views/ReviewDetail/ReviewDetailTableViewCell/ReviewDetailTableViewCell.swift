//
//  ReviewDetailTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 17/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

protocol ReviewDetailTableViewCellDelegate {
    func didTapCoverImageView()
}

final class ReviewDetailTableViewCell: BaseTableViewCell, RegisterableCell {
    @IBOutlet private weak var coverPhotoImageView: UIImageView!
    @IBOutlet private weak var coverPhotoImageViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var reviewTitleLabel: UILabel!
    @IBOutlet private weak var bandNameLabel: UILabel!
    @IBOutlet private weak var releaseTitleLabel: UILabel!
    @IBOutlet private weak var ratingLabel: UILabel!
    @IBOutlet private weak var authorAndDateLabel: UILabel!
    @IBOutlet private weak var reviewContentLabel: UILabel!
    @IBOutlet private var iconImageViews: [UIImageView]!
    
    var delegate: ReviewDetailTableViewCellDelegate?
    
    override func initAppearance() {
        super.initAppearance()
        selectionStyle = .none
        
        coverPhotoImageViewHeightConstraint.constant = screenWidth
        coverPhotoImageView.sd_setShowActivityIndicatorView(true)
        coverPhotoImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapCoverImageView))
        tap.numberOfTapsRequired = 1
        coverPhotoImageView.addGestureRecognizer(tap)
        
        reviewTitleLabel.textColor = Settings.currentTheme.reviewTitleColor
        reviewTitleLabel.font = Settings.currentFontSize.reviewTitleFont
        
        bandNameLabel.textColor = Settings.currentTheme.bodyTextColor
        bandNameLabel.font = Settings.currentFontSize.bodyTextFont
        
        releaseTitleLabel.textColor = Settings.currentTheme.bodyTextColor
        releaseTitleLabel.font = Settings.currentFontSize.bodyTextFont
        
        ratingLabel.textColor = Settings.currentTheme.bodyTextColor
        ratingLabel.font = Settings.currentFontSize.bodyTextFont
        
        authorAndDateLabel.textColor = Settings.currentTheme.secondaryTitleColor
        authorAndDateLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        reviewContentLabel.textColor = Settings.currentTheme.bodyTextColor
        reviewContentLabel.font = Settings.currentFontSize.bodyTextFont
        
        iconImageViews.forEach({
            $0.tintColor = Settings.currentTheme.iconTintColor
        })
    }

    func fill(with review: Review) {
        if let coverPhotoURLString = review.coverPhotoURLString {
            coverPhotoImageView.sd_setImage(with: URL(string: coverPhotoURLString), placeholderImage: nil, options: [.retryFailed])
        } else {
            coverPhotoImageViewHeightConstraint.constant = 20
        }
        
        reviewTitleLabel.text = review.title
        bandNameLabel.text = review.bandName
        releaseTitleLabel.text = review.releaseTitle
        ratingLabel.text = "\(review.rating!)%"
        ratingLabel.textColor = UIColor.colorByRating(review.rating)
        authorAndDateLabel.text = "Review written by \(review.authorName!) on \(review.dateAndReleaseVersionHTMLString!.htmlToString!)"
        reviewContentLabel.text = review.htmlContentString.htmlToString
    }
    
    @objc private func tapCoverImageView() {
        delegate?.didTapCoverImageView()
    }
}
