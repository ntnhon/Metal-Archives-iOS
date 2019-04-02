//
//  RelatedLinkTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 04/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class RelatedLinkTableViewCell: BaseTableViewCell, RegisterableCell {
    @IBOutlet private weak var favIconImageView: UIImageView!
    @IBOutlet private weak var linkTitleLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        self.linkTitleLabel.textColor = Settings.currentTheme.bodyTextColor
        self.linkTitleLabel.font = Settings.currentFontSize.bodyTextFont

        self.favIconImageView.sd_setShowActivityIndicatorView(true)
        self.favIconImageView.tintColor = Settings.currentTheme.secondaryTitleColor
    }
    
    func bind(relatedLink: RelatedLink) {
        self.linkTitleLabel.text = relatedLink.title
        self.favIconImageView.sd_setImage(with: URL(string: relatedLink.favIconURLString)!) { [weak self] (image, error, cacheType, url) in
            if let _ = error {
                self?.favIconImageView.image = #imageLiteral(resourceName: "hyperlink")
            }
        }
    }
}
