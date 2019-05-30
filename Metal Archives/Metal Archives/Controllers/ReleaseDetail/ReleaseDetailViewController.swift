//
//  ReleaseDetailViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 05/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Toaster
import FirebaseAnalytics
import Crashlytics

//MARK: - Properties
final class ReleaseDetailViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!
    var urlString: String!
    
    private var release: Release!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.reloadRelease()
    }
    
    override func initAppearance() {
        super.initAppearance()
    }
    
    private func reloadRelease() {
        MetalArchivesAPI.reloadRelease(urlString: urlString) { [weak self] (release, error) in
            if let `error` = error as NSError? {
                if error.code == -999 {
                    self?.reloadRelease()
                } else {
                    self?.displayErrorLoadingAlert()
                }
            }
            else if let `release` = release {
                self?.release = release
                self?.title = release.title
                self?.tableView.reloadData()
                
                Analytics.logEvent(AnalyticsEvent.ViewRelease, parameters: [AnalyticsParameter.ReleaseTitle: release.title!, AnalyticsParameter.ReleaseID: release.id!])
                
                Crashlytics.sharedInstance().setObjectValue(release, forKey: CrashlyticsKey.Release)
            }
        }
    }
}

//MARK: - UIPopoverPresentationControllerDelegate
extension ReleaseDetailViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

// MARK: - UITableViewDelegate
extension ReleaseDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ReleaseDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
