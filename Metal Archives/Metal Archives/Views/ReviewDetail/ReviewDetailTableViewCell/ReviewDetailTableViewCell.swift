//
//  ReviewDetailTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 17/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

protocol ReviewDetailTableViewCellDelegate: class {
    func didTapBandNameLabel()
    func didTapReleaseTitleLabel()
    func didTapAuthorLabel()
    func didTapBaseVersionLabel()
}

final class ReviewDetailTableViewCell: BaseTableViewCell, RegisterableCell {
    @IBOutlet private weak var bandNameLabel: UILabel!
    @IBOutlet private weak var releaseTitleLabel: UILabel!
    @IBOutlet private weak var ratingLabel: UILabel!
    @IBOutlet private weak var authorLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var baseVersionLabel: UILabel!
    @IBOutlet private weak var reviewContentLabel: UILabel!
    @IBOutlet private var iconImageViews: [UIImageView]!
    
    weak var delegate: ReviewDetailTableViewCellDelegate?
    
    override func initAppearance() {
        super.initAppearance()
        selectionStyle = .none
        
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
        authorLabel.textColor = Settings.currentTheme.secondaryTitleColor
        authorLabel.font = Settings.currentFontSize.bodyTextFont
        
        let authorLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAuthorLabel))
        authorLabel.isUserInteractionEnabled = true
        authorLabel.addGestureRecognizer(authorLabelTapGesture)
        
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
    }

    func fill(with review: Review) {
        bandNameLabel.text = review.band.name
        releaseTitleLabel.text = review.release.title
        ratingLabel.text = "\(review.rating!)%"
        ratingLabel.textColor = UIColor.colorByRating(review.rating)
        authorLabel.text = review.user.name
        dateLabel.text = review.dateString
        baseVersionLabel.attributedText = review.baseVersionAttributedString
        reviewContentLabel.text = review.htmlContentString.htmlToString
    }
    
    @objc private func tapBandNameLabel() {
        delegate?.didTapBandNameLabel()
    }
    
    @objc private func tapReleaseTitleLabel() {
        delegate?.didTapReleaseTitleLabel()
    }
    
    @objc private func tapAuthorLabel() {
        delegate?.didTapAuthorLabel()
    }
    
    @objc private func tapBaseVersionLabel() {
        delegate?.didTapBaseVersionLabel()
    }
}
