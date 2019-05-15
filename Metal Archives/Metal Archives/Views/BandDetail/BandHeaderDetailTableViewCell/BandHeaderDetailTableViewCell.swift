//
//  BandHeaderDetailTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import SDWebImage
import UIKit

//MARK: Protocol
protocol BandHeaderDetailTableViewCellDelegate {
    func didTapBandPhoto()
    func didTapBandLogo()
    func didTapBandAbout()
    func didTapLastModifiedOn()
    func didTapYearsActive()
    func didTapLastLabelLabel()
}

//MARK: Declaration
final class BandHeaderDetailTableViewCell: BaseTableViewCell, RegisterableCell {
    //Band's Photo+Logo+Name
    @IBOutlet private weak var bandPhotoLogoNameView: UIView!
    @IBOutlet private weak var bandLogoImageView: UIImageView!
    @IBOutlet private weak var bandPhotoImageView: UIImageView!
    @IBOutlet private weak var bandNameLabel: UILabel!
    
    @IBOutlet private var bandPhotoLogoNameViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var logoImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var photoImageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private var photoImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var photoImageViewVerticalBaselineConstraint: NSLayoutConstraint!
    
    //In case no logo
    private var noLogoLablel: UILabel!
    private var noPhotoLabel: UILabel!
    
    //Details
    @IBOutlet private var eachDetailIconImageView: [UIImageView]!
    @IBOutlet private var eachDetailLabel: [UILabel]!
    
    //Country of origin
    @IBOutlet private weak var originLabel: UILabel!
    //Location
    @IBOutlet private weak var locationLabel: UILabel!
    //Status
    @IBOutlet private weak var statusLabel: UILabel!
    //Formed in
    @IBOutlet private weak var formedInLabel: UILabel!
    //Years active
    @IBOutlet private weak var yearsActiveLabel: UILabel!
    //Genre
    @IBOutlet private weak var genreLabel: UILabel!
    //Lyrical theme
    @IBOutlet private weak var lyricalThemeLabel: UILabel!
    //Last label
    @IBOutlet private weak var lastLabelLabel: UILabel!
    //Last Modifed Label
    @IBOutlet private weak var lastModifiedOnLabel: UILabel!
    //About
    @IBOutlet private weak var aboutLabel: UILabel!
    
    var delegate: BandHeaderDetailTableViewCellDelegate?

