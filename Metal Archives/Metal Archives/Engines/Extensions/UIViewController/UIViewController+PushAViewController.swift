//
//  UIViewController+PushAViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 07/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func pushBandDetailViewController(urlString: String, animated: Bool) {
        let bandDetailViewController = UIStoryboard(name: "BandDetail", bundle: nil).instantiateViewController(withIdentifier: "BandDetailViewController") as! BandDetailViewController
        bandDetailViewController.bandURLString = urlString
        navigationController?.pushViewController(bandDetailViewController, animated: animated)
    }
    
    func pushReleaseDetailViewController(urlString: String, animated: Bool) {
        let releaseDetailViewController = UIStoryboard(name: "ReleaseDetail", bundle: nil).instantiateViewController(withIdentifier: "ReleaseDetailViewController") as! ReleaseDetailViewController
        releaseDetailViewController.urlString = urlString
        navigationController?.pushViewController(releaseDetailViewController, animated: animated)
    }
    
    func pushArtistDetailViewController(urlString: String, animated: Bool) {
        let artistDetailViewController = UIStoryboard(name: "Artist", bundle: nil).instantiateViewController(withIdentifier: "ArtistDetailViewController") as! ArtistDetailViewController
        artistDetailViewController.urlString = urlString
        navigationController?.pushViewController(artistDetailViewController, animated: animated)
    }
    
    func pushLabelDetailViewController(urlString: String, animated: Bool) {
        let labelDetailViewController = UIStoryboard(name: "LabelDetail", bundle: nil).instantiateViewController(withIdentifier: "LabelDetailViewController") as! LabelDetailViewController
        labelDetailViewController.urlString = urlString
        navigationController?.pushViewController(labelDetailViewController, animated: animated)
    }
    
    func pushRelatedLinkListViewController(_ relatedLinks: [RelatedLink], animated: Bool) {
        let relatedLinkListViewController = UIStoryboard(name: "RelatedLink", bundle: nil).instantiateViewController(withIdentifier: "RelatedLinkListViewController") as! RelatedLinkListViewController
        relatedLinkListViewController.relatedLinks = relatedLinks
        navigationController?.pushViewController(relatedLinkListViewController, animated: true)
    }
    
    func takeActionFor(actionableObject: Actionable) {
        var alert: UIAlertController!
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        } else {
            alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        }
        
        actionableObject.actionableElements.forEach { (element) in
            var action: UIAlertAction!
            switch element.type {
            case .band:
                action = UIAlertAction(title: "👥 Band: \(element.name)", style: .default, handler: { (action) in
                    self.pushBandDetailViewController(urlString: element.urlString, animated: true)
                })
            case .artist:
                action = UIAlertAction(title: "👤 Artist: \(element.name)", style: .default, handler: { (action) in
                    self.pushArtistDetailViewController(urlString: element.urlString, animated: true)
                })
            case .release:
                action = UIAlertAction(title: "💿 Release: \(element.name)", style: .default, handler: { (action) in
                    self.pushReleaseDetailViewController(urlString: element.urlString, animated: true)
                })
            case .label:
                action = UIAlertAction(title: "🏷️ Label: \(element.name)", style: .default, handler: { (action) in
                    self.pushLabelDetailViewController(urlString: element.urlString, animated: true)
                })
            case .website:
                action = UIAlertAction(title: "🔗 Website: \(element.name)", style: .default, handler: { (action) in
                    self.presentAlertOpenURLInBrowsers(URL(string: element.urlString)!, alertMessage: element.name)
                })
            case .review:
                action = UIAlertAction(title: "💬 Review: \(element.name)", style: .default, handler: { (action) in
                    self.presentReviewController(urlString: element.urlString, animated: true)
                })
            }
            
            alert.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
}
