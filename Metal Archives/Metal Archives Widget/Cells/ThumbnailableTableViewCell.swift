//
//  ThumbnailableTableViewCell.swift
//  Metal Archives Widget
//
//  Created by Thanh-Nhon Nguyen on 20/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//
import UIKit
import SDWebImage

class ThumbnailableTableViewCell: UITableViewCell {
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var thumbnailImageViewHeightConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.thumbnailImageView.contentMode = .scaleAspectFit
        self.thumbnailImageView.sd_setShowActivityIndicatorView(true)
        self.thumbnailImageView.sd_setIndicatorStyle(.gray)
        self.thumbnailImageViewHeightConstraint.constant = Settings.thumbnailHeight
    }
    
    func setThumbnailImageView(with thumbnailableObject: ThumbnailableObject) {
        if thumbnailableObject.noImage {
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

