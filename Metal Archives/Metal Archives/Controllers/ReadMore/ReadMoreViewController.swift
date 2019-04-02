//
//  ReadMoreViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 29/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class ReadMoreViewController: BaseViewController {
    @IBOutlet private weak var navTitle: UINavigationItem!
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var closeButton: UIButton!
    
    var readMoreString: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = readMoreString
        self.navTitle.title = self.title
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.textView.contentOffset = .zero
    }
    
    override func initAppearance() {
        super.initAppearance()
        self.closeButton.setTitleColor(Settings.currentTheme.titleColor, for: .normal)
        self.closeButton.titleLabel?.font = Settings.currentFontSize.titleFont
        
        self.textView.backgroundColor = Settings.currentTheme.backgroundColor
        self.textView.textColor = Settings.currentTheme.bodyTextColor
        self.textView.font = Settings.currentFontSize.bodyTextFont
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction private func tapCloseButton() {
        self.dismiss(animated: true, completion: nil)
    }
}
