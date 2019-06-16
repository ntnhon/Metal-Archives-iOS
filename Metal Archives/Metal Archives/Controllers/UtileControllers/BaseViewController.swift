//
//  BaseViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 20/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Toaster

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initAppearance()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ToastCenter.default.cancelAll()
    }
    
    func initAppearance() {
        self.view.backgroundColor = Settings.currentTheme.backgroundColor
        self.view.tintColor = Settings.currentTheme.iconTintColor
    }
    
    func hideStatusBar() {
        DispatchQueue.main.async(execute: {
            if let window = UIApplication.shared.keyWindow {
                window.windowLevel = UIWindow.Level.statusBar + 1
            }
        })
    }
    
    func showStatusBar() {
        DispatchQueue.main.async(execute: {
            if let window = UIApplication.shared.keyWindow {
                window.windowLevel = UIWindow.Level.normal
            }
        })
    }
}
