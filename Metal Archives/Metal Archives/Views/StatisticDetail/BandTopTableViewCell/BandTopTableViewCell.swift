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
        orderLabel.textColor = Settings.currentTheme.secondaryTitleColor
        orderLabel.font = Settings.currentFontSize.titleFont
        
        nameLabel.textColor = Settings.currentTheme.titleColor
        nameLabel.font = Settings.currentFontSize.titleFont
        
        countLabel.textColor = Settings.currentTheme.bodyTextColor
        countLabel.font = Settings.currentFontSize.bodyTextFont
    }
    
    func fill(with band: BandTop, order: Int) {
        orderLabel.text = "#\(order)"
        nameLabel.text = band.name
        countLabel.text = "\(band.count)"
        setThumbnailImageView(with: band)
    }
}
