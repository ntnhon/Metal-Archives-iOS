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
        self.artistNameLabel.textColor = Settings.currentTheme.titleColor
        self.artistNameLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        self.instrumentsLabel.textColor = Settings.currentTheme.bodyTextColor
        self.instrumentsLabel.font = Settings.currentFontSize.bodyTextFont
    }
    
    func fill(with artist: ArtistLiteInRelease) {
        self.artistNameLabel.text = artist.name
        self.instrumentsLabel.text = artist.instrumentString
        self.setThumbnailImageView(with: artist)
    }
}
