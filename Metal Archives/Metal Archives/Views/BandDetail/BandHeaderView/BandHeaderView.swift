//
//  BandHeaderView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/05/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class BandHeaderView: UITableViewHeaderFooterView {
    @IBOutlet private weak var photoImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var genreLabel: UILabel!
    @IBOutlet private weak var countryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.textColor = Settings.currentTheme.bodyTextColor
        nameLabel.font = Settings.currentFontSize.titleFont
        
        genreLabel.textColor = Settings.currentTheme.bodyTextColor
        genreLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        countryLabel.textColor = Settings.currentTheme.bodyTextColor
        countryLabel.font = Settings.currentFontSize.bodyTextFont
    }
    
    func fill(with band: Band) {
        if let photoURLString = band.photoURLString, let photoURL = URL(string: photoURLString) {
            photoImageView.sd_setImage(with: photoURL)
        }
        
        nameLabel.text = band.name
        genreLabel.text = band.genre
        countryLabel.text = band.country.nameAndEmoji
    }
}
