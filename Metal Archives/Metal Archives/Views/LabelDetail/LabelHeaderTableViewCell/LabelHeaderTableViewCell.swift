//
//  LabelHeaderTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 25/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

protocol LabelHeaderTableViewCellDelegate {
    func didTapLogo()
    func didTapParentLabel()
    func didTapWebsite()
    func didTapLastModifiedOn()
}

final class LabelHeaderTableViewCell: BaseTableViewCell, RegisterableCell {
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var logoImageViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var countryLabel: UILabel!
    @IBOutlet private weak var phoneNumberLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var genreLabel: UILabel!
    @IBOutlet private weak var yearLabel: UILabel!
    @IBOutlet private weak var parentLabelNameLabel: UILabel!
    @IBOutlet private weak var shoppingOnlineLabel: UILabel!
    @IBOutlet private weak var websiteLabel: UILabel!
    @IBOutlet private weak var lastModifiedOnLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    @IBOutlet private var iconImageViews: [UIImageView]!
    @IBOutlet private var detailLabels: [UILabel]!
    
    private var noLogoLablel: UILabel!
    
    var delegate: LabelHeaderTableViewCellDelegate?
    
    private var fullyDisplayLastModifiedOnDate = false
    private weak var label: Label!
    
    override func initAppearance() {
        super.initAppearance()
        self.selectionStyle = .none
    
        self.logoImageView.sd_setShowActivityIndicatorView(true)
        self.logoImageViewHeightConstraint.constant = screenHeight/3
        
        self.nameLabel.font = Settings.currentFontSize.largeTitleFont
        self.nameLabel.textColor = Settings.currentTheme.bodyTextColor

        self.iconImageViews.forEach({
            $0.tintColor = Settings.currentTheme.iconTintColor
        })
        
        self.detailLabels.forEach({
            $0.textColor = Settings.currentTheme.bodyTextColor
            $0.font = Settings.currentFontSize.bodyTextFont
            $0.text = nil
        })
        
        self.lastModifiedOnLabel.textColor = Settings.currentTheme.titleColor
        self.lastModifiedOnLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        self.initNoLogoLabel()
        self.initGestures()
    }
    
    private func initNoLogoLabel() {
        self.noLogoLablel = UILabel(frame: CGRect.zero)
        self.logoImageView.addSubview(self.noLogoLablel)
        
        self.noLogoLablel.translatesAutoresizingMaskIntoConstraints = false
        self.noLogoLablel.topAnchor.constraint(equalTo: self.noLogoLablel.superview!.topAnchor).isActive = true
        self.noLogoLablel.leadingAnchor.constraint(equalTo: self.noLogoLablel.superview!.leadingAnchor).isActive = true
        self.noLogoLablel.bottomAnchor.constraint(equalTo: self.noLogoLablel.superview!.bottomAnchor).isActive = true
        self.noLogoLablel.trailingAnchor.constraint(equalTo: self.noLogoLablel.superview!.trailingAnchor).isActive = true
        self.noLogoLablel.text = "Logo not available"
        self.noLogoLablel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        self.noLogoLablel.numberOfLines = 0
        self.noLogoLablel.textAlignment = .center
        self.noLogoLablel.textColor = Settings.currentTheme.bodyTextColor
        self.noLogoLablel.backgroundColor = Settings.currentTheme.backgroundColor
        self.noLogoLablel.isHidden = true
    }
    
