//
//  DeezerArtistTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 21/07/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class DeezerArtistTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        nameLabel.textColor = Settings.currentTheme.titleColor
        nameLabel.font = Settings.currentFontSize.titleFont
        nameLabel.numberOfLines = 0
        
        infoLabel.textColor = Settings.currentTheme.bodyTextColor
        infoLabel.font = Settings.currentFontSize.bodyTextFont
    }
    
    func fill(with artist: DeezerArtist) {
        thumbnailImageView.sd_setImage(with: URL(string: artist.picture_xl))
        nameLabel.text = artist.name
        
        let numOfReleaseString = "\(artist.nb_album) " + (artist.nb_album > 1 ? "releases" : "release")
        let numOfFan = "\(artist.nb_fan) " + (artist.nb_fan > 1 ? "fans" : "fan")
        infoLabel.text = numOfReleaseString + " • " + numOfFan
    }
}
