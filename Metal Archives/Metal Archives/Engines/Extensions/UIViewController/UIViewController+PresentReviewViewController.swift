//
//  UIViewController+PresentReviewViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 07/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func presentReviewController(urlString: String, animated: Bool, completion: (()->Void)?) {
        let reviewViewController = UIStoryboard(name: "Review", bundle: nil).instantiateViewController(withIdentifier: "ReviewViewController") as! ReviewViewController
        reviewViewController.urlString = urlString
        self.present(reviewViewController, animated: animated) {
            completion?()
        }
    }
}
