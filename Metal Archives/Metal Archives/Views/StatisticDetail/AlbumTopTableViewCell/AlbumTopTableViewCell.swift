//
//  AlbumTopTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class AlbumTopTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var orderLabel: UILabel!
    @IBOutlet private weak var bandNameLabel: UILabel!
    @IBOutlet private weak var releaseTitleLabel: UILabel!
    @IBOutlet private weak var countLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        orderLabel.textColor = Settings.currentTheme.secondaryTitleColor
        orderLabel.font = Settings.currentFontSize.titleFont
        
        bandNameLabel.textColor = Settings.currentTheme.titleColor
        bandNameLabel.font = Settings.currentFontSize.titleFont
        
        releaseTitleLabel.textColor = Settings.currentTheme.secondaryTitleColor
        releaseTitleLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        countLabel.textColor = Settings.currentTheme.bodyTextColor
        countLabel.font = Settings.currentFontSize.bodyTextFont
    }
    
    func fill(with album: AlbumTop, order: Int) {
        orderLabel.text = "#\(order)"
        bandNameLabel.text = album.band.name
        releaseTitleLabel.text = album.release.title
        countLabel.text = "\(album.count)"
        setThumbnailImageView(with: album)
        setNeedsLayout()
        layoutIfNeeded()
    }
}
