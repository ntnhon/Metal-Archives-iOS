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
        selectionStyle = .none
        
        // Init titleLabel
        titleLabel = UILabel(frame: .zero)
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0))
        
        titleLabel.numberOfLines = 0
        titleLabel.font = Settings.currentFontSize.largeTitleFont
        titleLabel.textColor = Settings.currentTheme.bodyTextColor
        titleLabel.textAlignment = .center
        
        // Init typeLabel
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

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        // Init gradientLayer here because this is where the cell's height is defined
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [UIColor.clear.cgColor, Settings.currentTheme.backgroundColor.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func fill(with release: Release) {
        titleLabel.text = release.title
        typeLabel.text = release.type.description
    }
}
