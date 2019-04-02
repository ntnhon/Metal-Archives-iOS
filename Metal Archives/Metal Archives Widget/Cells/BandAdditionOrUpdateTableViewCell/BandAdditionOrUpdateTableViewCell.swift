//
//  BandAdditionOrUpdateTableViewCell.swift
//  Metal Archives Widget
//
//  Created by Thanh-Nhon Nguyen on 20/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class BandAdditionOrUpdateTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var countryLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var genreLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initAppearance()
    }
    
    private func initAppearance() {
        self.titleLabel.textColor = Theme.light.titleColor
        self.titleLabel.font = FontSize.default.titleFont
        
        self.countryLabel.textColor = Theme.light.bodyTextColor
        self.countryLabel.font = FontSize.default.secondaryTitleFont
        
        self.dateLabel.textColor = Theme.light.bodyTextColor
        self.dateLabel.font = FontSize.default.bodyTextFont
        
        self.genreLabel.textColor = Theme.light.bodyTextColor
        self.genreLabel.font = FontSize.default.bodyTextFont
    }

    func fill(with band: BandAdditionOrUpdate) {
        self.titleLabel.text = band.name
        self.dateLabel.text = band.updatedDateAndTimeString
        self.countryLabel.text = band.country.nameAndEmoji
        self.genreLabel.text = band.genre
        self.setThumbnailImageView(with: band, placeHolderImageName: Ressources.Images.band)
    }
}
