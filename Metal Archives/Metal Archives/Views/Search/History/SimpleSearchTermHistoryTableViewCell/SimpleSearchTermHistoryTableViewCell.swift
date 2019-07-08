//
//  SimpleSearchTermHistoryTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 08/07/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class SimpleSearchTermHistoryTableViewCell: BaseTableViewCell, RegisterableCell {
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var searchTermLabel: UILabel!
    @IBOutlet private weak var searchTypeLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        iconImageView.tintColor = Settings.currentTheme.bodyTextColor
        
        searchTermLabel.textColor = Settings.currentTheme.bodyTextColor
        searchTermLabel.font = Settings.currentFontSize.bodyTextFont
        
        searchTypeLabel.textColor = Settings.currentTheme.bodyTextColor
        searchTypeLabel.font = Settings.currentFontSize.italicBodyTextFont
    }
    
    func fill(with searchHistory: SearchHistory) {
        guard let term = searchHistory.term,
            let type = SimpleSearchType(rawValue: Int(searchHistory.searchType)) else {
                return
        }
        
        searchTermLabel.text = term
        searchTypeLabel.text = type.description
    }
}
