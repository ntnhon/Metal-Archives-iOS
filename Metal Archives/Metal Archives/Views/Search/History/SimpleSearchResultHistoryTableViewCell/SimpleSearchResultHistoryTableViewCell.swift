//
//  SimpleSearchResultHistoryTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 08/07/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import SDWebImage

final class SimpleSearchResultHistoryTableViewCell: BaseTableViewCell, RegisterableCell {
    @IBOutlet private weak var thumbnailImageView: UIImageView!
    @IBOutlet private weak var thumbnailImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var nameOrTitleLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        thumbnailImageView.sd_showActivityIndicatorView()
        thumbnailImageViewHeightConstraint.constant = Settings.thumbnailHeight
        
        nameOrTitleLabel.textColor = Settings.currentTheme.bodyTextColor
        nameOrTitleLabel.font = Settings.currentFontSize.bodyTextFont
    }
    
    func fill(with searchHistory: SearchHistory) {
        guard let nameOrTitle = searchHistory.nameOrTitle, let objectType = SearchResultObjectType(rawValue: Int(searchHistory.objectType)) else {
            return
        }
        
        nameOrTitleLabel.text = nameOrTitle
        
        if let thumbnailUrlString = searchHistory.thumbnailUrlString,
            let thumbnailURL = URL(string: thumbnailUrlString) {
            thumbnailImageView.sd_setImage(with: thumbnailURL)
        } else {
            switch objectType {
            case .band: thumbnailImageView.image = #imageLiteral(resourceName: "band")
            case .release: thumbnailImageView.image = #imageLiteral(resourceName: "vinyl")
            case .artist: thumbnailImageView.image = #imageLiteral(resourceName: "person")
            case .label: thumbnailImageView.image = #imageLiteral(resourceName: "label")
            }
        }
    }
}
