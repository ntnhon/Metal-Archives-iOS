//
//  BaseTextField.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 04/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

final class BaseTextField: SkyFloatingLabelTextField {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = Settings.currentTheme.tableViewBackgroundColor.withAlphaComponent(0.4)
        
        self.clearButtonMode = .never
        self.setCustomClearButton(withImage: UIImage(named: Ressources.Images.delete)!, tintColor: Settings.currentTheme.bodyTextColor)
        self.rightViewMode = .whileEditing
        
        self.selectedTitleColor = Settings.currentTheme.titleColor
        self.titleFont = Settings.currentFontSize.titleFont
        
        self.placeholderColor = Settings.currentTheme.bodyTextColor.withAlphaComponent(0.5)
        self.placeholderFont = Settings.currentFontSize.bodyTextFont
        
        self.textColor = Settings.currentTheme.bodyTextColor
        
        self.lineHeight = 0
        self.selectedLineColor = Settings.currentTheme.titleColor
        self.lineColor = Settings.currentTheme.titleColor.withAlphaComponent(0.5)
    }
}
