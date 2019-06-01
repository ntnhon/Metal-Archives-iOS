//
//  ReleaseTitleTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 31/05/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class ReleaseTitleAndTypeTableViewCell: BaseTableViewCell, RegisterableCell {
    private(set) var titleLabel: UILabel!
    private var typeLabel: UILabel!
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        super.initAppearance()
        backgroundColor = .clear
        selectionStyle = .none
        
        titleLabel = UILabel(frame: .zero)
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0))
        
        titleLabel.numberOfLines = 0
        titleLabel.font = Settings.currentFontSize.largeTitleFont
        titleLabel.textColor = Settings.currentTheme.bodyTextColor
        titleLabel.textAlignment = .center
        
        typeLabel = UILabel(frame: .zero)
        addSubview(typeLabel)
        typeLabel.anchor(top: titleLabel.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 5, left: 0, bottom: 10, right: 0))
        
        typeLabel.numberOfLines = 0
        typeLabel.font = Settings.currentFontSize.titleFont
        typeLabel.textColor = Settings.currentTheme.bodyTextColor
        typeLabel.textAlignment = .center
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fill(with release: Release) {
        titleLabel.text = release.title
        typeLabel.text = release.type.description
        
        print(titleLabel.frame)
        print(typeLabel.frame)
    }
}