    private weak var band: Band!
    private var fullyDisplayLastModifiedOnDate = false

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.initNoLogoAndNoPhotoLabel()
        self.layoutIfNeeded()
    }
    
    override func initAppearance() {
        super.initAppearance()
        //Band's Photo+Logo+Name takes 1/3 of the screen's height
        self.bandPhotoLogoNameViewHeightConstraint.constant = screenHeight/3
        self.logoImageViewHeightConstraint.constant = self.bandPhotoLogoNameViewHeightConstraint.constant*3/4
        self.photoImageViewHeightConstraint.constant = self.bandPhotoLogoNameViewHeightConstraint.constant/2 - 16
        self.photoImageViewVerticalBaselineConstraint.constant = self.photoImageViewHeightConstraint.constant/2
        
        self.bandPhotoLogoNameView.backgroundColor = Settings.currentTheme.backgroundColor
        self.bandLogoImageView.backgroundColor = Settings.currentTheme.imageViewBackgroundColor
        self.bandPhotoImageView.backgroundColor = Settings.currentTheme.imageViewBackgroundColor
        self.bandNameLabel.textColor = Settings.currentTheme.bodyTextColor
        
        self.bandLogoImageView.sd_setShowActivityIndicatorView(true)
        self.bandPhotoImageView.sd_setShowActivityIndicatorView(true)
        
        self.bandLogoImageView.contentMode = .scaleAspectFit
        self.bandPhotoImageView.contentMode = .scaleAspectFit
        
        //Draw border band's photo as avatar
        self.bandPhotoImageView.clipsToBounds = true
        self.bandPhotoImageView.layer.borderColor = Settings.currentTheme.iconTintColor.cgColor
        self.bandPhotoImageView.layer.borderWidth = 4
        
        
        //Labels
        self.eachDetailLabel.forEach({
            $0.textColor = Settings.currentTheme.bodyTextColor
            $0.font = Settings.currentFontSize.bodyTextFont
        })
        //icon
        self.eachDetailIconImageView.forEach({
            $0.tintColor = Settings.currentTheme.iconTintColor
        })
        
        //Last modified on label
        self.lastModifiedOnLabel.textColor = Settings.currentTheme.titleColor
        self.lastModifiedOnLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        //About
        self.aboutLabel.translatesAutoresizingMaskIntoConstraints = false
        self.aboutLabel.backgroundColor = Settings.currentTheme.backgroundColor
        self.aboutLabel.textColor = Settings.currentTheme.bodyTextColor
        self.aboutLabel.font = Settings.currentFontSize.bodyTextFont
    }

    func initNoLogoAndNoPhotoLabel() {
        //Noto logo label: init and constraint to bandLogoImageView
        self.noLogoLablel = UILabel(frame: CGRect.zero)
        self.bandLogoImageView.addSubview(self.noLogoLablel)
        
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
        
        //Add Tapgesture
        let tapLogoGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapBandLogo))
        tapLogoGestureRecognizer.numberOfTapsRequired = 1
        self.bandLogoImageView.isUserInteractionEnabled = true
        self.bandLogoImageView.addGestureRecognizer(tapLogoGestureRecognizer)
        
        let tapPhotoGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapBandPhoto))
        tapPhotoGestureRecognizer.numberOfTapsRequired = 1
        self.bandPhotoImageView.isUserInteractionEnabled = true
        self.bandPhotoImageView.addGestureRecognizer(tapPhotoGestureRecognizer)
        
        let tapAboutGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapBandAbout))
        tapAboutGestureRecognizer.numberOfTapsRequired = 1
        self.aboutLabel.isUserInteractionEnabled = true
        self.aboutLabel.addGestureRecognizer(tapAboutGestureRecognizer)
        
        let tapLastModifiedOnLabelGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapLastModifiedOnLabel))
        tapLastModifiedOnLabelGestureRecognizer.numberOfTapsRequired = 1
        self.lastModifiedOnLabel.isUserInteractionEnabled = true
        self.lastModifiedOnLabel.addGestureRecognizer(tapLastModifiedOnLabelGestureRecognizer)
        
        let tapYearsActiveLabel = UITapGestureRecognizer(target: self, action: #selector(didTapYearsActive))
        tapYearsActiveLabel.numberOfTapsRequired = 1
        self.yearsActiveLabel.isUserInteractionEnabled = true
        self.yearsActiveLabel.addGestureRecognizer(tapYearsActiveLabel)
        
        let tapLastLabelLabel = UITapGestureRecognizer(target: self, action: #selector(didTapLastLabelLabel))
        tapLastLabelLabel.numberOfTapsRequired = 1
        self.lastLabelLabel.isUserInteractionEnabled = true
        self.lastLabelLabel.addGestureRecognizer(tapLastLabelLabel)
        
        
        //No photo label: init and contraint to bandPhotoImageView
        self.noPhotoLabel = UILabel(frame: CGRect.zero)
        self.bandPhotoImageView.addSubview(self.noPhotoLabel)
        
        self.noPhotoLabel.translatesAutoresizingMaskIntoConstraints = false
        self.noPhotoLabel.topAnchor.constraint(equalTo: self.noPhotoLabel.superview!.topAnchor).isActive = true
        self.noPhotoLabel.leadingAnchor.constraint(equalTo: self.noPhotoLabel.superview!.leadingAnchor).isActive = true
        self.noPhotoLabel.bottomAnchor.constraint(equalTo: self.noPhotoLabel.superview!.bottomAnchor).isActive = true
        self.noPhotoLabel.trailingAnchor.constraint(equalTo: self.noPhotoLabel.superview!.trailingAnchor).isActive = true
        
        self.noPhotoLabel.text = "Photo not available"
        self.noPhotoLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        self.noPhotoLabel.numberOfLines = 0
        self.noPhotoLabel.textAlignment = .center
        self.noPhotoLabel.textColor = Settings.currentTheme.bodyTextColor
        self.noPhotoLabel.backgroundColor = Settings.currentTheme.backgroundColor
        self.noPhotoLabel.isHidden = true
    }
    
    func fill(with band: Band) {
        self.band = band
        self.reload()
    }
    
    private func reload() {
        if let logoURLString = band.logoURLString {
            self.noLogoLablel.isHidden = true
            self.bandLogoImageView.sd_setShowActivityIndicatorView(true)
            self.bandLogoImageView.sd_setImage(with: URL(string: logoURLString), placeholderImage: nil, options: [.retryFailed], completed: nil)
        } else {
            self.noLogoLablel.isHidden = false
        }
        
        if let photoURLString = band.photoURLString {
            self.noPhotoLabel.isHidden = true
            self.bandPhotoImageView.sd_setShowActivityIndicatorView(true)
            self.bandPhotoImageView.sd_setImage(with: URL(string: photoURLString), placeholderImage: nil, options: [.retryFailed], completed: nil)
        } else {
            self.noPhotoLabel.isHidden = false
        }
        
        self.bandNameLabel.text = band.name
        self.originLabel.text = band.country.nameAndEmoji
        self.locationLabel.text = band.location
        
        self.statusLabel.text = band.status.description
        self.statusLabel.textColor = band.status.color
        
        self.formedInLabel.text = band.formedIn
        
        self.yearsActiveLabel.text = band.yearsActiveString
        if let _ = band.oldBands {
            self.yearsActiveLabel.textColor = Settings.currentTheme.titleColor
            self.yearsActiveLabel.font = Settings.currentFontSize.secondaryTitleFont
        } else {
            self.yearsActiveLabel.textColor = Settings.currentTheme.bodyTextColor
            self.yearsActiveLabel.font = Settings.currentFontSize.bodyTextFont
        }
        
        self.genreLabel.text = band.genre
        self.lyricalThemeLabel.text = band.lyricalTheme
        
        self.lastLabelLabel.text = band.lastLabel.name
        if let _ = band.lastLabel.urlString {
            self.lastLabelLabel.textColor = Settings.currentTheme.titleColor
            self.lastLabelLabel.font = Settings.currentFontSize.secondaryTitleFont
        } else {
            self.lastLabelLabel.textColor = Settings.currentTheme.bodyTextColor
            self.lastLabelLabel.font = Settings.currentFontSize.bodyTextFont
        }
        
        self.aboutLabel.text = band.shortHTMLDescription?.htmlToString
        
        self.setLastModifiedOnLabel()
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
            
            self.lastModifiedOnLabel.text = "Added on: \(addedOnString)\nLast modified on: \(lastModifiedOnString)"
            
        } else if let lastModifiedOnDate = band.auditTrail.modifiedOnDate {
            
            let (value, unit) = lastModifiedOnDate.distanceFromNow()
            self.lastModifiedOnLabel.text = "Updated \(value) \(unit) ago"
        }
    }
    
    @objc private func didTapBandLogo() {
        self.delegate?.didTapBandLogo()
    }
    
    @objc private func didTapBandPhoto() {
        self.delegate?.didTapBandPhoto()
    }
    
    @objc private func didTapBandAbout() {
        self.delegate?.didTapBandAbout()
    }
    
    @objc private func didTapYearsActive() {
        if let _ = self.band.oldBands {
            self.delegate?.didTapYearsActive()
        }
    }
    
    @objc private func didTapLastLabelLabel() {
        if let _ = self.band.lastLabel.urlString {
            self.delegate?.didTapLastLabelLabel()
        }
    }
    
    @objc private func didTapLastModifiedOnLabel() {
        self.fullyDisplayLastModifiedOnDate = !self.fullyDisplayLastModifiedOnDate
        self.setLastModifiedOnLabel()
        self.delegate?.didTapLastModifiedOn()
    }
}
