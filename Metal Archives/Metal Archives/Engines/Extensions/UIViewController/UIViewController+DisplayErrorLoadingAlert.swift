//
//  UIViewController+DisplayErrorMessage.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 09/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import UIKit
import Toaster
extension UIViewController {
    func displayErrorLoadingAlert() {
        let title = "Oops!!! 😵"
        let message = "Looks like something went wrong. Please help me fix this by emailing me how to reproduce this problem and give me as much clues as possible. Thank you :)"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay, take me to email!", style: .default) { (action) in
            
        }
        
        let cancelAction = UIAlertAction(title: "Maybe later", style: .default, handler: nil)
        alert.addAction(okayAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
}
