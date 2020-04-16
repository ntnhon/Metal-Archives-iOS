//
//  ModificationRecordTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 16/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class ModificationRecordTableViewCell: ThumbnailableTableViewCell, RegisterableCell {
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var noteLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        nameLabel.textColor = Settings.currentTheme.titleColor
        nameLabel.font = Settings.currentFontSize.titleFont
        
        noteLabel.textColor = Settings.currentTheme.bodyTextColor
        noteLabel.font = Settings.currentFontSize.bodyTextFont
        
        dateLabel.textColor = Settings.currentTheme.bodyTextColor
        dateLabel.font = Settings.currentFontSize.italicBodyTextFont
    }
    
    func bind(with record: ModificationRecord) {
        nameLabel.text = record.name
        noteLabel.text = record.note
        dateLabel.text = record.dateString
        
        if let thumbnailableObject = record.thumbnailableObject {
            setThumbnailImageView(with: thumbnailableObject)
        }
    }
}
