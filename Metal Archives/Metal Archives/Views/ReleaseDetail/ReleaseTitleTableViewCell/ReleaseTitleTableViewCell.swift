//
//  ReleaseTitleTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 31/05/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class ReleaseTitleTableViewCell: BaseTableViewCell, RegisterableCell {
    var titleLabel: UILabel!
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        super.initAppearance()
        backgroundColor = .clear
        selectionStyle = .none
        
        titleLabel = UILabel(frame: .zero)
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.fillSuperview(padding: .init(top: 10, left: 0, bottom: 10, right: 0))
        
        titleLabel.font = Settings.currentFontSize.largeTitleFont
        titleLabel.textColor = Settings.currentTheme.bodyTextColor
        titleLabel.textAlignment = .center
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
