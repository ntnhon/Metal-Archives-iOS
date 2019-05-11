//
//  UpcomingAlbumTableViewCell.swift
//  Metal Archives Widget
//
//  Created by Thanh-Nhon Nguyen on 21/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class UpcomingAlbumTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var bandsNameLabel: UILabel!
    @IBOutlet private weak var releaseTitleLabel: UILabel!
    @IBOutlet private weak var releaseTypeLabel: UILabel!
    @IBOutlet private weak var genreLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initAppearance()
    }
    
    private func initAppearance() {
        self.bandsNameLabel.textColor = Theme.light.titleColor
        self.bandsNameLabel.font = FontSize.default.titleFont
        
        self.releaseTitleLabel.textColor = Theme.light.bodyTextColor
        self.releaseTitleLabel.font = FontSize.default.secondaryTitleFont
        
        self.releaseTypeLabel.textColor = Theme.light.bodyTextColor
        self.releaseTypeLabel.font = FontSize.default.bodyTextFont
        
        self.genreLabel.textColor = Theme.light.bodyTextColor
        self.genreLabel.font = FontSize.default.bodyTextFont
        
        self.dateLabel.textColor = Theme.light.bodyTextColor
        self.dateLabel.font = FontSize.default.bodyTextFont
    }

    func fill(with upcomingAlbum: UpcomingAlbum) {
        var bandsNames: String = ""
        for i in 0..<upcomingAlbum.bands.count {
            let eachBand = upcomingAlbum.bands[i]
            if i == upcomingAlbum.bands.count - 1 {
                bandsNames.append("\(eachBand.name)")
            } else {
                bandsNames.append("\(eachBand.name) / ")
            }
        }
        
        self.bandsNameLabel.text = bandsNames
        
        self.releaseTitleLabel.text = upcomingAlbum.release.name
        self.releaseTypeLabel.text = upcomingAlbum.releaseType.description
        self.genreLabel.text = upcomingAlbum.genre
        self.dateLabel.text = upcomingAlbum.date
        self.setThumbnailImageView(with: upcomingAlbum.release)
    }
}
