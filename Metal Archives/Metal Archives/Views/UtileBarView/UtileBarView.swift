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
    
    var didTapBackButton: (() -> Void)?
    var didTapShareButton: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
        initActions()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubviews()
        initActions()
    }
    
    private func initSubviews() {
        clipsToBounds = false
        backgroundColor = .clear
        
        // Init backgroundView
        backgroundView = UIView(frame: .zero)
        backgroundView.backgroundColor = Settings.currentTheme.backgroundColor
        backgroundView.alpha = 0
        addSubview(backgroundView)
        backgroundView.fillSuperview()
        
        // Init backButton
        backButton = UIButton(type: .system)
        backButton.contentEdgeInsets = .init(top: 0, left: 10, bottom: 0, right: 20)
        backButton.setImage(#imageLiteral(resourceName: "back"), for: .normal)
        backButton.tintColor = Settings.currentTheme.bodyTextColor
        addSubview(backButton)
        backButton.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: nil, padding: .init(top: 0, left: 0, bottom: 10, right: 0))
        backButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        // Init titleLabel
        titleLabel = UILabel(frame: .zero)
        titleLabel.textColor = Settings.currentTheme.bodyTextColor
        titleLabel.font = Settings.currentFontSize.titleFont
        titleLabel.textAlignment = .center
        titleLabel.alpha = 0
        addSubview(titleLabel)
        titleLabel.anchor(top: nil, leading: backButton.trailingAnchor, bottom: bottomAnchor, trailing: nil, padding: .init(top: 0, left: 10, bottom: 10, right: 0))
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        
        // Init shareButton
        shareButton = UIButton(type: .system)
        shareButton.contentEdgeInsets = .init(top: 0, left: 20, bottom: 0, right: 20)
        shareButton.setImage(#imageLiteral(resourceName: "share"), for: .normal)
        shareButton.tintColor = Settings.currentTheme.bodyTextColor
        addSubview(shareButton)
        shareButton.anchor(top: nil, leading: titleLabel.trailingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 10, bottom: 10, right: -10))
        shareButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
//
//        let stackView = UIStackView(arrangedSubviews: [
//            backButton, titleLabel, shareButton
//            ])
//        stackView.spacing = 4
//        stackView.distribution = .fill
//        addSubview(stackView)
//        stackView.fillSuperview(padding: .init(top: 20, left: 10, bottom: 0, right: 10))
    }
    
    private func initActions() {
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
    }
    
    func setAlphaForBackgroundAndTitleLabel(_ alpha: CGFloat) {
        backgroundView.alpha = alpha
        titleLabel.alpha = alpha
    }
    
    @objc private func backButtonTapped() {
        didTapBackButton?()
    }
    
    @objc private func shareButtonTapped() {
        didTapShareButton?()
    }
}
