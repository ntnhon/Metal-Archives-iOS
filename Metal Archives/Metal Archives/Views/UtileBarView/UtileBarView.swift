//
//  UtileBarView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/05/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class UtileBarView: UIView {
    private var backgroundView: UIView!
    private var backButton: UIButton!
    var titleLabel: UILabel!
    private var shareButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubviews()
    }
    
    private func initSubviews() {
        clipsToBounds = false
        backgroundColor = .clear
        
        backgroundView = UIView(frame: .zero)
        backgroundView.backgroundColor = Settings.currentTheme.backgroundColor
        backgroundView.alpha = 0
        addSubview(backgroundView)
        backgroundView.fillSuperview()
        
        backButton = UIButton(type: .system)
        backButton.setImage(#imageLiteral(resourceName: "back"), for: .normal)
        backButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        titleLabel = UILabel(frame: .zero)
        titleLabel.textColor = Settings.currentTheme.bodyTextColor
        titleLabel.font = Settings.currentFontSize.titleFont
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        titleLabel.textAlignment = .center
        titleLabel.alpha = 0
        
        shareButton = UIButton(type: .system)
        shareButton.setImage(#imageLiteral(resourceName: "share"), for: .normal)
        shareButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let stackView = UIStackView(arrangedSubviews: [
            backButton, titleLabel, shareButton
            ])
        stackView.spacing = 4
        stackView.distribution = .fill
        addSubview(stackView)
        stackView.fillSuperview(padding: .init(top: 20, left: 10, bottom: 0, right: 10))
    }
    
    func backgroundAlpha(_ alpha: CGFloat) {
        backgroundView.alpha = alpha
        titleLabel.alpha = alpha
        print(alpha)
    }
}
