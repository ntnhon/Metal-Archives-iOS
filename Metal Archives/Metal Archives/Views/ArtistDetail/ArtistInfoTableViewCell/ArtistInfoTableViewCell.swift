//
//  ArtistInfoTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 18/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import SDWebImage

final class ArtistInfoTableViewCell: BaseTableViewCell, RegisterableCell {
    @IBOutlet private weak var realFullNameLabel: UILabel!
    @IBOutlet private weak var ageLabel: UILabel!
    @IBOutlet private weak var ripLabel: UILabel!
    @IBOutlet private weak var diedOfLabel: UILabel!
    @IBOutlet private weak var originLabel: UILabel!
    @IBOutlet private weak var genderLabel: UILabel!
    @IBOutlet private weak var triviaLabel: UILabel!
    @IBOutlet private weak var ripIconImageView: UIImageView!
    @IBOutlet private weak var diedOfIconImageView: UIImageView!
    
    @IBOutlet private var iconImageViews: [UIImageView]!
    @IBOutlet private var detailLabels: [UILabel]!
    
    override func initAppearance() {
        super.initAppearance()
        selectionStyle = .none
        iconImageViews.forEach({
            $0.tintColor = Settings.currentTheme.iconTintColor
        })
        
        detailLabels.forEach({
            $0.textColor = Settings.currentTheme.bodyTextColor
            $0.font = Settings.currentFontSize.bodyTextFont
        })
    }
    
    func fill(with artist: Artist) {
        realFullNameLabel.text = artist.realFullName
        originLabel.text = artist.origin
        genderLabel.text = artist.gender
        ageLabel.text = artist.age

        
        if let rip = artist.rip {
            ripIconImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
            ripLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 18).isActive = true
            ripLabel.text = rip
        } else {
            ripIconImageView.heightAnchor.constraint(equalToConstant: 0).isActive = true
            ripLabel.heightAnchor.constraint(equalToConstant: 0).isActive = true
        }
        
        if let diedOf = artist.diedOf {
            diedOfIconImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
            diedOfLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 18).isActive = true
            diedOfLabel.text = diedOf
        } else {
            diedOfIconImageView.heightAnchor.constraint(equalToConstant: 0).isActive = true
            diedOfLabel.heightAnchor.constraint(equalToConstant: 0).isActive = true
        }

        if let trivia = artist.trivia {
            triviaLabel.text = trivia
        } else {
            triviaLabel.heightAnchor.constraint(equalToConstant: 0).isActive = true
        }
    }
}
