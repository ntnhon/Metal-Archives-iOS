//
//  BandPhotoAndNameTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 24/05/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class BandPhotoAndNameTableViewCell: BaseTableViewCell, RegisterableCell {
    @IBOutlet private weak var photoImageViewBackgroundView: UIView!
    @IBOutlet private weak var photoImageViewBackgroundViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private(set) weak var photoImageView: UIImageView!
    @IBOutlet private weak var photoImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private(set) weak var nameLabel: UILabel!
    
    var tappedPhotoImageView: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func initAppearance() {
        super.initAppearance()
        clipsToBounds = false
        backgroundColor = .clear
        
        nameLabel.font = Settings.currentFontSize.largeTitleFont
        nameLabel.textColor = Settings.currentTheme.bodyTextColor
        
        // background view to make outer border effect
        photoImageViewBackgroundView.backgroundColor = Settings.currentTheme.bodyTextColor
        photoImageViewBackgroundViewHeightConstraint.constant = Settings.bandPhotoImageViewHeight + 5
        
        photoImageViewHeightConstraint.constant = Settings.bandPhotoImageViewHeight
        
        photoImageView.sd_showActivityIndicatorView()
        photoImageView.isUserInteractionEnabled = true
        let photoImageViewTapGestureRegconizer = UITapGestureRecognizer(target: self, action: #selector(photoImageViewTapped))
        photoImageView.addGestureRecognizer(photoImageViewTapGestureRegconizer)
    }
    
    func fill(with band: Band) {
        if let photoURLString = band.photoURLString, let photoURL = URL(string: photoURLString) {
            photoImageView.sd_setImage(with: photoURL, placeholderImage: nil, options: [.retryFailed], completed: nil)
        } else {
            photoImageView.image = #imageLiteral(resourceName: "band")
            photoImageView.backgroundColor = Settings.currentTheme.backgroundColor
            photoImageView.contentMode = .scaleAspectFit
        }
        
        nameLabel.text = band.name
    }
    
    @objc private func photoImageViewTapped() {
        tappedPhotoImageView?()
    }
}
