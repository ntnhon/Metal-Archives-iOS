//
//  SubLabelTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 25/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class SubLabelTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var nameLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        self.nameLabel.textColor = Settings.currentTheme.titleColor
        self.nameLabel.font = Settings.currentFontSize.titleFont
    }

    func fill(with subLabel: LabelLite) {
        self.nameLabel.text = subLabel.name
        self.setThumbnailImageView(with: subLabel, placeHolderImageName: Ressources.Images.labelIcon)
    }
}
