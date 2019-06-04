//
//  LabelNameTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 04/06/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class LabelNameTableViewCell: BaseTableViewCell, RegisterableCell {
    private(set) var nameLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        
        nameLabel = UILabel()
        addSubview(nameLabel)
        nameLabel.fillSuperview()
        nameLabel.font = Settings.currentFontSize.largeTitleFont
        nameLabel.textColor = Settings.currentTheme.bodyTextColor
        nameLabel.numberOfLines = 0
        nameLabel.textAlignment = .center
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
    
    func fill(with name: String) {
        nameLabel.text = name
    }
}
