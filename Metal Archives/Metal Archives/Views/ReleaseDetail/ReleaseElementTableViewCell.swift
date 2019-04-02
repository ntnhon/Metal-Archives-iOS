//
//  ReleaseElementTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 06/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class ReleaseElementTableViewCell: BaseTableViewCell, RegisterableCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var lengthLabel: UILabel!
    @IBOutlet private weak var lyricIconImageView: UIImageView!

    override func initAppearance() {
        super.initAppearance()
        self.titleLabel.textColor = Settings.currentTheme.bodyTextColor
        self.titleLabel.font = Settings.currentFontSize.bodyTextFont
        
        self.lengthLabel.textColor = Settings.currentTheme.bodyTextColor
        self.lengthLabel.font = Settings.currentFontSize.bodyTextFont
        
        self.lyricIconImageView.tintColor = Settings.currentTheme.titleColor
        self.lyricIconImageView.backgroundColor = Settings.currentTheme.backgroundColor
        self.lyricIconImageView.isHidden = true
    }
    
    func fill(with element: ReleaseElement) {
        switch element.type {
        case .disc, .side:
            self.titleLabel.text = element.title
            self.titleLabel.textAlignment = .left
            self.lyricIconImageView.isHidden = true
            self.lengthLabel.isHidden = true
        case .length:
            self.titleLabel.textAlignment = .right
            self.titleLabel.text = "Total length:"
            self.lengthLabel.isHidden = false
            self.lengthLabel.text = element.title
            self.lyricIconImageView.isHidden = true
        case .song:
            if let song = element as? Song {
                self.titleLabel.text = song.title
                self.titleLabel.textAlignment = .left
                self.lengthLabel.isHidden = false
                self.lengthLabel.text = song.length
                self.lyricIconImageView.isHidden = (song.lyricID == nil)
            }
        }
    }
}
