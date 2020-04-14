//
//  UIViewController+PushAViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 07/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import UIKit
import EventKitUI
import Toaster
import FirebaseAnalytics

extension UIViewController {
    func pushBandDetailViewController(urlString: String, animated: Bool) {
        let bandDetailViewController = UIStoryboard(name: "BandDetail", bundle: nil).instantiateViewController(withIdentifier: "BandDetailViewController") as! BandDetailViewController
        bandDetailViewController.bandURLString = urlString
        navigationController?.pushViewController(bandDetailViewController, animated: animated)
    
        if let _ = self as? HistoryRecordable {
            bandDetailViewController.historyRecordableDelegate = (self as! HistoryRecordable)
        }
    }
    
    func pushReleaseDetailViewController(urlString: String, animated: Bool) {
        let releaseDetailViewController = UIStoryboard(name: "ReleaseDetail", bundle: nil).instantiateViewController(withIdentifier: "ReleaseDetailViewController") as! ReleaseDetailViewController
        releaseDetailViewController.urlString = urlString
        navigationController?.pushViewController(releaseDetailViewController, animated: animated)
        
        if let _ = self as? HistoryRecordable {
            releaseDetailViewController.historyRecordableDelegate = (self as! HistoryRecordable)
        }
    }
    
    func pushArtistDetailViewController(urlString: String, animated: Bool) {
        let artistDetailViewController = UIStoryboard(name: "Artist", bundle: nil).instantiateViewController(withIdentifier: "ArtistDetailViewController") as! ArtistDetailViewController
        artistDetailViewController.urlString = urlString
        navigationController?.pushViewController(artistDetailViewController, animated: animated)
        
        if let _ = self as? HistoryRecordable {
            artistDetailViewController.historyRecordableDelegate = (self as! HistoryRecordable)
        }
    }
    
    func pushLabelDetailViewController(urlString: String, animated: Bool) {
        let labelDetailViewController = UIStoryboard(name: "LabelDetail", bundle: nil).instantiateViewController(withIdentifier: "LabelDetailViewController") as! LabelDetailViewController
        labelDetailViewController.urlString = urlString
        navigationController?.pushViewController(labelDetailViewController, animated: animated)
        
        if let _ = self as? HistoryRecordable {
            labelDetailViewController.historyRecordableDelegate = (self as! HistoryRecordable)
        }
    }
    
    func pushUserDetailViewController(urlString: String, animated: Bool) {
        let userDetailViewController = UIStoryboard(name: "UserDetail", bundle: nil).instantiateViewController(withIdentifier: "UserDetailViewController") as! UserDetailViewController
        userDetailViewController.urlString = urlString
        navigationController?.pushViewController(userDetailViewController, animated: animated)
        
        if let _ = self as? HistoryRecordable {
            userDetailViewController.historyRecordableDelegate = (self as! HistoryRecordable)
        }
    }
    
    func takeActionFor(actionableObject: Actionable) {
        if actionableObject.actionableElements.count == 1 {
            switch actionableObject.actionableElements[0] {
            case .artist(_, let urlString):
                self.pushArtistDetailViewController(urlString: urlString, animated: true)
                return
                
            case .band(_, let urlString):
                self.pushBandDetailViewController(urlString: urlString, animated: true)
                return
                
            case .label(_, let urlString):
                self.pushLabelDetailViewController(urlString: urlString, animated: true)
                return
                
            case .release(_, let urlString):
                self.pushReleaseDetailViewController(urlString: urlString, animated: true)
                return
                
            default: break
            }
        }
        
        var alert: UIAlertController!
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        } else {
            alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        }
        
        actionableObject.actionableElements.forEach { (element) in
            var action: UIAlertAction!
            switch element {
            case .band(let name, let urlString):
                action = UIAlertAction(title: "👥 Band: \(name)", style: .default, handler: { (action) in
                    self.pushBandDetailViewController(urlString: urlString, animated: true)
                })
                
            case .artist(let name, let urlString):
                action = UIAlertAction(title: "👤 Artist: \(name)", style: .default, handler: { (action) in
                    self.pushArtistDetailViewController(urlString: urlString, animated: true)
                })
                
            case .release(let name, let urlString):
                action = UIAlertAction(title: "💿 Release: \(name)", style: .default, handler: { (action) in
                    self.pushReleaseDetailViewController(urlString: urlString, animated: true)
                })
                
            case .label(let name, let urlString):
                action = UIAlertAction(title: "🏷️ Label: \(name)", style: .default, handler: { (action) in
                    self.pushLabelDetailViewController(urlString: urlString, animated: true)
                })
                
            case .website(let name, let urlString):
                action = UIAlertAction(title: "🔗 Website: \(name)", style: .default, handler: { (action) in
                    self.presentAlertOpenURLInBrowsers(URL(string: urlString)!, alertMessage: name)
                })
                
            case .review(let name, let urlString):
                action = UIAlertAction(title: "💬 Review: \(name)", style: .default, handler: { (action) in
                    self.presentReviewController(urlString: urlString, animated: true)
                })
                
            case .event(let event):
                action = UIAlertAction(title: "📅 Create a reminder for this release", style: .default, handler: { (action) in
                    eventStore.requestAccess(to: EKEntityType.event) { [unowned self] (granted, error) in
                        DispatchQueue.main.async {
                            if let error = error {
                                Toast.displayMessageShortly(error.localizedDescription)
                            } else if granted {
                                let eventEditViewController = EKEventEditViewController()
                                eventEditViewController.event = event
                                eventEditViewController.eventStore = eventStore
                                eventEditViewController.editViewDelegate = self
                                self.present(eventEditViewController, animated: true, completion: nil)
                            } else {
                                self.alertNoCalendarAccess()
                            }
                        }
                    }
                })
                
            case .user(let name, let urlString):
                action = UIAlertAction(title: "👤 User: \(name)", style: .default, handler: { (action) in
                    self.pushUserDetailViewController(urlString: urlString, animated: true)
                })
            }
            
            alert.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - EKEventEditViewDelegate
extension UIViewController: EKEventEditViewDelegate {
    public func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        switch action {
        case .saved:
            if let _ = self as? ReleaseDetailViewController {
                Analytics.logEvent("create_reminder_from_release_page", parameters: nil)
            } else {
                Analytics.logEvent("create_reminder", parameters: nil)
            }
            Toast.displayMessageShortly("Reminder created")
            
        default: break
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Push deezer
extension UIViewController {
    func pushDeezerResultViewController(type: DeezerableType, term: String) {
        let deezerResultViewController = UIStoryboard(name: "Deezer", bundle: nil).instantiateViewController(withIdentifier: "DeezerResultViewController") as! DeezerResultViewController
        
        deezerResultViewController.deezerableType = type
        deezerResultViewController.deezerableSearchTerm = term
        
        switch type {
        case .artist: Analytics.logEvent("deezer_band", parameters: nil)
        case .album: Analytics.logEvent("deezer_release", parameters: nil)
        }
        
        navigationController?.pushViewController(deezerResultViewController, animated: true)
    }
}
