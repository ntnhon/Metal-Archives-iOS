//
//  LabelMenuTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 04/06/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class LabelMenuTableViewCell: BaseTableViewCell, RegisterableCell {
    
    private(set) var horizontalMenuView: HorizontalMenuView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = Settings.currentTheme.backgroundColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initMenu(with options: [String]) {
        if horizontalMenuView == nil {
            horizontalMenuView = HorizontalMenuView(options: options, font: Settings.currentFontSize.secondaryTitleFont, normalColor: Settings.currentTheme.bodyTextColor, highlightColor: Settings.currentTheme.secondaryTitleColor)
            horizontalMenuView.backgroundColor = Settings.currentTheme.backgroundColor
            addSubview(horizontalMenuView)
            
            horizontalMenuView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                horizontalMenuView.topAnchor.constraint(equalTo: topAnchor),
                horizontalMenuView.leadingAnchor.constraint(equalTo: leadingAnchor),
                horizontalMenuView.bottomAnchor.constraint(equalTo: bottomAnchor),
                horizontalMenuView.trailingAnchor.constraint(equalTo: trailingAnchor),
                horizontalMenuView.heightAnchor.constraint(equalToConstant: horizontalMenuView.intrinsicHeight)
                ])
        }
    }
}

