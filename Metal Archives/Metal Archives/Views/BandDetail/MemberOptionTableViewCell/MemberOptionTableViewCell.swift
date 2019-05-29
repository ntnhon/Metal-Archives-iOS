//
//  MemberOptionTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 29/05/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class MemberOptionTableViewCell: BaseTableViewCell, RegisterableCell {
    @IBOutlet weak var memberTypeButton: FilledButton!
    
    var tappedMemberTypeButton: (() -> Void)?

    @IBAction private func memberTypeButtonTapped() {
        tappedMemberTypeButton?()
    }
}
