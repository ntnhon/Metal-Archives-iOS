//
//  UINavigationController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 06/07/2021.
//

import UIKit

// swiftlint:disable override_in_extension
extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1
    }
}
