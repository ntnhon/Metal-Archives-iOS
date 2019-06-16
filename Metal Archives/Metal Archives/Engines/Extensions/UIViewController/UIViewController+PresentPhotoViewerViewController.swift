//
//  UIViewController+PresentPhotoViewerViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 28/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

extension UIViewController {
    func presentPhotoViewer(photoUrlString: String, description: String, fromImageView imageView: UIImageView) {
        let photoViewerViewController = UIStoryboard(name: "PhotoViewer", bundle: nil).instantiateViewController(withIdentifier: "PhotoViewerViewController" ) as! PhotoViewerViewController
        photoViewerViewController.photoURLString = photoUrlString
        photoViewerViewController.photoDescription = description
        
        photoViewerViewController.present(in: self, fromImageView: imageView)
    }
    
    func presentPhotoViewerWithCacheChecking(photoUrlString: String?, description: String, fromImageView imageView: UIImageView) {
        guard let photoUrlString = photoUrlString else {
            return
        }
        
        SDWebImageManager.shared().cachedImageExists(for: URL(string: photoUrlString)) { [weak self] (isInCache) in
            if isInCache {
                self?.presentPhotoViewer(photoUrlString: photoUrlString, description: description, fromImageView: imageView)
            }
        }
    }
}
