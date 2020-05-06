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
    
    var tappedThumbnailImageView: (() -> Void)?
    
    override func initAppearance() {
        super.initAppearance()
        thumbnailImageView.backgroundColor = Settings.currentTheme.imageViewBackgroundColor
        thumbnailImageView.tintColor = Settings.currentTheme.iconTintColor
        thumbnailImageView.contentMode = .scaleAspectFit
        thumbnailImageView.sd_imageIndicator = Settings.currentTheme.activityIndicator
        
        let thumbnailImageViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapThumbnailImageView))
        thumbnailImageView.isUserInteractionEnabled = true
        thumbnailImageView.addGestureRecognizer(thumbnailImageViewTapGesture)
    }
    
    @objc private func didTapThumbnailImageView() {
        tappedThumbnailImageView?()
    }
    
    func setThumbnailImageView(with thumbnailableObject: ThumbnailableObject) {
        if thumbnailableObject.noImage || !Settings.thumbnailEnabled {
            thumbnailImageView.image = thumbnailableObject.placeHolderImage
            thumbnailableObject.resetStates()
        }
        else if let imageURLString = thumbnailableObject.imageURLString {
            thumbnailImageView.sd_setImage(with: URL(string: imageURLString)) { [weak self] (image, error, cachType, url) in
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
