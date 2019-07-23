//
//  BaseViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 20/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Toaster
import MBProgressHUD

class BaseViewController: UIViewController {
    
    private var hud: MBProgressHUD?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initAppearance()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ToastCenter.default.cancelAll()
    }
    
    func initAppearance() {
        view.backgroundColor = Settings.currentTheme.backgroundColor
        view.tintColor = Settings.currentTheme.iconTintColor
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

// MARK: - MBProgressHUD
extension BaseViewController {
    func showHUD(hideNavigationBar: Bool = true) {
        if let hud = hud, hud.alpha > 0.0 {
            return
        }
        
        hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud!.mode = .indeterminate
        hud!.button.setTitle("Cancel", for: .normal)
        hud!.button.addTarget(self, action: #selector(cancelFromHUD), for: .touchUpInside)
        
        if hideNavigationBar {
            showCustomNavigationBarView(false)
        }
    }
    
    @objc func cancelFromHUD() {
        hideHUD()
        navigationController?.popViewController(animated: true)
    }

    func hideHUD() {
        hud?.hide(animated: true)
        showCustomNavigationBarView(true)
    }
    
    private func showCustomNavigationBarView(_ show: Bool) {
        for view in view.subviews {
            if let baseNavigationBarView = view as? BaseNavigationBarView {
                baseNavigationBarView.isHidden = !show
                return
            }
        }
    }
}
