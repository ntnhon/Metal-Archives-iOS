//
//  UIViewController+DisplayRestartAlert.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 09/04/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

extension UIViewController {
    func displayRestartAlert() {
        let alert = UIAlertController(title: "Restart required", message: "Restart application for changes to take effect.", preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        alert.addAction(okayAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func displayLoginRequiredAlert() {
        let alert = UIAlertController(title: "Login required", message: "You have to log in in order to perform this action.", preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        alert.addAction(okayAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func alertNoCalendarAccess() {
        let alert = UIAlertController(title: "Calendar access required", message: "You have to allow calendar access in order to create a reminder.", preferredStyle: .alert)
        
        let openSettingsAction = UIAlertAction(title: "Open settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alert.addAction(openSettingsAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
}