    private func initGestures() {
        let tapLogoGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapLogo))
        tapLogoGestureRecognizer.numberOfTapsRequired = 1
        self.logoImageView.isUserInteractionEnabled = true
        self.logoImageView.addGestureRecognizer(tapLogoGestureRecognizer)
        
        let tapParentLabelRegconizer = UITapGestureRecognizer(target: self, action: #selector(didTapParentLabel))
        tapParentLabelRegconizer.numberOfTapsRequired = 1
        self.parentLabelNameLabel.isUserInteractionEnabled = true
        self.parentLabelNameLabel.addGestureRecognizer(tapParentLabelRegconizer)
        
        let tapWebsiteRegconizer = UITapGestureRecognizer(target: self, action: #selector(didTapWebsite))
        tapWebsiteRegconizer.numberOfTapsRequired = 1
        self.websiteLabel.isUserInteractionEnabled = true
        self.websiteLabel.addGestureRecognizer(tapWebsiteRegconizer)
        
        let tapLastModifiedOnLabelGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapLastModifiedOnLabel))
        tapLastModifiedOnLabelGestureRecognizer.numberOfTapsRequired = 1
        self.lastModifiedOnLabel.isUserInteractionEnabled = true
        self.lastModifiedOnLabel.addGestureRecognizer(tapLastModifiedOnLabelGestureRecognizer)
        
    }
    
    func fill(with label: Label) {
        self.label = label
        
        if let logoURLString = label.logoURLString, let logoURL = URL(string: logoURLString) {
            self.noLogoLablel.isHidden = true
            self.logoImageView.sd_setImage(with: logoURL, completed: nil)
        } else {
            self.noLogoLablel.isHidden = false
        }
        
        self.nameLabel.text = label.name
        self.addressLabel.text = label.address
        
        if let country = label.country {
            self.countryLabel.text = country.nameAndEmoji
        } else {
            self.countryLabel.text = "N/A"
        }
        
        self.phoneNumberLabel.text = label.phoneNumber
        
        self.statusLabel.text = label.status.description
        self.statusLabel.textColor = label.status.color
        
        self.genreLabel.text = label.specialisedIn
        
        if let year = label.foundingDate {
            self.yearLabel.text = "\(year)"
        } else {
            self.yearLabel.text = "N/A"
        }
        
        if let parentLabel = label.parentLabel {
            self.parentLabelNameLabel.text = parentLabel.name
            self.parentLabelNameLabel.textColor = Settings.currentTheme.titleColor
            self.parentLabelNameLabel.font = Settings.currentFontSize.secondaryTitleFont
        } else {
            self.parentLabelNameLabel.text = "N/A"
            self.parentLabelNameLabel.textColor = Settings.currentTheme.bodyTextColor
            self.parentLabelNameLabel.font = Settings.currentFontSize.bodyTextFont
        }
        
        self.shoppingOnlineLabel.text = label.onlineShopping
        
        if let website = label.website {
            self.websiteLabel.text = website.title
            self.websiteLabel.textColor = Settings.currentTheme.titleColor
            self.websiteLabel.font = Settings.currentFontSize.secondaryTitleFont
        } else {
            self.websiteLabel.text = "N/A"
            self.websiteLabel.textColor = Settings.currentTheme.bodyTextColor
            self.websiteLabel.font = Settings.currentFontSize.bodyTextFont
        }
        
        self.descriptionLabel.text = label.additionalNotes
        
        self.setLastModifiedOnLabel()
    }
    
    private func setLastModifiedOnLabel() {
        if fullyDisplayLastModifiedOnDate {
            var addedOnString = "N/A"
            var lastModifiedOnString = "N/A"
            
            if let addedOnDate = self.label.addedOnDate {
                addedOnString = defaultDateFormatter.string(from: addedOnDate)
                
            }
            
            if let lastModifiedOnDate = self.label.lastModifiedOnDate {
                lastModifiedOnString = defaultDateFormatter.string(from: lastModifiedOnDate)
            }
            
            self.lastModifiedOnLabel.text = "Added on: \(addedOnString)\nLast modified on: \(lastModifiedOnString)"
            
        } else if let lastModifiedOnDate = self.label.lastModifiedOnDate {
            
            let (value, unit) = lastModifiedOnDate.distanceFromNow()
            self.lastModifiedOnLabel.text = "Updated \(value) \(unit) ago"
        }
    }
    
    @objc private func didTapLogo() {
        self.delegate?.didTapLogo()
    }
    
    @objc private func didTapParentLabel() {
        self.delegate?.didTapParentLabel()
    }
    
    @objc private func didTapWebsite() {
        self.delegate?.didTapWebsite()
    }
    
    @objc private func didTapLastModifiedOnLabel() {
        self.fullyDisplayLastModifiedOnDate = !self.fullyDisplayLastModifiedOnDate
        self.setLastModifiedOnLabel()
        self.delegate?.didTapLastModifiedOn()
    }
}
