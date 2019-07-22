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
    @IBOutlet private weak var dateOrArtistAndTypeLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        albumTitleLabel.textColor = Settings.currentTheme.titleColor
        albumTitleLabel.font = Settings.currentFontSize.titleFont
        
        dateOrArtistAndTypeLabel.textColor = Settings.currentTheme.bodyTextColor
        dateOrArtistAndTypeLabel.font = Settings.currentFontSize.bodyTextFont
    }
    
    func fill(with album: DeezerAlbum) {
        thumbnailImageView.sd_setImage(with: URL(string: album.cover_xl))
        albumTitleLabel.text = album.title
        
        if let releaseDateString = album.release_date {
            dateOrArtistAndTypeLabel.text = album.artist.name + " • " + releaseDateString + " • " + album.record_type
        } else {
            dateOrArtistAndTypeLabel.text = album.artist.name + " • " + album.record_type
        }
    }
}
