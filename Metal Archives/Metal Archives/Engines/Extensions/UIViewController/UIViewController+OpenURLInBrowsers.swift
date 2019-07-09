//
//  UIViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 21/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import FirebaseAnalytics

extension UIViewController {
    func presentAlertOpenURLInBrowsers(_ url: URL, alertTitle title: String? = "Open this link in browser", alertMessage message: String, shareMessage: String? = "Share this link") {
        let scheme = url.scheme
        var chomeScheme: String?
        if scheme == "http" {
            chomeScheme = "googlechrome"
        } else if scheme == "https" {
            chomeScheme = "googlechromes"
        }
        
        var alertActions: [UIAlertAction] = []
        
        if let `chromeScheme` = chomeScheme {
            let absoluteString = url.absoluteString
            let urlStringNoScheme = String(absoluteString.subString(after: "://", before: nil, options: .caseInsensitive) ?? "")
            if let chromeURL = URL(string: chromeScheme + "://" + urlStringNoScheme) {
                if UIApplication.shared.canOpenURL(chromeURL) {
                    let openChromeAction = UIAlertAction(title: "Open in Chrome", style: .default) { (_) in
                        UIApplication.shared.open(chromeURL, options: [:], completionHandler: nil)
                        
                        self.openInChrome(url)
                    }
                    alertActions.append(openChromeAction)
                }
            }
            
        }
        
        let openSafariAction = UIAlertAction(title: "Open in Safari", style: .default) { (_) in
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            self.openInSafari(url)
        }
        alertActions.append(openSafariAction)
        
        let shareAction = UIAlertAction(title: shareMessage, style: .default) { (_) in
            let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            
            self.present(activityViewController, animated: true, completion: nil)
            self.share(url)
        }
        alertActions.append(shareAction)
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertActions.append(cancelAction)
        
        var alert: UIAlertController!
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        } else {
            alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        }
        
        alertActions.forEach({alert.addAction(_:$0)})
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func openInChrome(_ url: URL) {
        let absoluteString = url.absoluteString
        
        var itemType = ""
        
        if absoluteString.contains("news/view/id") {
            itemType = "News"
        } else if absoluteString.contains("https://www.metal-archives.com/bands/") {
            itemType = "Band"
        } else if absoluteString.contains("https://www.metal-archives.com/albums/") {
            itemType = "Release"
        } else if absoluteString.contains("https://www.metal-archives.com/artists/") {
            itemType = "Artist"
        } else if absoluteString.contains("https://www.metal-archives.com/reviews") {
            itemType = "Review"
        } else if absoluteString.contains("https://www.metal-archives.com/labels") {
            itemType = "Label"
        }
        
        Analytics.logEvent("open_url_in_browser", parameters: ["browser": "Chrome", "item_type": itemType])
    }
    
    fileprivate func openInSafari(_ url: URL) {
        let absoluteString = url.absoluteString
        
        var itemType = ""
        
        if absoluteString.contains("news/view/id") {
            itemType = "News"
        } else if absoluteString.contains("https://www.metal-archives.com/bands/") {
            itemType = "Band"
        } else if absoluteString.contains("https://www.metal-archives.com/albums/") {
            itemType = "Release"
        } else if absoluteString.contains("https://www.metal-archives.com/artists/") {
            itemType = "Artist"
        } else if absoluteString.contains("https://www.metal-archives.com/reviews") {
            itemType = "Review"
        } else if absoluteString.contains("https://www.metal-archives.com/labels") {
            itemType = "Label"
        }
        
        Analytics.logEvent("open_url_in_browser", parameters: ["browser": "Safari", "item_type": itemType])
    }
    
    fileprivate func share(_ url: URL) {
        let absoluteString = url.absoluteString
        
        var itemType = ""
        
        if absoluteString.contains("news/view/id") {
            itemType = "News"
        } else if absoluteString.contains("https://www.metal-archives.com/bands/") {
            itemType = "Band"
        } else if absoluteString.contains("https://www.metal-archives.com/albums/") {
            itemType = "Release"
        } else if absoluteString.contains("https://www.metal-archives.com/artists/") {
            itemType = "Artist"
        } else if absoluteString.contains("https://www.metal-archives.com/reviews") {
            itemType = "Review"
        } else if absoluteString.contains("https://www.metal-archives.com/labels") {
            itemType = "Label"
        }
        
        Analytics.logEvent("share_url", parameters: ["item_type": itemType])
    }
}
