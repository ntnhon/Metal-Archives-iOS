//
//  DiscographyOptionsTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 29/05/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class DiscographyOptionsTableViewCell: BaseTableViewCell, RegisterableCell {
    @IBOutlet private(set) weak var orderingButton: UIButton!
    @IBOutlet weak var discographyTypeButton: UIButton!
    
    var tappedOrderingButton: (() -> Void)?
    var tappedDiscographyTypeButton: (() -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func initAppearance() {
        super.initAppearance()
        discographyTypeButton.setTitleColor(Settings.currentTheme.secondaryTitleColor, for: .normal)
        orderingButton.setTitleColor(Settings.currentTheme.secondaryTitleColor, for: .normal)
    }
    
    @IBAction private func orderingButtonTapped() {
        tappedOrderingButton?()
    }
    
    @IBAction private func discographyTypeButtonTapped() {
        tappedDiscographyTypeButton?()
    }
    
    func setOrderingTitle(isAscending: Bool) {
        UIView.performWithoutAnimation {
            if isAscending {
                orderingButton.setTitle("Release years ⬆", for: .normal)
            } else {
                orderingButton.setTitle("Release years ⬇", for: .normal)
            }
            layoutIfNeeded()
        }
    }
}
