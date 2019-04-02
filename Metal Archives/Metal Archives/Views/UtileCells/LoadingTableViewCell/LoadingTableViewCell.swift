//
//  LoadingTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class LoadingTableViewCell: BaseTableViewCell, RegisterableCell {
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private weak var errorLabel: UILabel!
    
    override func initAppearance() {
        super.initAppearance()
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.color = Settings.currentTheme.bodyTextColor
        self.errorLabel.textColor = Settings.currentTheme.bodyTextColor
        self.errorLabel.font = Settings.currentFontSize.bodyTextFont
    }
    
    func displayIsLoading() {
        self.activityIndicatorView.isHidden = false
        self.activityIndicatorView.startAnimating()
        self.errorLabel.isHidden = true
    }
    
    func didsplayError(_ message: String) {
        self.activityIndicatorView.isHidden = true
        self.activityIndicatorView.stopAnimating()
        self.errorLabel.isHidden = false
        self.errorLabel.text = message
    }
}
