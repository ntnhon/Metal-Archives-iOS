//
//  UIViewController+AddToggleMenuButton.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 12/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import SlideMenuControllerSwift

extension UIViewController {
    func addToggleMenuButton() {
        self.addLeftBarButtonWithImage(UIImage(named: Ressources.Images.menuIcon)!)
        self.slideMenuController()?.removeLeftGestures()
        self.slideMenuController()?.addLeftGestures()
    }
}
