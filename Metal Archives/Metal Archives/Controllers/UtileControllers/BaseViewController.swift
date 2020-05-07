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
    
    deinit {
        print("\(Self.self) is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initAppearance()
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
    func showHUD(hideNavigationBar: Bool = false) {
        if let hud = hud, hud.alpha > 0.0 {
            return
        }
        
        hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud!.mode = .indeterminate
        hud!.button.setTitle("Cancel", for: .normal)
        hud!.button.addTarget(self, action: #selector(cancelFromHUD), for: .touchUpInside)
        
        view.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        
        if hideNavigationBar {
            showCustomNavigationBarView(false)
        }
        
        harmoniseSmokedImageViewToBackgroundColor(false)
    }
    
    @objc func cancelFromHUD() {
        hideHUD()
        navigationController?.popViewController(animated: true)
    }

    func hideHUD() {
        hud?.hide(animated: true)
        showCustomNavigationBarView(true)
        view.backgroundColor = Settings.currentTheme.backgroundColor
        harmoniseSmokedImageViewToBackgroundColor(true)
    }
    
    private func showCustomNavigationBarView(_ show: Bool) {
        for view in view.subviews {
            if let baseNavigationBarView = view as? BaseNavigationBarView {
                baseNavigationBarView.isHidden = !show
                return
            }
        }
    }
    
    private func harmoniseSmokedImageViewToBackgroundColor(_ harmonized: Bool) {
        for view in view.subviews {
            if let smokedImageView = view as? SmokedImageView {
                if harmonized {
                    smokedImageView.setBackgroundColor(Settings.currentTheme.backgroundColor)
                } else { smokedImageView.setBackgroundColor(Settings.currentTheme.tableViewBackgroundColor)
                }
                return
            }
        }
    }
}
