//
//  LoadingTableViewCell.swift
//  Metal Archives Widget
//
//  Created by Thanh-Nhon Nguyen on 21/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class LoadingTableViewCell: UITableViewCell, RegisterableCell {
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
    }
    
    func animate() {
        self.activityIndicatorView.style = .gray
        self.activityIndicatorView.startAnimating()
    }
}
