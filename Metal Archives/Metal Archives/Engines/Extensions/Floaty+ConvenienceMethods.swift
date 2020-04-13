//
//  Floaty+ConvenienceMethods.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 12/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import Floaty

extension Floaty {
    func customizeAppearance() {
        buttonColor = Settings.currentTheme.iconTintColor
        itemButtonColor = Settings.currentTheme.iconTintColor
        plusColor = Settings.currentTheme.backgroundColor
        overlayColor = UIColor.black.withAlphaComponent(0.7)
    }
    
    func addBackToHomepageItem(_ navigationController: UINavigationController?, completion: (() -> Void)?) {
        addItem("Back to homepage", icon: UIImage(named: Ressources.Images.homeIcon)) { _ in
            navigationController?.popToRootViewController(animated: true)
            completion?()
        }
    }
    
    func addStartNewSearchItem(_ navigationController: UINavigationController?, completion: (() -> Void)?) {
        addItem("Start new search", icon: UIImage(named: Ressources.Images.horns_search)) { _ in
            guard let searchViewController = UIStoryboard(name: "Search", bundle: nil).instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController else {
            return
            }
            
            // Remove SearchViewController if there is one in the navigation stack
            navigationController?.viewControllers.forEach({ (eachViewController) in
                if eachViewController.isKind(of: SearchViewController.self) {
                    eachViewController.removeFromParent()
                }
            })
            
            navigationController?.pushViewController(searchViewController, animated: true)
            completion?()
        }
    }
}
