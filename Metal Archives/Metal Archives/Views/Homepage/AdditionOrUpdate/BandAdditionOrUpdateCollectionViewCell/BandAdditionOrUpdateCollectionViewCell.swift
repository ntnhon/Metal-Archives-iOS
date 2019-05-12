//
//  BandAdditionOrUpdateCollectionViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 12/05/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class BandAdditionOrUpdateCollectionViewCell: ThumbnailableCollectionViewCell, RegisterableCell {
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var countryLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var genreLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func initAppearance() {
        super.initAppearance()
        nameLabel.font = Settings.currentFontSize.titleFont
        nameLabel.textColor = Settings.currentTheme.titleColor
        
        countryLabel.font = Settings.currentFontSize.secondaryTitleFont
        countryLabel.textColor = Settings.currentTheme.secondaryTitleColor
        
        dateLabel.font = Settings.currentFontSize.bodyTextFont
        dateLabel.textColor = Settings.currentTheme.bodyTextColor
        
        genreLabel.font = Settings.currentFontSize.bodyTextFont
        genreLabel.textColor = Settings.currentTheme.bodyTextColor
        
        separatorView.backgroundColor = Settings.currentTheme.collectionViewSeparatorColor
    }
    
    func fill(with band: BandAdditionOrUpdate) {
        nameLabel.text = band.name
        countryLabel.text = band.country.nameAndEmoji
        dateLabel.text = band.updatedDateAndTimeString
        genreLabel.text = band.genre
        setThumbnailImageView(with: band)
    }
    
    func showSeparator(_ show: Bool) {
        separatorView.alpha = show ? 0 : 1
    }
}
