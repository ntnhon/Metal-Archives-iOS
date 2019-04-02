//
//  LeftMenuOptionTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 14/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class LeftMenuOptionTableViewCell: UITableViewCell, RegisterableCell {
    @IBOutlet private weak var optionIconImageView: UIImageView!
    @IBOutlet private weak var optionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initAppearance()
    }
    
    private func initAppearance() {
        self.backgroundColor = Settings.currentTheme.leftMenuOptionBackgroundColor
        self.optionLabel.textColor = Settings.currentTheme.menuTitleColor
        self.optionLabel.font = Settings.currentFontSize.bodyTextFont
        
        self.optionIconImageView.tintColor = Settings.currentTheme.menuTitleColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initOption(iconName: String, optionName: String) {
        self.optionIconImageView.image = UIImage(named: iconName)
        self.optionLabel.text = optionName
    }
}
