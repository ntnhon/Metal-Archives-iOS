//
//  ReviewDetailTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 17/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

protocol ReviewDetailTableViewCellDelegate: class {
    func didTapCoverImageView()
    func didTapBandNameLabel()
    func didTapReleaseTitleLabel()
    func didTapBaseVersionLabel()
    func didTapCloseButton()
    func didTapShareButton()
}

final class ReviewDetailTableViewCell: BaseTableViewCell, RegisterableCell {
    @IBOutlet private(set) weak var coverPhotoImageView: UIImageView!
    @IBOutlet private weak var coverPhotoImageViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var reviewTitleLabel: UILabel!
    @IBOutlet private weak var bandNameLabel: UILabel!
    @IBOutlet private weak var releaseTitleLabel: UILabel!
    @IBOutlet private weak var ratingLabel: UILabel!
    @IBOutlet private weak var authorLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var baseVersionLabel: UILabel!
    @IBOutlet private weak var reviewContentLabel: UILabel!
    @IBOutlet private var iconImageViews: [UIImageView]!
    
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var shareButton: UIButton!
    
    weak var delegate: ReviewDetailTableViewCellDelegate?
    
    override func initAppearance() {
        super.initAppearance()
        selectionStyle = .none
        
        // Cover photo image view
        coverPhotoImageViewHeightConstraint.constant = screenWidth
        coverPhotoImageView.sd_setShowActivityIndicatorView(true)
        coverPhotoImageView.isUserInteractionEnabled = true
        let coverPhotoImageViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(tapCoverImageView))
        coverPhotoImageView.addGestureRecognizer(coverPhotoImageViewTapGesture)
        
        // Review title
        reviewTitleLabel.textColor = Settings.currentTheme.reviewTitleColor
        reviewTitleLabel.font = Settings.currentFontSize.reviewTitleFont
        
        // Band name
        bandNameLabel.textColor = Settings.currentTheme.secondaryTitleColor
        bandNameLabel.font = Settings.currentFontSize.bodyTextFont
        let bandNameLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(tapBandNameLabel))
        bandNameLabel.isUserInteractionEnabled = true
        bandNameLabel.addGestureRecognizer(bandNameLabelTapGesture)
        
        // Release title
        releaseTitleLabel.textColor = Settings.currentTheme.secondaryTitleColor
        releaseTitleLabel.font = Settings.currentFontSize.bodyTextFont
        let releaseTitleLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(tapReleaseTitleLabel))
        releaseTitleLabel.isUserInteractionEnabled = true
        releaseTitleLabel.addGestureRecognizer(releaseTitleLabelTapGesture)
        
        // Rating
        ratingLabel.textColor = Settings.currentTheme.bodyTextColor
        ratingLabel.font = Settings.currentFontSize.bodyTextFont
        
        // Date
        dateLabel.textColor = Settings.currentTheme.bodyTextColor
        dateLabel.font = Settings.currentFontSize.bodyTextFont
        
        // Author
        authorLabel.textColor = Settings.currentTheme.bodyTextColor
        authorLabel.font = Settings.currentFontSize.bodyTextFont
        
        // Base version
        baseVersionLabel.textColor = Settings.currentTheme.secondaryTitleColor
        baseVersionLabel.font = Settings.currentFontSize.secondaryTitleFont
        let baseVersionLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(tapBaseVersionLabel))
        baseVersionLabel.isUserInteractionEnabled = true
        baseVersionLabel.addGestureRecognizer(baseVersionLabelTapGesture)
        
        reviewContentLabel.textColor = Settings.currentTheme.bodyTextColor
        reviewContentLabel.font = Settings.currentFontSize.bodyTextFont
        
        iconImageViews.forEach({
            $0.tintColor = Settings.currentTheme.iconTintColor
        })
        
        closeButton.tintColor = Settings.currentTheme.bodyTextColor
        shareButton.tintColor = Settings.currentTheme.bodyTextColor
    }

    func fill(with review: Review) {
        if let coverPhotoURLString = review.coverPhotoURLString {
            coverPhotoImageView.sd_setImage(with: URL(string: coverPhotoURLString), placeholderImage: nil, options: [.retryFailed])
        } else {
            coverPhotoImageViewHeightConstraint.constant = 20
        }
        
        reviewTitleLabel.text = review.title
        bandNameLabel.text = review.band.name
        releaseTitleLabel.text = review.release.name
        ratingLabel.text = "\(review.rating!)%"
        ratingLabel.textColor = UIColor.colorByRating(review.rating)
        authorLabel.text = review.user.name
        dateLabel.text = review.dateString
        baseVersionLabel.attributedText = review.baseVersionAttributedString
        reviewContentLabel.text = review.htmlContentString.htmlToString
    }
    
    @objc private func tapCoverImageView() {
        delegate?.didTapCoverImageView()
    }
    
    @objc private func tapBandNameLabel() {
        delegate?.didTapBandNameLabel()
    }
    
    @objc private func tapReleaseTitleLabel() {
        delegate?.didTapReleaseTitleLabel()
    }
    
    @objc private func tapBaseVersionLabel() {
        delegate?.didTapBaseVersionLabel()
    }
    
    @IBAction private func tapCloseButton() {
        delegate?.didTapCloseButton()
    }
    
    @IBAction private func tapShareButton() {
        delegate?.didTapShareButton()
    }
}
