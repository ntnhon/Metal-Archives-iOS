//
//  SearchModeNavigationBarView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 15/06/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

enum SearchMode: Int, CustomStringConvertible {
    case simple = 0, advanced
    
    var description: String {
        switch self {
        case .simple: return "Simple"
        case .advanced: return "Advanced"
        }
    }
}

final class SearchModeNavigationBarView: BaseNavigationBarView {
    private var segmentedControl: UISegmentedControl!
    private var backButton: UIButton!
    private var tipsButton: UIButton!
    
    var didTapBackButton: (() -> Void)?
    var didTapTipsButton: (() -> Void)?
    var didChangeSearchMode: (() -> Void)?
    
    var selectedMode: SearchMode {
        return SearchMode(rawValue: segmentedControl.selectedSegmentIndex) ?? .simple
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
        
        // Init leftButton
        backButton = UIButton(type: .system)
        backButton.contentEdgeInsets = .init(top: 0, left: 10, bottom: 0, right: 20)
        backButton.setImage(#imageLiteral(resourceName: "back"), for: .normal)
        backButton.tintColor = Settings.currentTheme.secondaryTitleColor
        addSubview(backButton)
        backButton.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: nil, padding: .init(top: 0, left: 0, bottom: 15, right: 0))
        backButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        // Init segmentedControl
        segmentedControl = UISegmentedControl(frame: .zero)
        segmentedControl.tintColor = Settings.currentTheme.secondaryTitleColor
        segmentedControl.insertSegment(withTitle: SearchMode.simple.description, at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: SearchMode.advanced.description, at: 1, animated: false)
        segmentedControl.selectedSegmentIndex = 0
        addSubview(segmentedControl)
        segmentedControl.anchor(top: nil, leading: backButton.trailingAnchor, bottom: bottomAnchor, trailing: nil, padding: .init(top: 0, left: 10, bottom: 15, right: 10))
        segmentedControl.setContentHuggingPriority(.defaultLow, for: .horizontal)
        segmentedControl.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        // Init rightButton
        tipsButton = UIButton(type: .system)
        tipsButton.contentEdgeInsets = .init(top: 0, left: 20, bottom: 0, right: 10)
        tipsButton.setTitle("💡 Tips", for: .normal)
        tipsButton.tintColor = Settings.currentTheme.secondaryTitleColor
        addSubview(tipsButton)
        tipsButton.anchor(top: nil, leading: segmentedControl.trailingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 0, bottom: 15, right: 0))
        tipsButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        backButton.centerYAnchor.constraint(equalTo: segmentedControl.centerYAnchor).isActive = true
        tipsButton.centerYAnchor.constraint(equalTo: segmentedControl.centerYAnchor).isActive = true
    }
    
    private func initActions() {
        segmentedControl.addTarget(self, action: #selector(segementedControlValueChanged), for: .valueChanged)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        tipsButton.addTarget(self, action: #selector(tipsButtonTapped), for: .touchUpInside)
    }

    @objc private func backButtonTapped() {
        didTapBackButton?()
    }
    
    @objc private func tipsButtonTapped() {
        didTapTipsButton?()
    }
    
    @objc private func segementedControlValueChanged() {
        didChangeSearchMode?()
    }
}

