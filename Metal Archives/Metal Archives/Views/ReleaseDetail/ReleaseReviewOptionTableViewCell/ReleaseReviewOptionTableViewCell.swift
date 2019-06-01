//
//  ReleaseReviewOptionTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 01/06/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class ReleaseReviewOptionTableViewCell: BaseTableViewCell, RegisterableCell {
    @IBOutlet private weak var orderingButton: FilledButton!
    
    var tappedOrderingButton: (() -> Void)?
    
    @IBAction private func orderingButtonTapped() {
        tappedOrderingButton?()
    }
    
    func setOrderingTitle(isAscending: Bool) {
        UIView.performWithoutAnimation {
            if isAscending {
                orderingButton.setTitle(" Date ▲ ", for: .normal)
            } else {
                orderingButton.setTitle(" Date ▼ ", for: .normal)
            }
            layoutIfNeeded()
        }
    }
}
