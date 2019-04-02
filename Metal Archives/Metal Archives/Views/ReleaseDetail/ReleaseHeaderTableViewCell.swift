//
//  ReleaseHeaderTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 06/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

protocol ReleaseHeaderTableViewCellDelegate {
    func didTapCoverImageView()
    func didTapLastModifiedOn()
}

final class ReleaseHeaderTableViewCell: BaseTableViewCell, RegisterableCell {
    @IBOutlet private weak var coverImageView: UIImageView!
    @IBOutlet private weak var coverImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var typeLabel: UILabel!
    @IBOutlet private weak var bandLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var catalogIDLabel: UILabel!
    @IBOutlet private weak var labelLabel: UILabel!
    @IBOutlet private weak var formatLabel: UILabel!
    @IBOutlet private weak var reviewsLabel: UILabel!
    @IBOutlet private weak var lastModifiedOnLabel: UILabel!
    @IBOutlet private weak var additionalNotesLabel: UILabel!
    
    
    private var noCoverLabel: UILabel!
    
    @IBOutlet private var detailLabels: [UILabel]!
    @IBOutlet private var iconImageViews: [UIImageView]!
    
    var delegate: ReleaseHeaderTableViewCellDelegate?
    private weak var release: Release!
    private var fullyDisplayLastModifiedOnDate = false
    
    override func initAppearance() {
        super.initAppearance()
        self.selectionStyle = .none

        self.titleLabel.textColor = Settings.currentTheme.bodyTextColor
        self.titleLabel.font = Settings.currentFontSize.largeTitleFont
        
        self.coverImageViewHeightConstraint.constant = screenHeight / 3
        self.coverImageView.sd_setShowActivityIndicatorView(true)
        
        self.detailLabels.forEach({
            $0.textColor = Settings.currentTheme.bodyTextColor
            $0.font = Settings.currentFontSize.bodyTextFont
        })
        
        self.iconImageViews.forEach({
            $0.tintColor = Settings.currentTheme.iconTintColor
        })
        
        self.lastModifiedOnLabel.textColor = Settings.currentTheme.titleColor
        self.lastModifiedOnLabel.font = Settings.currentFontSize.secondaryTitleFont
        let tapLastModifiedOnLabelGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapLastModifiedOnLabel))
        tapLastModifiedOnLabelGestureRecognizer.numberOfTapsRequired = 1
        self.lastModifiedOnLabel.isUserInteractionEnabled = true
        self.lastModifiedOnLabel.addGestureRecognizer(tapLastModifiedOnLabelGestureRecognizer)
        
        //Add cover image view tap gesture
        self.coverImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCoverImageView))
        tap.numberOfTapsRequired = 1
        self.coverImageView.addGestureRecognizer(tap)
        
        //Add cover image view shadow
        self.coverImageView.addShadow()
        
        self.initNoCoverLabel()
    }
    
    private func initNoCoverLabel() {
        self.noCoverLabel = UILabel(frame: CGRect.zero)
        self.coverImageView.addSubview(self.noCoverLabel)
        
        self.noCoverLabel.translatesAutoresizingMaskIntoConstraints = false
        self.noCoverLabel.topAnchor.constraint(equalTo: self.noCoverLabel.superview!.topAnchor).isActive = true
        self.noCoverLabel.leadingAnchor.constraint(equalTo: self.noCoverLabel.superview!.leadingAnchor).isActive = true
        self.noCoverLabel.bottomAnchor.constraint(equalTo: self.noCoverLabel.superview!.bottomAnchor).isActive = true
        self.noCoverLabel.trailingAnchor.constraint(equalTo: self.noCoverLabel.superview!.trailingAnchor).isActive = true
        
        self.noCoverLabel.text = "Cover photo not available"
        self.noCoverLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        self.noCoverLabel.numberOfLines = 0
        self.noCoverLabel.textAlignment = .center
        self.noCoverLabel.textColor = Settings.currentTheme.bodyTextColor
        self.noCoverLabel.backgroundColor = Settings.currentTheme.backgroundColor
        self.noCoverLabel.isHidden = true
    }
    
    func fill(with release: Release) {
        self.release = release
        self.reload()
    }
    
    private func reload() {
        if let urlString = release.coverURLString, let url = URL(string: urlString) {
            self.noCoverLabel.isHidden = true
            self.coverImageView.sd_setImage(with: url, placeholderImage: nil, options: [.retryFailed]) { [weak self] (image, error, cacheType, url) in
                if let _ = error {
                    self?.noCoverLabel.isEnabled = false
                }
            }
        } else {
            self.noCoverLabel.isHidden = false
        }
        
        self.typeLabel.text = release.type.description
        self.titleLabel.text = release.title
        self.bandLabel.text = release.band?.name
        self.dateLabel.text = release.dateString
        self.catalogIDLabel.text = release.catalogID
        self.labelLabel.text = release.label.name
        self.formatLabel.text = release.format
        
        self.reviewsLabel.text = release.ratingString
        if let rating = release.rating {
            self.reviewsLabel.textColor = UIColor.colorByRating(rating)
        } else {
            self.reviewsLabel.textColor = Settings.currentTheme.bodyTextColor
        }
        
        self.additionalNotesLabel.text = release.additionalHTMLNotes?.htmlToString
        self.setLastModifiedOnLabel()
    }
    
    private func setLastModifiedOnLabel() {
        if fullyDisplayLastModifiedOnDate {
            var addedOnString = "N/A"
            var lastModifiedOnString = "N/A"
            
            if let addedOnDate = release.addedOnDate {
                addedOnString = defaultDateFormatter.string(from: addedOnDate)
                
            }
            
            if let lastModifiedOnDate = release.lastModifiedOnDate {
                lastModifiedOnString = defaultDateFormatter.string(from: lastModifiedOnDate)
            }
            
            self.lastModifiedOnLabel.text = "Added on: \(addedOnString)\nLast modified on: \(lastModifiedOnString)"
            
        } else if let lastModifiedOnDate = release.lastModifiedOnDate {
            
            let (value, unit) = lastModifiedOnDate.distanceFromNow()
            self.lastModifiedOnLabel.text = "Updated \(value) \(unit) ago"
        }
    }
    
    @objc private func didTapCoverImageView() {
        self.delegate?.didTapCoverImageView()
    }
    
    @objc private func didTapLastModifiedOnLabel() {
        self.fullyDisplayLastModifiedOnDate = !self.fullyDisplayLastModifiedOnDate
        self.setLastModifiedOnLabel()
        self.delegate?.didTapLastModifiedOn()
    }
}
