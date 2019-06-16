//
//  HomepageNavigationController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 28/05/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class HomepageNavigationController: UINavigationController, UIGestureRecognizerDelegate {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
