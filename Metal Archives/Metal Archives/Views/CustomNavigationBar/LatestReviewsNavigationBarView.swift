//
//  LatestReviewsNavigationBarView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 29/06/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class LatestReviewsNavigationBarView: BaseNavigationBarView, TransformableWithScrollView {
    private var titleLabel: UILabel!
    private var backButton: UIButton!
    private(set) var monthButton: UIButton!
    
    var didTapBackButton: (() -> Void)?
    var didTapMonthButton: (() -> Void)?
    
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
        backgroundColor = Settings.currentTheme.backgroundColor
        
        // Init backButton
        backButton = UIButton(type: .system)
        backButton.contentEdgeInsets = .init(top: 0, left: 10, bottom: 0, right: 20)
        backButton.setImage(#imageLiteral(resourceName: "back"), for: .normal)
        backButton.tintColor = Settings.currentTheme.secondaryTitleColor
        addSubview(backButton)
        backButton.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: nil, padding: .init(top: 0, left: 0, bottom: 15, right: 0))
        backButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        // Init titleLabel
        titleLabel = UILabel(frame: .zero)
        titleLabel.textColor = Settings.currentTheme.bodyTextColor
        titleLabel.font = Settings.currentFontSize.titleFont
        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = .byTruncatingMiddle
        addSubview(titleLabel)
        titleLabel.anchor(top: nil, leading: nil, bottom: bottomAnchor, trailing: nil, padding: .init(top: 0, left: 0, bottom: 15, right: 0))
        titleLabel.centerXInSuperview()
        
        // Init rightButton
        monthButton = UIButton(type: .system)
        monthButton.contentEdgeInsets = .init(top: 0, left: 20, bottom: 0, right: 10)
        monthButton.setTitleColor(Settings.currentTheme.secondaryTitleColor, for: .normal)
        addSubview(monthButton)
        monthButton.anchor(top: nil, leading: nil, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 0, bottom: 15, right: 0))
        monthButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        backButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
        monthButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
    }
    
    private func initActions() {
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        monthButton.addTarget(self, action: #selector(monthButtonTapped), for: .touchUpInside)
    }
    
    func setTitle(_ title: String?) {
        titleLabel.text = title
    }

    @objc private func backButtonTapped() {
        didTapBackButton?()
    }
    
    @objc private func monthButtonTapped() {
        didTapMonthButton?()
    }
    
    func setMonthButtonTitle(_ title: String) {
        monthButton.setTitle(title, for: .normal)
    }
}
