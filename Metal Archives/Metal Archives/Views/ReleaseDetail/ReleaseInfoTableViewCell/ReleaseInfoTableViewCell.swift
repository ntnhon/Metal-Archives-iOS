//
//  ReleaseInfoTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 01/06/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class ReleaseInfoTableViewCell: BaseTableViewCell, RegisterableCell {
    @IBOutlet private weak var bandNameLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var catalogIDLabel: UILabel!
    @IBOutlet private weak var labelLabel: UILabel!
    @IBOutlet private weak var formatLabel: UILabel!
    @IBOutlet private weak var reviewsLabel: UILabel!
    @IBOutlet private weak var lastModifiedOnLabel: UILabel!
    
    @IBOutlet private var iconImageViews: [UIImageView]!
    @IBOutlet private var labels: [UILabel]!
    
    private unowned var release: Release!
    private var fullyDisplayLastModifiedOnDate = false
    
    var tappedBandNameLabel: (() -> Void)?
    var tappedLastModifiedOnLabel: (() -> Void)?
    var tappedLabelLabel: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func initAppearance() {
        super.initAppearance()
        self.selectionStyle = .none
        
        iconImageViews.forEach({$0.tintColor = Settings.currentTheme.iconTintColor})
        labels.forEach({
            $0.textColor = Settings.currentTheme.bodyTextColor
            $0.font = Settings.currentFontSize.bodyTextFont
        })
        
        let bandNameLabelTap = UITapGestureRecognizer(target: self, action: #selector(didTapBandNameLabel))
        bandNameLabel.isUserInteractionEnabled = true
        bandNameLabel.addGestureRecognizer(bandNameLabelTap)
        bandNameLabel.textColor = Settings.currentTheme.secondaryTitleColor
        bandNameLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        let lastLabelLabelTap = UITapGestureRecognizer(target: self, action: #selector(didTapLabelLabel))
        labelLabel.isUserInteractionEnabled = true
        labelLabel.addGestureRecognizer(lastLabelLabelTap)
        
        let lastModifiedOnLabelTap = UITapGestureRecognizer(target: self, action: #selector(didTapLastModifiedOnLabel))
        lastModifiedOnLabel.isUserInteractionEnabled = true
        lastModifiedOnLabel.addGestureRecognizer(lastModifiedOnLabelTap)
        
        lastModifiedOnLabel.textColor = Settings.currentTheme.secondaryTitleColor
        lastModifiedOnLabel.font = Settings.currentFontSize.secondaryTitleFont
    }
    
    func fill(with release: Release) {
        self.release = release
        
        bandNameLabel.text = release.band?.name
        dateLabel.text = release.dateString
        catalogIDLabel.text = release.catalogID
        labelLabel.text = release.label.name
        formatLabel.text = release.format
        
        reviewsLabel.text = release.ratingString
        if let rating = release.rating {
            self.reviewsLabel.textColor = UIColor.colorByRating(rating)
        } else {
            self.reviewsLabel.textColor = Settings.currentTheme.bodyTextColor
        }
        
        setLabelLabel()
        setLastModifiedOnLabel()
    }
    
    private func setLabelLabel() {
        labelLabel.text = release.label.name
        if let _ = release.label.urlString {
            labelLabel.textColor = Settings.currentTheme.secondaryTitleColor
            labelLabel.font = Settings.currentFontSize.secondaryTitleFont
        } else {
            labelLabel.textColor = Settings.currentTheme.bodyTextColor
            labelLabel.font = Settings.currentFontSize.bodyTextFont
        }
    }
    
    private func setLastModifiedOnLabel() {
        if fullyDisplayLastModifiedOnDate {
            var addedOnString = "N/A"
            var lastModifiedOnString = "N/A"
            
            if let addedOnDate = release.auditTrail.addedOnDate {
                addedOnString = defaultDateFormatter.string(from: addedOnDate)
                
            }
            
            if let lastModifiedOnDate = release.auditTrail.modifiedOnDate {
                lastModifiedOnString = defaultDateFormatter.string(from: lastModifiedOnDate)
            }
            
            lastModifiedOnLabel.text = "Added on: \(addedOnString)\nLast modified on: \(lastModifiedOnString)"
            
        } else if let lastModifiedOnDate = release.auditTrail.modifiedOnDate {
            
            let (value, unit) = lastModifiedOnDate.distanceFromNow()
            lastModifiedOnLabel.text = "Updated \(value) \(unit) ago"
        }
    }
    
    @objc private func didTapBandNameLabel() {
        tappedBandNameLabel?()
    }
    
    @objc private func didTapLabelLabel() {
        tappedLabelLabel?()
    }
    
    @objc private func didTapLastModifiedOnLabel() {
        fullyDisplayLastModifiedOnDate.toggle()
        setLastModifiedOnLabel()
        tappedLastModifiedOnLabel?()
    }
}
