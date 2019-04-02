//
//  BandTopTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class BandTopTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var orderLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var countLabel: UILabel!

    override func initAppearance() {
        super.initAppearance()
        self.orderLabel.textColor = Settings.currentTheme.titleColor
        self.orderLabel.font = Settings.currentFontSize.titleFont
        
        self.nameLabel.textColor = Settings.currentTheme.titleColor
        self.nameLabel.font = Settings.currentFontSize.titleFont
        
        self.countLabel.textColor = Settings.currentTheme.bodyTextColor
        self.countLabel.font = Settings.currentFontSize.bodyTextFont
    }
    
    func fill(with band: BandTop, order: Int) {
        self.orderLabel.text = "#\(order)"
        self.nameLabel.text = band.name
        self.countLabel.text = "\(band.count)"
        self.setThumbnailImageView(with: band, placeHolderImageName: Ressources.Images.band)
    }
}
