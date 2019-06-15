//
//  SimpleNavigationBarView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/05/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class SimpleNavigationBarView: UIView {
    private var backgroundView: UIView!
    private var titleLabel: UILabel!
    private var leftButton: UIButton!
    private var rightButton: UIButton!
    
    var didTapLeftButton: (() -> Void)?
    var didTapRightButton: (() -> Void)?
    
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
        
        // Init leftButton
        leftButton = UIButton(type: .system)
        leftButton.contentEdgeInsets = .init(top: 0, left: 10, bottom: 0, right: 20)
        leftButton.setImage(#imageLiteral(resourceName: "back"), for: .normal)
        leftButton.tintColor = Settings.currentTheme.secondaryTitleColor
        addSubview(leftButton)
        leftButton.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: nil, padding: .init(top: 0, left: 0, bottom: 15, right: 0))
        leftButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        // Init titleLabel
        titleLabel = UILabel(frame: .zero)
        titleLabel.textColor = Settings.currentTheme.bodyTextColor
        titleLabel.font = Settings.currentFontSize.titleFont
        titleLabel.textAlignment = .center
        titleLabel.alpha = 0
        addSubview(titleLabel)
        titleLabel.anchor(top: nil, leading: leftButton.trailingAnchor, bottom: bottomAnchor, trailing: nil, padding: .init(top: 0, left: 10, bottom: 15, right: 10))
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        
        // Init rightButton
        rightButton = UIButton(type: .system)
        rightButton.contentEdgeInsets = .init(top: 0, left: 20, bottom: 0, right: 10)
        rightButton.setImage(#imageLiteral(resourceName: "share"), for: .normal)
        rightButton.tintColor = Settings.currentTheme.secondaryTitleColor
        addSubview(rightButton)
        rightButton.anchor(top: nil, leading: titleLabel.trailingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 0, bottom: 15, right: 0))
        rightButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    private func initActions() {
        leftButton.addTarget(self, action: #selector(leftButtonTapped), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(rightButtonTapped), for: .touchUpInside)
    }
    
    func setAlphaForBackgroundAndTitleLabel(_ alpha: CGFloat) {
        backgroundView.alpha = alpha
        titleLabel.alpha = alpha
    }
    
    func setTitle(_ title: String?) {
        titleLabel.text = title
    }
    
    func setLeftButtonIcon(_ image: UIImage?) {
        leftButton.setImage(image, for: .normal)
    }
    
    func setRightButtonIcon(_ image: UIImage?) {
        rightButton.setImage(image, for: .normal)
    }
    
    func transformWith(_ scrollView: UIScrollView) {
        let transform: CGAffineTransform
        if scrollView.panGestureRecognizer.translation(in: scrollView.superview).y < 0 && scrollView.contentOffset.y > 0 {
            // scrolled up
            transform = CGAffineTransform(translationX: 0, y: -bounds.height)
        } else {
            // scrolled down
            transform = .identity
        }
        
        guard self.transform != transform else { return }
        
        UIView.animate(withDuration: 0.35) { [unowned self] in
            self.transform = transform
        }
    }
    
    @objc private func leftButtonTapped() {
        didTapLeftButton?()
    }
    
    @objc private func rightButtonTapped() {
        didTapRightButton?()
    }
}
