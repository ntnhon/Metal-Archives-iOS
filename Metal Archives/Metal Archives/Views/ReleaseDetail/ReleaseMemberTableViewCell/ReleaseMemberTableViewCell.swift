//
//  ReleaseMemberTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 06/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class ReleaseMemberTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var artistNameLabel: UILabel!
    @IBOutlet private weak var instrumentsLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        thumbnailImageViewHeightConstraint.constant = screenWidth / 5
        
        artistNameLabel.textColor = Settings.currentTheme.titleColor
        artistNameLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        instrumentsLabel.textColor = Settings.currentTheme.bodyTextColor
        instrumentsLabel.font = Settings.currentFontSize.bodyTextFont
    }
    
    func fill(with artist: ArtistLiteInRelease) {
        artistNameLabel.text = artist.name
        instrumentsLabel.text = artist.instrumentString
        setThumbnailImageView(with: artist)
    }
}
