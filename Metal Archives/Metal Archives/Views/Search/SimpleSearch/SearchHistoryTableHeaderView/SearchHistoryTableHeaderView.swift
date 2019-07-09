//
//  SearchHistoryTableHeaderView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 09/07/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class SearchHistoryTableHeaderView: UITableViewHeaderFooterView {
    private var clearAllLabel: UILabel!
    var didTapClearAll: (() -> Void)?
    
    var isClearAllLabelHidden: Bool {
        get {
            return clearAllLabel.isHidden
        }
        set {
            clearAllLabel.isHidden = newValue
        }
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        initAppearance()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initAppearance()
    }
    
    private func initAppearance() {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        addSubview(stackView)
        stackView.fillSuperview(padding: .init(top: 0, left: 10, bottom: 0, right: 10))
        
        let titleLabel = UILabel(frame: .zero)
        titleLabel.font = Settings.currentFontSize.bodyTextFont
        titleLabel.textColor = Settings.currentTheme.secondaryTitleColor
        titleLabel.textAlignment = .left
        titleLabel.text = "SEARCH HISTORY"
        stackView.addArrangedSubview(titleLabel)
        
        clearAllLabel = UILabel(frame: .zero)
        clearAllLabel.font = Settings.currentFontSize.bodyTextFont
        clearAllLabel.textColor = Settings.currentTheme.titleColor
        clearAllLabel.textAlignment = .right
        clearAllLabel.text = "Clear All"
        stackView.addArrangedSubview(clearAllLabel)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedClearAllLabel))
        tap.numberOfTapsRequired = 1
        clearAllLabel.isUserInteractionEnabled = true
        clearAllLabel.addGestureRecognizer(tap)
    }
    
    @objc private func tappedClearAllLabel() {
        didTapClearAll?()
    }
}
