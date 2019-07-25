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
        titleLabel.textColor = Settings.currentTheme.bodyTextColor
        titleLabel.font = Settings.currentFontSize.bodyTextFont
        
        lengthLabel.textColor = Settings.currentTheme.bodyTextColor
        lengthLabel.font = Settings.currentFontSize.bodyTextFont
        
        lyricIconImageView.tintColor = Settings.currentTheme.titleColor
        lyricIconImageView.backgroundColor = Settings.currentTheme.backgroundColor
        lyricIconImageView.isHidden = true
    }
    
    func fill(with element: ReleaseElement) {
        switch element.type {
        case .disc, .side:
            titleLabel.text = element.title
            titleLabel.textAlignment = .left
            lyricIconImageView.isHidden = true
            lengthLabel.isHidden = true
        case .length:
            titleLabel.textAlignment = .right
            titleLabel.text = "Total length:"
            lengthLabel.isHidden = false
            lengthLabel.text = element.title
            lyricIconImageView.isHidden = true
        case .song:
            if let song = element as? Song {
                titleLabel.text = song.title
                titleLabel.textAlignment = .left
                lengthLabel.isHidden = false
                lengthLabel.text = song.length
                lyricIconImageView.isHidden = false
                if let _ = song.lyricID {
                    lyricIconImageView.image = #imageLiteral(resourceName: "lyric")
                } else if song.isInstrumental {
                    lyricIconImageView.image = #imageLiteral(resourceName: "instrumental")
                } else {
                    lyricIconImageView.image = nil
                }
            }
        }
    }
}
