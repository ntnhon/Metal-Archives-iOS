//
//  MemberTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 02/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class MemberTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var instrumentsInBandLabel: UILabel!
    @IBOutlet private weak var seeAlsoLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        
        nameLabel.textColor = Settings.currentTheme.titleColor
        nameLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        instrumentsInBandLabel.textColor = Settings.currentTheme.bodyTextColor
        instrumentsInBandLabel.font = Settings.currentFontSize.bodyTextFont
        
        seeAlsoLabel.textColor = Settings.currentTheme.bodyTextColor
        seeAlsoLabel.font = Settings.currentFontSize.bodyTextFont
    }
    
    func fill(with member: ArtistLite) {
        nameLabel.text = member.name
        instrumentsInBandLabel.text = member.instrumentsInBand
        seeAlsoLabel.attributedText = member.seeAlsoAttributedString
        setThumbnailImageView(with: member)
    }
}
