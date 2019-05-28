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
    
    var tappedLastModifiedOn: (() -> Void)?
    
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
        
        let lastModifiedOnLabelTap = UITapGestureRecognizer(target: self, action: #selector(didTapLastModifiedOnLabel))
        lastModifiedOnLabel.isUserInteractionEnabled = true
        lastModifiedOnLabel.addGestureRecognizer(lastModifiedOnLabelTap)
    }
    
    func fill(with band: Band) {
        self.band = band
        
        countryLabel.text = band.country.nameAndEmoji
        locationLabel.text = band.location
        
        statusLabel.text = band.status.description
        statusLabel.textColor = band.status.color
        
        formedInLabel.text = band.formedIn
        
        yearsActiveLabel.text = band.yearsActiveString
        if let _ = band.oldBands {
            yearsActiveLabel.textColor = Settings.currentTheme.titleColor
            yearsActiveLabel.font = Settings.currentFontSize.secondaryTitleFont
        } else {
            yearsActiveLabel.textColor = Settings.currentTheme.bodyTextColor
            yearsActiveLabel.font = Settings.currentFontSize.bodyTextFont
        }
        
        genreLabel.text = band.genre
        lastLabelLabel.text = band.lastLabel.name
        aboutLabel.text = band.shortHTMLDescription?.htmlToString
        
        setLastModifiedOnLabel()
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
    
    @objc private func didTapLastModifiedOnLabel() {
        fullyDisplayLastModifiedOnDate.toggle()
        setLastModifiedOnLabel()
        tappedLastModifiedOn?()
    }
}
