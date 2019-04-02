//
//  NewsDetailTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class NewsDetailTableViewCell: BaseTableViewCell, RegisterableCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var contentLabel: UILabel!
    @IBOutlet private weak var authorLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        self.titleLabel.textColor = Settings.currentTheme.titleColor
        self.titleLabel.font = Settings.currentFontSize.titleFont
        
        self.contentLabel.textColor = Settings.currentTheme.bodyTextColor
        self.contentLabel.font = Settings.currentFontSize.bodyTextFont
        
        self.authorLabel.textColor = Settings.currentTheme.bodyTextColor
        self.authorLabel.font = Settings.currentFontSize.bodyTextFont
        
        self.dateLabel.textColor = Settings.currentTheme.bodyTextColor
        self.dateLabel.font = Settings.currentFontSize.bodyTextFont
    }
    
    func fill(with news: News) {
        self.titleLabel.text = news.title
        
        let (distanceValue, distanceUnit) = news.date.distanceFromNow()
        
        self.dateLabel.text = "\(news.dateAndTimeString) (\(distanceValue) \(distanceUnit) ago)"
        self.contentLabel.text = news.htmlBody
        self.authorLabel.text = "-\(news.author)"
    }
}

