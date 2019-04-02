//
//  ReleaseTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 30/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import SDWebImage

final class ReleaseTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var releaseTitleLabel: UILabel!
    @IBOutlet private weak var releaseTypeLabel: UILabel!
    @IBOutlet private weak var yearLabel: UILabel!
    @IBOutlet private weak var reviewLabel: UILabel!

    override func initAppearance() {
        super.initAppearance()
        self.releaseTypeLabel.textColor = Settings.currentTheme.bodyTextColor
        self.releaseTypeLabel.font = Settings.currentFontSize.bodyTextFont
        
        self.yearLabel.textColor = Settings.currentTheme.bodyTextColor
        self.yearLabel.font = Settings.currentFontSize.bodyTextFont
        
        self.reviewLabel.textColor = Settings.currentTheme.secondaryTitleColor
        self.reviewLabel.font = Settings.currentFontSize.secondaryTitleFont
    }
    
    func fill(with release: ReleaseLite) {
        self.adjustReleaseTitleAttributes(releaseType: release.type)
        self.releaseTitleLabel.text = release.title
        self.releaseTypeLabel.text = release.type.description
        self.yearLabel.text = "\(release.year)"
        
        if let numberOfReviews = release.numberOfReviews, let averagePoint = release.averagePoint {
            self.reviewLabel.text = "\(numberOfReviews) (\(averagePoint)%)"
            self.reviewLabel.textColor = UIColor.colorByRating(averagePoint)
        } else {
            self.reviewLabel.text = ""
        }
        
        self.setThumbnailImageView(with: release, placeHolderImageName: Ressources.Images.vinyl)
    }
    
    private func adjustReleaseTitleAttributes(releaseType: ReleaseType?) {
        guard let `releaseType` = releaseType else { return }
        
        switch releaseType {
        case .fullLength:
            self.releaseTitleLabel.textColor = Settings.currentTheme.titleColor
            self.releaseTitleLabel.font = Settings.currentFontSize.titleFont
        case .demo:
            self.releaseTitleLabel.textColor = Settings.currentTheme.bodyTextColor
            self.releaseTitleLabel.font = Settings.currentFontSize.bodyTextFont
        default:
            self.releaseTitleLabel.textColor = Settings.currentTheme.secondaryTitleColor
            self.releaseTitleLabel.font = Settings.currentFontSize.secondaryTitleFont
        }
    }
}
