//
//  NewsCollectionViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 12/05/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import AttributedLib

final class NewsCollectionViewCell: BaseCollectionViewCell, RegisterableCell {
    @IBOutlet private weak var textLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func initAppearance() {
        super.initAppearance()
        textLabel.textColor = Settings.currentTheme.bodyTextColor
        textLabel.font = Settings.currentFontSize.bodyTextFont
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .justified
        textLabel.lineBreakMode = .byTruncatingTail
    }
    
    func fill(with news: News) {
        self.textLabel.attributedText = news.summaryAttributedText
    }
}
