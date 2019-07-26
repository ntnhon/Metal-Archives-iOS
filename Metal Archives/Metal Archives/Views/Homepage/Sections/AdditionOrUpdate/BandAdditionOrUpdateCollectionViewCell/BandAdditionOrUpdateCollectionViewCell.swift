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
    @IBOutlet private weak var countryAndDateLabel: UILabel!
    @IBOutlet private weak var genreLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func initAppearance() {
        super.initAppearance()
        nameLabel.font = Settings.currentFontSize.titleFont
        nameLabel.textColor = Settings.currentTheme.titleColor
        
        countryAndDateLabel.font = Settings.currentFontSize.secondaryTitleFont
        countryAndDateLabel.textColor = Settings.currentTheme.secondaryTitleColor
        
        genreLabel.font = Settings.currentFontSize.italicBodyTextFont
        genreLabel.textColor = Settings.currentTheme.bodyTextColor
        
        separatorView.backgroundColor = Settings.currentTheme.collectionViewSeparatorColor
    }
    
    func fill(with band: BandAdditionOrUpdate) {
        nameLabel.text = band.name
        countryAndDateLabel.attributedText = band.countryAndDateAttributedString
        genreLabel.text = band.genre
        setThumbnailImageView(with: band)
    }
    
    func showSeparator(_ show: Bool) {
        separatorView.alpha = show ? 0 : 1
    }
}
