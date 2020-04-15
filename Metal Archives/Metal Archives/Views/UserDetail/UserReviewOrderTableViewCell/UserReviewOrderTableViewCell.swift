//
//  UserReviewOrderTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 15/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

typealias SubmittedBandOrderTableViewCell = UserReviewOrderTableViewCell

final class UserReviewOrderTableViewCell: BaseTableViewCell, RegisterableCell {
    @IBOutlet weak var orderButton: FilledButton!
    
    var tappedOrderButton: (() -> Void)?

    @IBAction private func orderButtonTapped() {
        tappedOrderButton?()
    }
    
    func setOrderButtonTitle(_ order: UserReviewOrder) {
        orderButton.setTitle(" \(order.description) ", for: .normal)
    }
    
    func setOrderButtonTitle(_ order: SubmittedBandOrder) {
        orderButton.setTitle(" \(order.description) ", for: .normal)
    }
}
