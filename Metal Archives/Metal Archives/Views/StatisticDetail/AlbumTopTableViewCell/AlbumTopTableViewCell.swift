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
        self.orderLabel.textColor = Settings.currentTheme.titleColor
        self.orderLabel.font = Settings.currentFontSize.titleFont
        
        self.bandNameLabel.textColor = Settings.currentTheme.titleColor
        self.bandNameLabel.font = Settings.currentFontSize.titleFont
        
        self.releaseTitleLabel.textColor = Settings.currentTheme.secondaryTitleColor
        self.releaseTitleLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        self.countLabel.textColor = Settings.currentTheme.bodyTextColor
        self.countLabel.font = Settings.currentFontSize.bodyTextFont
    }
    
    func fill(with album: AlbumTop, order: Int) {
        self.orderLabel.text = "#\(order)"
        self.bandNameLabel.text = album.band.name
        self.releaseTitleLabel.text = album.release.title
        self.countLabel.text = "\(album.count)"
        self.setThumbnailImageView(with: album)
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
}
