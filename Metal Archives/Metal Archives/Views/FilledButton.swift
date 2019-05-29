//
//  FilledButton.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 30/05/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

class FilledButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        customStyle()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customStyle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customStyle()
    }
    
    private func customStyle() {
        setTitleColor(Settings.currentTheme.backgroundColor, for: .normal)
        backgroundColor = Settings.currentTheme.iconTintColor
        layer.cornerRadius = 4
    }
}
