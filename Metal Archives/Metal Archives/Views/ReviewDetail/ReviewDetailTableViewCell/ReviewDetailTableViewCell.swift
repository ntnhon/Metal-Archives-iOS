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
    private var noCoverPhotoLabel: UILabel!
    
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
        self.selectionStyle = .none
        
        self.coverPhotoImageViewHeightConstraint.constant = screenHeight/3
        self.coverPhotoImageView.sd_setShowActivityIndicatorView(true)
        self.coverPhotoImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapCoverImageView))
        tap.numberOfTapsRequired = 1
        self.coverPhotoImageView.addGestureRecognizer(tap)
        //No cover photo label: init and contraint to bandPhotoImageView
        self.noCoverPhotoLabel = UILabel(frame: CGRect.zero)
        self.coverPhotoImageView.addSubview(self.noCoverPhotoLabel)
        
        self.noCoverPhotoLabel.translatesAutoresizingMaskIntoConstraints = false
        self.noCoverPhotoLabel.topAnchor.constraint(equalTo: self.noCoverPhotoLabel.superview!.topAnchor).isActive = true
        self.noCoverPhotoLabel.leadingAnchor.constraint(equalTo: self.noCoverPhotoLabel.superview!.leadingAnchor).isActive = true
        self.noCoverPhotoLabel.bottomAnchor.constraint(equalTo: self.noCoverPhotoLabel.superview!.bottomAnchor).isActive = true
        self.noCoverPhotoLabel.trailingAnchor.constraint(equalTo: self.noCoverPhotoLabel.superview!.trailingAnchor).isActive = true
        
        self.noCoverPhotoLabel.text = "Cover photo not available"
        self.noCoverPhotoLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        self.noCoverPhotoLabel.numberOfLines = 0
        self.noCoverPhotoLabel.textAlignment = .center
        self.noCoverPhotoLabel.textColor = Settings.currentTheme.bodyTextColor
        self.noCoverPhotoLabel.backgroundColor = Settings.currentTheme.backgroundColor
        self.noCoverPhotoLabel.isHidden = true
        
        
        //Add cover image view shadow
        self.coverPhotoImageView.layer.shadowColor = Settings.currentTheme.bodyTextColor.cgColor
        self.coverPhotoImageView.layer.shadowOffset = .zero
        self.coverPhotoImageView.layer.shadowOpacity = 0.7
        self.coverPhotoImageView.layer.shadowRadius = 10
        self.coverPhotoImageView.layer.shouldRasterize = true
        self.coverPhotoImageView.layer.rasterizationScale = UIScreen.main.scale
        
        self.reviewTitleLabel.textColor = Settings.currentTheme.reviewTitleColor
        self.reviewTitleLabel.font = Settings.currentFontSize.reviewTitleFont
        
        self.bandNameLabel.textColor = Settings.currentTheme.bodyTextColor
        self.bandNameLabel.font = Settings.currentFontSize.bodyTextFont
        
        self.releaseTitleLabel.textColor = Settings.currentTheme.bodyTextColor
        self.releaseTitleLabel.font = Settings.currentFontSize.bodyTextFont
        
        self.ratingLabel.textColor = Settings.currentTheme.bodyTextColor
        self.ratingLabel.font = Settings.currentFontSize.bodyTextFont
        
        self.authorAndDateLabel.textColor = Settings.currentTheme.secondaryTitleColor
        self.authorAndDateLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        self.reviewContentLabel.textColor = Settings.currentTheme.bodyTextColor
        self.reviewContentLabel.font = Settings.currentFontSize.bodyTextFont
        
        self.iconImageViews.forEach({
            $0.tintColor = Settings.currentTheme.iconTintColor
        })
    }

    func bind(review: Review) {
        if let coverPhotoURLString = review.coverPhotoURLString {
            self.noCoverPhotoLabel.isHidden = true
            self.coverPhotoImageView.sd_setImage(with: URL(string: coverPhotoURLString), placeholderImage: nil, options: [.retryFailed]) { [weak self] (image, error, cacheType, url) in
                if let _ = error {
                    self?.noCoverPhotoLabel.isEnabled = false
                }
            }
        } else {
            self.noCoverPhotoLabel.isHidden = false
        }
        
        self.reviewTitleLabel.text = review.title
        self.bandNameLabel.text = review.bandName
        self.releaseTitleLabel.text = review.releaseTitle
        self.ratingLabel.text = "\(review.rating!)%"
        self.ratingLabel.textColor = UIColor.colorByRating(review.rating)
        self.authorAndDateLabel.text = "Review written by \(review.authorName!) on \(review.dateAndReleaseVersionHTMLString!.htmlToString!)"
        self.reviewContentLabel.text = review.htmlContentString.htmlToString
    }
    
    @objc private func tapCoverImageView() {
        self.delegate?.didTapCoverImageView()
    }
}
