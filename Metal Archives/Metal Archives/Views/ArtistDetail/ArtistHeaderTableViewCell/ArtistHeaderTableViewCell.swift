//
//  ArtistHeaderTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 18/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import SDWebImage

protocol ArtistHeaderTableViewCellDelegate {
    func didTapPhotoImageView()
    func didTapBiographyLabel()
}

final class ArtistHeaderTableViewCell: BaseTableViewCell, RegisterableCell {
    @IBOutlet private weak var photoImageView: UIImageView!
    @IBOutlet private weak var photoImageViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var memberNameLabel: UILabel!
    @IBOutlet private weak var realFullNameLabel: UILabel!
    @IBOutlet private weak var ageLabel: UILabel!
    @IBOutlet private weak var ripLabel: UILabel!
    @IBOutlet private weak var diedOfLabel: UILabel!
    @IBOutlet private weak var originLabel: UILabel!
    @IBOutlet private weak var genderLabel: UILabel!
    @IBOutlet private weak var biographyLabel: UILabel!
    @IBOutlet private weak var ripIconImageView: UIImageView!
    @IBOutlet private weak var diedOfIconImageView: UIImageView!
    
    @IBOutlet private var iconImageViews: [UIImageView]!
    @IBOutlet private var detailLabels: [UILabel]!
    @IBOutlet private var biographyLabelHeightConstraint: NSLayoutConstraint!
    
    private var noPhotoLabel: UILabel!
    
    var delegate: ArtistHeaderTableViewCellDelegate?
    
    override func initAppearance() {
        super.initAppearance()
        self.selectionStyle = .none
        self.iconImageViews.forEach({
            $0.tintColor = Settings.currentTheme.iconTintColor
        })
        
        self.detailLabels.forEach({
            $0.textColor = Settings.currentTheme.bodyTextColor
            $0.font = Settings.currentFontSize.bodyTextFont
        })
        
        self.memberNameLabel.textColor = Settings.currentTheme.bodyTextColor
        
        self.photoImageView.sd_setShowActivityIndicatorView(true)
        self.photoImageViewHeightConstraint.constant = screenHeight/3
        
        //No photo label: init and contraint to photoImageView
        self.noPhotoLabel = UILabel(frame: CGRect.zero)
        self.photoImageView.addSubview(self.noPhotoLabel)
        
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
        
        //Add tap gesture to photoImageView
        self.photoImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapPhotoImageView))
        tap.numberOfTapsRequired = 1
        self.photoImageView.addGestureRecognizer(tap)
        
        //Add tap gesture to biographyLabel
        self.biographyLabel.isUserInteractionEnabled = true
        let tapBiographyLabel = UITapGestureRecognizer(target: self, action: #selector(didTapBiographyLabel))
        tapBiographyLabel.numberOfTapsRequired = 1
        self.biographyLabel.addGestureRecognizer(tapBiographyLabel)
        
        //Add photo image view shadow
        self.photoImageView.layer.shadowColor = Settings.currentTheme.bodyTextColor.cgColor
        self.photoImageView.layer.shadowOffset = .zero
        self.photoImageView.layer.shadowOpacity = 0.7
        self.photoImageView.layer.shadowRadius = 10
        self.photoImageView.layer.shouldRasterize = true
        self.photoImageView.layer.rasterizationScale = UIScreen.main.scale
    }
    
    func fill(with artist: Artist) {
        if let photoURLString = artist.photoURLString {
            self.noPhotoLabel.isHidden = true
            let photoURL = URL(string: photoURLString)
            self.photoImageView.sd_setImage(with: photoURL, placeholderImage: nil, options: [.retryFailed]) { [weak self] (image, error, cacheType, url) in
                if let _ = error {
                    self?.noPhotoLabel.isEnabled = false
                }
            }
        } else {
            self.noPhotoLabel.isHidden = false
        }
        
        self.memberNameLabel.text = artist.bandMemberName
        self.realFullNameLabel.text = artist.realFullName
        self.originLabel.text = artist.origin
        self.genderLabel.text = artist.gender
        self.ageLabel.text = artist.age

        
        if let rip = artist.rip {
            self.ripIconImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
            self.ripLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 18).isActive = true
            self.ripLabel.text = rip
        } else {
            self.ripIconImageView.heightAnchor.constraint(equalToConstant: 0).isActive = true
            self.ripLabel.heightAnchor.constraint(equalToConstant: 0).isActive = true
        }
        
        if let diedOf = artist.diedOf {
            self.diedOfIconImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
            self.diedOfLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 18).isActive = true
            self.diedOfLabel.text = diedOf
        } else {
            self.diedOfIconImageView.heightAnchor.constraint(equalToConstant: 0).isActive = true
            self.diedOfLabel.heightAnchor.constraint(equalToConstant: 0).isActive = true
        }

        if let biography = artist.biography {
            self.biographyLabel.text = biography
        } else {
            self.biographyLabel.heightAnchor.constraint(equalToConstant: 0).isActive = true
        }
    }
    
    @objc private func didTapPhotoImageView() {
        self.delegate?.didTapPhotoImageView()
    }
    
    @objc private func didTapBiographyLabel() {
        self.biographyLabelHeightConstraint.isActive = !self.biographyLabelHeightConstraint.isActive
        self.delegate?.didTapBiographyLabel()
    }
}
