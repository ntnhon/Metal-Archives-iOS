//
//  LatestAdditionsOrUpdatesNavigationBarView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 29/06/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class LatestAdditionsOrUpdatesNavigationBarView: BaseNavigationBarView, TransformableWithScrollView {
    private var segmentedControl: UISegmentedControl!
    private var messageLabel: UILabel!
    private var backButton: UIButton!
    private(set) var monthButton: UIButton!
    
    var didTapBackButton: (() -> Void)?
    var didTapMonthButton: (() -> Void)?
    var didChangeAdditionOrUpdateType: (() -> Void)?
    
    var selectedAdditionOrUpdateType: AdditionOrUpdateType {
        return AdditionOrUpdateType(rawValue: segmentedControl.selectedSegmentIndex) ?? .bands
    }
    
    override func adjustHeightBaseOnDevice() {
        constrainHeight(constant: UIApplication.shared.keyWindow!.safeAreaInsets.top + segmentedNavigationBarViewHeightWithoutTopInset)
    }
    
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
        
        // Init centeredStackView
        let centeredStackView = UIStackView()
        centeredStackView.distribution = .fill
        centeredStackView.alignment = .center
        centeredStackView.axis = .vertical
        centeredStackView.spacing = 5
        
        segmentedControl = UISegmentedControl(frame: .zero)
        segmentedControl.tintColor = Settings.currentTheme.secondaryTitleColor
        for i in 0..<AdditionOrUpdateType.allCases.count {
            let additionOrUpdateType = AdditionOrUpdateType.allCases[i]
            segmentedControl.insertSegment(withTitle: additionOrUpdateType.description, at: i, animated: false)
        }
        centeredStackView.addArrangedSubview(segmentedControl)
        
        messageLabel = UILabel(frame: .zero)
        messageLabel.font = Settings.currentFontSize.bodyTextFont
        messageLabel.textColor = Settings.currentTheme.bodyTextColor
        centeredStackView.addArrangedSubview(messageLabel)

        addSubview(centeredStackView)
        centeredStackView.centerXInSuperview()
        centeredStackView.anchor(top: nil, leading: nil, bottom: bottomAnchor, trailing: nil, padding: .init(top: 0, left: 0, bottom: 10, right: 0))
        
        // Init monthButton
        monthButton = UIButton(type: .system)
        monthButton.contentEdgeInsets = .init(top: 0, left: 20, bottom: 0, right: 10)
        monthButton.setTitleColor(Settings.currentTheme.secondaryTitleColor, for: .normal)
        addSubview(monthButton)
        monthButton.anchor(top: nil, leading: nil, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 0, bottom: 15, right: 0))
        monthButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        backButton.centerYAnchor.constraint(equalTo: centeredStackView.centerYAnchor).isActive = true
        monthButton.centerYAnchor.constraint(equalTo: centeredStackView.centerYAnchor).isActive = true
    }
    
    private func initActions() {
        segmentedControl.addTarget(self, action: #selector(segementedControlValueChanged), for: .valueChanged)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        monthButton.addTarget(self, action: #selector(monthButtonTapped), for: .touchUpInside)
    }
    
    @objc private func segementedControlValueChanged() {
        didChangeAdditionOrUpdateType?()
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
    
    func setMessage(_ message: String) {
        messageLabel.text = message
    }
    
    func setAdditionOrUpdateType(_ additionOrUpdateType: AdditionOrUpdateType) {
        segmentedControl.selectedSegmentIndex = additionOrUpdateType.rawValue
    }
}
