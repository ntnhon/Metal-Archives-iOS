//
//  LineupOptionTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 01/06/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class LineupOptionTableViewCell: BaseTableViewCell, RegisterableCell {
    @IBOutlet weak var lineupOptionButton: FilledButton!
    
    var tappedLineupOptionButton: (() -> Void)?
    
    @IBAction private func lineupOptionButtonTapped() {
        tappedLineupOptionButton?()
    }
}
