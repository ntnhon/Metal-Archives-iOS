//
//  NewsTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 14/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class NewsTableViewCell: BaseTableViewCell, RegisterableCell {
    @IBOutlet fileprivate weak var headlineLabel: UILabel!
    @IBOutlet fileprivate weak var dateLabel: UILabel!
    @IBOutlet fileprivate weak var detailLabel: UILabel!

    override func initAppearance() {
        super.initAppearance()
        self.headlineLabel.textColor = Settings.currentTheme.titleColor
        self.headlineLabel.font = Settings.currentFontSize.titleFont
        
        self.dateLabel.textColor = Settings.currentTheme.secondaryTitleColor
        self.dateLabel.font = Settings.currentFontSize.secondaryTitleFont
        
        self.detailLabel.textColor = Settings.currentTheme.bodyTextColor
        self.detailLabel.font = Settings.currentFontSize.bodyTextFont
    }
    
    func fill(with news: News) {
        self.headlineLabel.text = news.title
        
        let (distanceValue, distanceUnit) = news.date.distanceFromNow()
        
        self.dateLabel.text = "Published by \(news.author) on \(news.dateString)\n(\(distanceValue) \(distanceUnit) ago)"
        
        self.detailLabel.text = news.htmlBody
    }
}
