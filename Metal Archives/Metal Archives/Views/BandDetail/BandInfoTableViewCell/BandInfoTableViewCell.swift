//
//  BandInfoTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 28/05/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class BandInfoTableViewCell: BaseTableViewCell, RegisterableCell {
    @IBOutlet private weak var countryLabel: UILabel!
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var formedInLabel: UILabel!
    @IBOutlet private weak var yearsActiveLabel: UILabel!
    @IBOutlet private weak var genreLabel: UILabel!
    @IBOutlet private weak var lyricalThemesLabel: UILabel!
    @IBOutlet private weak var lastLabelLabel: UILabel!
    @IBOutlet private weak var lastModifiedOnLabel: UILabel!
    @IBOutlet private weak var aboutLabel: UILabel!
    
    @IBOutlet private var iconImageViews: [UIImageView]!
    @IBOutlet private var labels: [UILabel]!
    
    private weak var band: Band!
    private var fullyDisplayLastModifiedOnDate = false
    
    var tappedYearsActiveLabel: (() -> Void)?
    var tappedLastModifiedOnLabel: (() -> Void)?
    var tappedLastLabelLabel: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func initAppearance() {
        super.initAppearance()
        iconImageViews.forEach({$0.tintColor = Settings.currentTheme.iconTintColor})
        labels.forEach({
            $0.textColor = Settings.currentTheme.bodyTextColor
            $0.font = Settings.currentFontSize.bodyTextFont
        })
        
        let yearsActiveLabelTap = UITapGestureRecognizer(target: self, action: #selector(didTapYearsActiveLabel))
        yearsActiveLabel.isUserInteractionEnabled = true
        yearsActiveLabel.addGestureRecognizer(yearsActiveLabelTap)
        
        let lastLabelLabelTap = UITapGestureRecognizer(target: self, action: #selector(didTapLastLabelLabel))
        lastLabelLabel.isUserInteractionEnabled = true
        lastLabelLabel.addGestureRecognizer(lastLabelLabelTap)
        
        let lastModifiedOnLabelTap = UITapGestureRecognizer(target: self, action: #selector(didTapLastModifiedOnLabel))
        lastModifiedOnLabel.isUserInteractionEnabled = true
        lastModifiedOnLabel.addGestureRecognizer(lastModifiedOnLabelTap)
        
        lastModifiedOnLabel.textColor = Settings.currentTheme.secondaryTitleColor
        lastModifiedOnLabel.font = Settings.currentFontSize.secondaryTitleFont
    }
    
    func fill(with band: Band) {
        self.band = band
        
        countryLabel.text = band.country.nameAndEmoji
        locationLabel.text = band.location
        statusLabel.text = band.status.description
        statusLabel.textColor = band.status.color
        formedInLabel.text = band.formedIn
        genreLabel.text = band.genre
        aboutLabel.text = band.shortHTMLDescription?.htmlToString
        yearsActiveLabel.attributedText = band.yearsActiveAttributedString
        
        setLastLabelLabel()
        setLastModifiedOnLabel()
    }
    
    private func setLastLabelLabel() {
        lastLabelLabel.text = band.lastLabel.name
        if let _ = band.lastLabel.urlString {
            lastLabelLabel.textColor = Settings.currentTheme.secondaryTitleColor
            lastLabelLabel.font = Settings.currentFontSize.secondaryTitleFont
        } else {
            lastLabelLabel.textColor = Settings.currentTheme.bodyTextColor
            lastLabelLabel.font = Settings.currentFontSize.bodyTextFont
        }
    }
    
    private func setLastModifiedOnLabel() {
        if fullyDisplayLastModifiedOnDate {
            var addedOnString = "N/A"
            var lastModifiedOnString = "N/A"
            
            if let addedOnDate = band.auditTrail.addedOnDate {
                addedOnString = defaultDateFormatter.string(from: addedOnDate)
                
            }
            
            if let lastModifiedOnDate = band.auditTrail.modifiedOnDate {
                lastModifiedOnString = defaultDateFormatter.string(from: lastModifiedOnDate)
            }
            
            lastModifiedOnLabel.text = "Added on: \(addedOnString)\nLast modified on: \(lastModifiedOnString)"
            
        } else if let lastModifiedOnDate = band.auditTrail.modifiedOnDate {
            
            let (value, unit) = lastModifiedOnDate.distanceFromNow()
            lastModifiedOnLabel.text = "Updated \(value) \(unit) ago"
        }
    }
    
    @objc private func didTapYearsActiveLabel() {
        tappedYearsActiveLabel?()
    }
    
    @objc private func didTapLastLabelLabel() {
        tappedLastLabelLabel?()
    }
    
    @objc private func didTapLastModifiedOnLabel() {
        fullyDisplayLastModifiedOnDate.toggle()
        setLastModifiedOnLabel()
        tappedLastModifiedOnLabel?()
    }
}
