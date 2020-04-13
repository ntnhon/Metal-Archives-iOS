//
//  ReleaseMemberTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 06/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class ReleaseMemberTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var artistNameLabel: UILabel!
    @IBOutlet private weak var bandNameLabel: UILabel!
    @IBOutlet private weak var instrumentsLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        
        artistNameLabel.textColor = Settings.currentTheme.titleColor
        artistNameLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        bandNameLabel.textColor = Settings.currentTheme.bodyTextColor
        bandNameLabel.font = Settings.currentFontSize.boldBodyTextFont
        
        instrumentsLabel.textColor = Settings.currentTheme.bodyTextColor
        instrumentsLabel.font = Settings.currentFontSize.bodyTextFont
    }
    
    func fill(with artist: ArtistLiteInRelease) {
        
        if let additionalDetail = artist.additionalDetail {
            let nameAndDetailString = "\(artist.name) (\(additionalDetail))"
            let mutableAttributedString = NSMutableAttributedString(string: nameAndDetailString)
            mutableAttributedString.addAttributes([.foregroundColor: Settings.currentTheme.titleColor, .font: Settings.currentFontSize.secondaryTitleFont], range: NSRange(nameAndDetailString.startIndex..., in: nameAndDetailString))
            
            if let rangeOfDetail = nameAndDetailString.range(of: "(\(additionalDetail))") {
                mutableAttributedString.addAttributes([.foregroundColor: Settings.currentTheme.bodyTextColor], range: NSRange(rangeOfDetail, in: nameAndDetailString))
            }
            
            artistNameLabel.attributedText = mutableAttributedString
        } else {
            artistNameLabel.text = artist.name
        }
        
        if let bandName = artist.bandName {
            bandNameLabel.text = "\(bandName) member"
        } else {
            bandNameLabel.text = nil
        }

        instrumentsLabel.text = artist.instrumentString
        setThumbnailImageView(with: artist)
    }
}
