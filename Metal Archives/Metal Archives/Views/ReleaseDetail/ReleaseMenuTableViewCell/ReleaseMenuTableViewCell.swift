//
//  ReleaseMenuTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 01/06/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class ReleaseMenuTableViewCell: BaseTableViewCell, RegisterableCell {
    
    private(set) var horizontalMenuView: HorizontalMenuView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = Settings.currentTheme.backgroundColor
        
        let releaseMenuOptionStrings = ReleaseMenuOption.allCases.map({return $0.description})
        horizontalMenuView = HorizontalMenuView(options: releaseMenuOptionStrings, font: Settings.currentFontSize.secondaryTitleFont, normalColor: Settings.currentTheme.bodyTextColor, highlightColor: Settings.currentTheme.secondaryTitleColor)
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
