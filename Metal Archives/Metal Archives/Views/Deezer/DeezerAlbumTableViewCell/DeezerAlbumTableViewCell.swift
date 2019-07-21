//
//  DeezerAlbumTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 21/07/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class DeezerAlbumTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var albumTitleLabel: UILabel!
    @IBOutlet private weak var dateAndTypeLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        albumTitleLabel.textColor = Settings.currentTheme.titleColor
        albumTitleLabel.font = Settings.currentFontSize.titleFont
        
        dateAndTypeLabel.textColor = Settings.currentTheme.bodyTextColor
        dateAndTypeLabel.font = Settings.currentFontSize.bodyTextFont
    }
    
    func fill(with album: DeezerAlbum) {
        thumbnailImageView.sd_setImage(with: URL(string: album.cover_xl))
        albumTitleLabel.text = album.title
        dateAndTypeLabel.text = album.release_date + " • " + album.record_type
    }
}
