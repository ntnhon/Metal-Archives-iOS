//
//  LabelInfoTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 25/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class LabelInfoTableViewCell: BaseTableViewCell, RegisterableCell {
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
    
    @IBOutlet private var iconImageViews: [UIImageView]!
    @IBOutlet private var detailLabels: [UILabel]!
    
    private var fullyDisplayLastModifiedOnDate = false
    private weak var label: Label!
    
    var tappedParentLabel: (() -> Void)?
    var tappedWebsite: (() -> Void)?
    var tappedLastModifiedOnLabel: (() -> Void)?
    
    override func initAppearance() {
        super.initAppearance()
        selectionStyle = .none
        
        iconImageViews.forEach({
            $0.tintColor = Settings.currentTheme.iconTintColor
        })
        
        detailLabels.forEach({
            $0.textColor = Settings.currentTheme.bodyTextColor
            $0.font = Settings.currentFontSize.bodyTextFont
            $0.text = nil
        })
        
        lastModifiedOnLabel.textColor = Settings.currentTheme.secondaryTitleColor
        lastModifiedOnLabel.font = Settings.currentFontSize.secondaryTitleFont
    
        initGestures()
    }
    
    private func initGestures() {
        let tapParentLabelRegconizer = UITapGestureRecognizer(target: self, action: #selector(didTapParentLabel))
        tapParentLabelRegconizer.numberOfTapsRequired = 1
        parentLabelNameLabel.isUserInteractionEnabled = true
        parentLabelNameLabel.addGestureRecognizer(tapParentLabelRegconizer)
        
        let tapWebsiteRegconizer = UITapGestureRecognizer(target: self, action: #selector(didTapWebsite))
        tapWebsiteRegconizer.numberOfTapsRequired = 1
        websiteLabel.isUserInteractionEnabled = true
        websiteLabel.addGestureRecognizer(tapWebsiteRegconizer)
        
        let tapLastModifiedOnLabelGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapLastModifiedOnLabel))
        tapLastModifiedOnLabelGestureRecognizer.numberOfTapsRequired = 1
        lastModifiedOnLabel.isUserInteractionEnabled = true
        lastModifiedOnLabel.addGestureRecognizer(tapLastModifiedOnLabelGestureRecognizer)
        
    }
    
    func fill(with label: Label) {
        self.label = label

        addressLabel.text = label.address
        
        if let country = label.country {
            countryLabel.text = country.nameAndEmoji
        } else {
            countryLabel.text = "N/A"
        }
        
        phoneNumberLabel.text = label.phoneNumber
        
        statusLabel.text = label.status.description
        statusLabel.textColor = label.status.color
        
        genreLabel.text = label.specialisedIn
        
        if let year = label.foundingDate {
            yearLabel.text = "\(year)"
        } else {
            yearLabel.text = "N/A"
        }
        
        if let parentLabel = label.parentLabel {
            parentLabelNameLabel.text = parentLabel.name
            parentLabelNameLabel.textColor = Settings.currentTheme.secondaryTitleColor
            parentLabelNameLabel.font = Settings.currentFontSize.secondaryTitleFont
        } else {
            parentLabelNameLabel.text = "N/A"
            parentLabelNameLabel.textColor = Settings.currentTheme.bodyTextColor
            parentLabelNameLabel.font = Settings.currentFontSize.bodyTextFont
        }
        
        shoppingOnlineLabel.text = label.onlineShopping
        
        if let website = label.website {
            websiteLabel.text = website.title
            websiteLabel.textColor = Settings.currentTheme.secondaryTitleColor
            websiteLabel.font = Settings.currentFontSize.secondaryTitleFont
        } else {
            websiteLabel.text = "N/A"
            websiteLabel.textColor = Settings.currentTheme.bodyTextColor
            websiteLabel.font = Settings.currentFontSize.bodyTextFont
        }
        
        setLastModifiedOnLabel()
    }
    
    private func setLastModifiedOnLabel() {
        if fullyDisplayLastModifiedOnDate {
            var addedOnString = "N/A"
            var lastModifiedOnString = "N/A"
            
            if let addedOnDate = label.addedOnDate {
                addedOnString = defaultDateFormatter.string(from: addedOnDate)
                
            }
            
            if let lastModifiedOnDate = label.lastModifiedOnDate {
                lastModifiedOnString = defaultDateFormatter.string(from: lastModifiedOnDate)
            }
            
            lastModifiedOnLabel.text = "Added on: \(addedOnString)\nLast modified on: \(lastModifiedOnString)"
            
        } else if let lastModifiedOnDate = label.lastModifiedOnDate {
            
            let (value, unit) = lastModifiedOnDate.distanceFromNow()
            lastModifiedOnLabel.text = "Updated \(value) \(unit) ago"
        }
    }

    @objc private func didTapParentLabel() {
        tappedParentLabel?()
    }
    
    @objc private func didTapWebsite() {
        tappedWebsite?()
    }
    
    @objc private func didTapLastModifiedOnLabel() {
        fullyDisplayLastModifiedOnDate.toggle()
        setLastModifiedOnLabel()
        tappedLastModifiedOnLabel?()
    }
}
