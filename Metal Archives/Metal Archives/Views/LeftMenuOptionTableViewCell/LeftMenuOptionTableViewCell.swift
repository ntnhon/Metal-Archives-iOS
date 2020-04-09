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
        initAppearance()
    }
    
    private func initAppearance() {
        backgroundColor = Settings.currentTheme.leftMenuOptionBackgroundColor
        optionLabel.textColor = Settings.currentTheme.menuTitleColor
        optionLabel.font = Settings.currentFontSize.metalBodyTextFont
        
        optionIconImageView.tintColor = Settings.currentTheme.menuTitleColor
    }
    
    func bind(with option: LeftMenuOption) {
        optionIconImageView.image = UIImage(named: option.iconName)
        optionLabel.text = option.title
    }
    
    func bind(with option: RightMenuOption) {
        optionIconImageView.image = UIImage(named: option.iconName)
        optionLabel.text = option.title
    }
}
