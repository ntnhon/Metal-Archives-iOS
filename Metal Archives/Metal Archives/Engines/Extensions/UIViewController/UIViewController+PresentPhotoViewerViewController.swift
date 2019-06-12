//
//  UIViewController+PresentPhotoViewerViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 28/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func presentPhotoViewer(photoURLString: String, description: String, fromRect rect: CGRect) {
        let photoViewerViewController = UIStoryboard(name: "PhotoViewer", bundle: nil).instantiateViewController(withIdentifier: "PhotoViewerViewController" ) as! PhotoViewerViewController
        photoViewerViewController.photoURLString = photoURLString
        photoViewerViewController.photoDescription = description
        
        photoViewerViewController.present(in: self, fromRect: rect)
    }
}
