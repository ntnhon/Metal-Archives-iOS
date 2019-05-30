//
//  DiscographyOptionsTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 29/05/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class DiscographyOptionsTableViewCell: BaseTableViewCell, RegisterableCell {
    @IBOutlet private(set) weak var orderingButton: FilledButton!
    @IBOutlet weak var discographyTypeButton: FilledButton!
    
    var tappedOrderingButton: (() -> Void)?
    var tappedDiscographyTypeButton: (() -> Void)?

    @IBAction private func orderingButtonTapped() {
        tappedOrderingButton?()
    }
    
    @IBAction private func discographyTypeButtonTapped() {
        tappedDiscographyTypeButton?()
    }
    
    func setOrderingTitle(isAscending: Bool) {
        UIView.performWithoutAnimation {
            if isAscending {
                orderingButton.setTitle(" Release years ▲ ", for: .normal)
            } else {
                orderingButton.setTitle(" Release years ▼ ", for: .normal)
            }
            layoutIfNeeded()
        }
    }
}
