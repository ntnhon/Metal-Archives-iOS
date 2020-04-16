//
//  SimpleUserTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 16/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class SimpleUserTableViewCell: BaseTableViewCell, RegisterableCell {
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var rankLabel: UILabel!
    @IBOutlet private weak var pointsLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        usernameLabel.textColor = Settings.currentTheme.titleColor
        usernameLabel.font = Settings.currentFontSize.titleFont
        
        rankLabel.textColor = Settings.currentTheme.bodyTextColor
        rankLabel.font = Settings.currentFontSize.bodyTextFont
        
        pointsLabel.textColor = Settings.currentTheme.bodyTextColor
        pointsLabel.font = Settings.currentFontSize.italicBodyTextFont
    }
    
    func bind(with result: SimpleSearchResultUser) {
        usernameLabel.text = result.username
        rankLabel.text = result.rank
        rankLabel.textColor = result.rank.rankColor()
        pointsLabel.text = result.points
    }
}
