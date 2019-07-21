//
//  DeezerTrackTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 21/07/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class DeezerTrackTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var trackTitleLabel: UILabel!
    @IBOutlet private weak var artistNameLabel: UILabel!
    @IBOutlet private weak var nowPlayingImageView: UIImageView!
    
    override func initAppearance() {
        super.initAppearance()
        trackTitleLabel.font = Settings.currentFontSize.secondaryTitleFont
        trackTitleLabel.textColor = Settings.currentTheme.secondaryTitleColor
        trackTitleLabel.numberOfLines = 0
        
        artistNameLabel.font = Settings.currentFontSize.bodyTextFont
        artistNameLabel.textColor = Settings.currentTheme.bodyTextColor
        artistNameLabel.numberOfLines = 0
        
        nowPlayingImageView.tintColor = Settings.currentTheme.bodyTextColor
        nowPlayingImageView.image = #imageLiteral(resourceName: "playing3")
    }
    
    func fill(with track: DeezerTrack) {
        if let album = track.album {
            thumbnailImageView.sd_setImage(with: URL(string: album.cover_xl))
        } else {
            thumbnailImageView.image = #imageLiteral(resourceName: "song")
        }
        
        trackTitleLabel.text = track.title
        artistNameLabel.text = track.artist.name
    }
    
    func setPlaying(_ playing: Bool) {
        nowPlayingImageView.isHidden = !playing
    }
}
