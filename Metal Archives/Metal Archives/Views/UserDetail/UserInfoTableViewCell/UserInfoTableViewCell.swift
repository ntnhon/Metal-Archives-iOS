//
//  File.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 14/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class UserInfoTableViewCell: BaseTableViewCell, RegisterableCell {
    @IBOutlet private weak var rankLabel: UILabel!
    @IBOutlet private weak var pointsLabel: UILabel!
    @IBOutlet private weak var fullNameLabel: UILabel!
    @IBOutlet private weak var genderLabel: UILabel!
    @IBOutlet private weak var ageLabel: UILabel!
    @IBOutlet private weak var countryLabel: UILabel!
    @IBOutlet private weak var homepageLabel: UILabel!
    @IBOutlet private weak var favoriteGenresLabel: UILabel!
    @IBOutlet private weak var commentsLabel: UILabel!
    
    @IBOutlet private var iconImageViews: [UIImageView]!
    @IBOutlet private var infoLabels: [UILabel]!
    
    override func initAppearance() {
        super.initAppearance()
        
        selectionStyle = .none
        
        iconImageViews.forEach({$0.tintColor = Settings.currentTheme.iconTintColor})
        infoLabels.forEach({
            $0.textColor = Settings.currentTheme.bodyTextColor
            $0.font = Settings.currentFontSize.bodyTextFont
        })
    }
    
    func bind(with userProfile: UserProfile) {
        rankLabel.text = userProfile.rank
        rankLabel.textColor = userProfile.rank.rankColor()
        
        pointsLabel.text = userProfile.points
        fullNameLabel.text = userProfile.fullName ?? "N/A"
        genderLabel.text = userProfile.gender
        ageLabel.text = userProfile.age
        countryLabel.text = userProfile.country.nameAndEmoji
        
        homepageLabel.text = userProfile.homepage ?? "N/A"
        if let _ = userProfile.homepage {
            homepageLabel.textColor = Settings.currentTheme.secondaryTitleColor
        }
        
        favoriteGenresLabel.text = userProfile.favoriteGenres ?? "N/A"
        commentsLabel.text = userProfile.comments ?? "N/A"
    }
}
