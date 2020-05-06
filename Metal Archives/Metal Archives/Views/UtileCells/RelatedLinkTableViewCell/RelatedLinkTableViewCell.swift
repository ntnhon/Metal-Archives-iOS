//
//  RelatedLinkTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 04/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import SDWebImage

final class RelatedLinkTableViewCell: BaseTableViewCell, RegisterableCell {
    @IBOutlet private weak var favIconImageView: UIImageView!
    @IBOutlet private weak var linkTitleLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        linkTitleLabel.textColor = Settings.currentTheme.bodyTextColor
        linkTitleLabel.font = Settings.currentFontSize.bodyTextFont

        favIconImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        favIconImageView.tintColor = Settings.currentTheme.secondaryTitleColor
    }
    
    func fill(with relatedLink: RelatedLink) {
        linkTitleLabel.text = relatedLink.title
        favIconImageView.sd_setImage(with: URL(string: relatedLink.favIconURLString)) { [weak self] (image, error, cacheType, url) in
            if let _ = error {
                self?.favIconImageView.image = #imageLiteral(resourceName: "hyperlink")
            }
        }
    }
}
