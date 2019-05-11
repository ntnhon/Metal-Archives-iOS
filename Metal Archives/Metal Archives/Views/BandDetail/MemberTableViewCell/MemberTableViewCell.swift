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
        self.nameLabel.textColor = Settings.currentTheme.titleColor
        self.nameLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        self.instrumentsInBandLabel.textColor = Settings.currentTheme.bodyTextColor
        self.instrumentsInBandLabel.font = Settings.currentFontSize.bodyTextFont
        
        self.seeAlsoLabel.textColor = Settings.currentTheme.bodyTextColor
        self.seeAlsoLabel.font = Settings.currentFontSize.bodyTextFont
    }
    
    func bind(with member: ArtistLite) {
        self.nameLabel.text = member.name
        self.instrumentsInBandLabel.text = member.instrumentsInBand
        self.seeAlsoLabel.text = member.seeAlsoString
        self.setThumbnailImageView(with: member)
    }
}
