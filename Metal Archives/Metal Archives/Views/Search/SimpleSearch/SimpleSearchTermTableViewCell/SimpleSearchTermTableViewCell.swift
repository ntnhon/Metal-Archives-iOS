//
//  SimpleSearchTermTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 08/07/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class SimpleSearchTermTableViewCell: BaseTableViewCell, RegisterableCell {
    @IBOutlet weak var searchTermTextField: BaseTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
}
