//
//  UINavigationController+Theme.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 24/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

extension UINavigationController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        switch Settings.currentTheme {
        case .unicorn, .vintage:
            self.navigationBar.barTintColor = Settings.currentTheme.secondaryTitleColor
            self.navigationBar.barStyle = .black
            self.navigationBar.tintColor = .white
            self.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        default:
            self.navigationBar.tintColor = .black
            self.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
            break
        }
    }
}
