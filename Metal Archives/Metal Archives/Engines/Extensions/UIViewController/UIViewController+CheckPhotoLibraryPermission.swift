//
//  UIViewController+CheckPhotoLibraryPermission.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 29/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import UIKit
import Photos

extension UIViewController {
    func canAccessToPhotoLibrary() -> Bool? {
        switch PHPhotoLibrary.authorizationStatus() {
        case .denied:
            let alert = UIAlertController(title: "Permission needed", message: "Hey, I can't save this photo, it looks like you denied access to your photo library. Please enable it in Settings.", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Got it!", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            return false
        case .restricted: return false
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (status) in
                
            }
            return nil
        case .authorized: return true
        }
    }
}
