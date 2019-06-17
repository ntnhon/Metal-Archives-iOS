//
//  Top100NavigationBarView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 15/06/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class Top100NavigationBarView: BaseNavigationBarView, TransformableWithScrollView {
    private var segmentedControl: UISegmentedControl!
    private var backButton: UIButton!
    
    var didTapBackButton: (() -> Void)?
    var didChangeBandTopType: (() -> Void)?
    var didChangeAlbumTopType: (() -> Void)?
    
    var selectedBandTopType: BandTopType {
        let selectedBandTopType = BandTopType(rawValue: segmentedControl.selectedSegmentIndex) ?? .release
        return selectedBandTopType
    }
    
    var selectedAlbumTopType: AlbumTopType {
        let selectedAlbumTopType = AlbumTopType(rawValue: segmentedControl.selectedSegmentIndex) ?? .review
        return selectedAlbumTopType
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
        addSubview(segmentedControl)
        segmentedControl.anchor(top: nil, leading: backButton.trailingAnchor, bottom: bottomAnchor, trailing: nil, padding: .init(top: 0, left: 10, bottom: 15, right: 10))
        segmentedControl.setContentHuggingPriority(.defaultLow, for: .horizontal)
        segmentedControl.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    private func initActions() {
        segmentedControl.addTarget(self, action: #selector(segementedControlValueChanged), for: .valueChanged)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }
    
    @objc private func backButtonTapped() {
        didTapBackButton?()
    }
    
    @objc private func segementedControlValueChanged() {
        didChangeBandTopType?()
        didChangeAlbumTopType?()
    }
    
    func addBandTopTypeSegments() {
        segmentedControl.removeAllSegments()
        segmentedControl.insertSegment(withTitle: BandTopType.release.description, at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: BandTopType.fullLength.description, at: 1, animated: false)
        segmentedControl.insertSegment(withTitle: BandTopType.review.description, at: 2, animated: false)
        segmentedControl.selectedSegmentIndex = 0
    }
    
    func addAlbumTopTypeSegments() {
        segmentedControl.removeAllSegments()
        segmentedControl.insertSegment(withTitle: AlbumTopType.review.description, at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: AlbumTopType.mostOwned.description, at: 1, animated: false)
        segmentedControl.insertSegment(withTitle: AlbumTopType.mostWanted.description, at: 2, animated: false)
        segmentedControl.selectedSegmentIndex = 0
    }
}

