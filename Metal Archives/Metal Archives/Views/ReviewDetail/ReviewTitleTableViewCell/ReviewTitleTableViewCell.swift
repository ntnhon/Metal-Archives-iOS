//
//  ReviewTitleTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 29/06/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class ReviewTitleTableViewCell: BaseTableViewCell, RegisterableCell {
    private(set) var titleLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        
        titleLabel = UILabel()
        addSubview(titleLabel)
        titleLabel.fillSuperview()
        titleLabel.font = Settings.currentFontSize.reviewTitleFont
        titleLabel.textColor = Settings.currentTheme.reviewTitleColor
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // Init gradientLayer here because this is where the cell's height is defined
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [Settings.currentTheme.backgroundColor.withAlphaComponent(0.1).cgColor, Settings.currentTheme.backgroundColor.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func fill(with title: String) {
        titleLabel.text = title
    }
}
