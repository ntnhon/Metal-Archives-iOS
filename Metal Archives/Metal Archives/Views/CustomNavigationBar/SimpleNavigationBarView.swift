//
//  SimpleNavigationBarView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/05/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

enum LeftButtonMode {
    case back, close
}

final class SimpleNavigationBarView: BaseNavigationBarView, TransformableWithScrollView {
    private var backgroundView: UIView!
    private var titleLabel: UILabel!
    private var leftButton: UIButton!
    private(set) var rightButton: UIButton!
    private var leftButtonMode: LeftButtonMode = .back
    
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
        leftButton.contentEdgeInsets = .init(top: 0, left: 10, bottom: 0, right: 10)
        leftButton.setImage(#imageLiteral(resourceName: "back"), for: .normal)
        leftButton.tintColor = Settings.currentTheme.secondaryTitleColor
        addSubview(leftButton)
        leftButton.anchor(top: nil, leading: leadingAnchor, bottom: nil, trailing: nil)
        leftButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        // Init titleLabel
        titleLabel = UILabel(frame: .zero)
        titleLabel.textColor = Settings.currentTheme.bodyTextColor
        titleLabel.font = Settings.currentFontSize.titleFont
        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = .byTruncatingMiddle
        titleLabel.numberOfLines = 2
        titleLabel.alpha = 0
        addSubview(titleLabel)
        
        titleLabel.anchor(top: nil, leading: leftButton.trailingAnchor, bottom: nil, trailing: nil)
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        // Init rightButton
        rightButton = UIButton(type: .system)
        rightButton.contentEdgeInsets = .init(top: 0, left: 10, bottom: 0, right: 10)
        rightButton.setImage(#imageLiteral(resourceName: "share"), for: .normal)
        rightButton.tintColor = Settings.currentTheme.secondaryTitleColor
        addSubview(rightButton)
        rightButton.anchor(top: nil, leading: titleLabel.trailingAnchor, bottom: nil, trailing: trailingAnchor)
        rightButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        // Center vertically buttons & title
        let yBias = UIApplication.shared.keyWindow!.safeAreaInsets.top / 2
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: yBias).isActive = true
        leftButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
        rightButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
    }
    
    private func initActions() {
        leftButton.addTarget(self, action: #selector(leftButtonTapped), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(rightButtonTapped), for: .touchUpInside)
    }
    
    func setLeftButtonMode(_ mode: LeftButtonMode) {
        leftButtonMode = mode
        
        switch leftButtonMode {
        case .back: leftButton.setImage(UIImage(named: Ressources.Images.back), for: .normal)
        case .close: leftButton.setImage(UIImage(named: Ressources.Images.close_filled), for: .normal)
        }
    }
    
    func setAlphaForBackgroundAndTitleLabel(_ alpha: CGFloat) {
        backgroundView.alpha = alpha
        titleLabel.alpha = alpha
        
        let normalImageName: String
        let filledImageName: String
        switch leftButtonMode {
        case .back:
            normalImageName = Ressources.Images.back
            filledImageName = Ressources.Images.back_filled
        case .close:
            normalImageName = Ressources.Images.close
            filledImageName = Ressources.Images.close_filled
        }
        
        if alpha <= 0 {
            leftButton.setImage(UIImage(named: filledImageName), for: .normal)
        } else {
            leftButton.setImage(UIImage(named: normalImageName), for: .normal)
        }
    }
    
    func setTitle(_ title: String?) {
        titleLabel.text = title
    }
    
    func setImageAsTitle(_ image: UIImage?, fallbackTitle: String, alwaysShowTitle: Bool, roundedCorner: Bool = false) {
        guard let image = image else {
            setTitle(fallbackTitle)
            return
        }

        let imageHeight = 2.5 * FontSize.default.titleFont.pointSize
        let imageWidth = imageHeight * image.size.width / image.size.height
        
        let resizedImage = image.resize(targetSize: .init(width: imageWidth, height: imageHeight), rounded: roundedCorner)
        
        let attributedString = NSMutableAttributedString(string: "")
        let imageAttachment = NSTextAttachment()
        imageAttachment.bounds = CGRect(x: 0, y: CGFloat(roundf(Float(FontSize.default.titleFont.capHeight - resizedImage.size.height).rounded() / 2)), width: resizedImage.size.width, height: resizedImage.size.height)
        imageAttachment.image = resizedImage
        let imageString = NSAttributedString(attachment: imageAttachment)
        attributedString.append(imageString)
        
        if alwaysShowTitle {
            let titleAttributedString = NSAttributedString(string: "  \(fallbackTitle)", attributes: [.font : FontSize.default.titleFont])
            attributedString.append(titleAttributedString)
            titleLabel.textAlignment = .left
        } else {
            titleLabel.textAlignment = .center
        }

        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.attributedText = attributedString
    }
    
    func setTitleFont(_ font: UIFont) {
        titleLabel.font = font
    }
    
    func setLeftButtonIcon(_ image: UIImage?) {
        if let image = image {
            leftButton.alpha = 1
            leftButton.setImage(image, for: .normal)
        } else {
            leftButton.alpha = 0
        }
    }
    
    func setRightButtonIcon(_ image: UIImage?) {
        if let image = image {
            rightButton.alpha = 1
            rightButton.setImage(image, for: .normal)
        } else {
            rightButton.alpha = 0
        }
    }

    @objc private func leftButtonTapped() {
        didTapLeftButton?()
    }
    
    @objc private func rightButtonTapped() {
        didTapRightButton?()
    }
}
