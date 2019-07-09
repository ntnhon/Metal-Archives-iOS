//
//  SimpleSearchTypeTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 08/07/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class SimpleSearchTypeTableViewCell: BaseTableViewCell, RegisterableCell {
    var horizontalOptionsView: HorizontalOptionsView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initHorizontalOptionsView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initHorizontalOptionsView()
    }
    
    private func initHorizontalOptionsView() {
        selectionStyle = .none
        backgroundColor = Settings.currentTheme.backgroundColor
        
        let options = SimpleSearchType.allCases.map({$0.description})
        horizontalOptionsView = HorizontalOptionsView(options: options, font: Settings.currentFontSize.bodyTextFont, textColor: Settings.currentTheme.bodyTextColor, normalColor: Settings.currentTheme.backgroundColor, highlightColor: Settings.currentTheme.secondaryTitleColor)
        horizontalOptionsView.selectedIndex = 0
        
        addSubview(horizontalOptionsView)
        horizontalOptionsView.fillSuperview()
    }
}
