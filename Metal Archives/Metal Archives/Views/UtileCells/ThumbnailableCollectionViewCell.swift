//
//  ThumbnailableCollectionViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 12/05/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

class ThumbnailableCollectionViewCell: BaseCollectionViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    //@IBOutlet weak var thumbnailImageViewHeightConstraint: NSLayoutConstraint!
    
    override func initAppearance() {
        super.initAppearance()
        self.thumbnailImageView.backgroundColor = Settings.currentTheme.imageViewBackgroundColor
        self.thumbnailImageView.tintColor = Settings.currentTheme.iconTintColor
        self.thumbnailImageView.contentMode = .scaleAspectFit
        self.thumbnailImageView.sd_setShowActivityIndicatorView(true)
        self.thumbnailImageView.sd_setIndicatorStyle(Settings.currentTheme.activityIndicatorStyle)
        //self.thumbnailImageViewHeightConstraint.constant = Settings.thumbnailHeight
    }
    
    func setThumbnailImageView(with thumbnailableObject: ThumbnailableObject) {
        if thumbnailableObject.noImage || !Settings.thumbnailEnabled {
            self.thumbnailImageView.image = thumbnailableObject.placeHolderImage
            thumbnailableObject.resetStates()
        }
        else if let imageURLString = thumbnailableObject.imageURLString {
            self.thumbnailImageView.sd_setImage(with: URL(string: imageURLString)) { [weak self] (image, error, cachType, url) in
                if let _ = error {
                    thumbnailableObject.retryGenerateImageURLString()
                    self?.setThumbnailImageView(with: thumbnailableObject)
                } else {
                    thumbnailableObject.foundRightURL()
                }
            }
        }
    }
    
}
