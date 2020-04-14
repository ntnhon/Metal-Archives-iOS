//
//  UserDetailViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 14/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Floaty
import FirebaseAnalytics

final class UserDetailViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var simpleNavigationBarView: SimpleNavigationBarView!
    @IBOutlet private weak var floaty: Floaty!
    
    var urlString: String!
    
    private var user: User!
    
    var historyRecordableDelegate: HistoryRecordable?
    
    deinit {
        print("UserDetailViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        initFloaty()
        initSimpleNavigationBarView()
    }
    
    private func configureTableView() {
        LoadingTableViewCell.register(with: tableView)
        
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    private func initFloaty() {
        floaty.customizeAppearance()
        
        floaty.addBackToHomepageItem(navigationController) {
            Analytics.logEvent("back_to_home_from_user_detail", parameters: nil)
        }
        
        floaty.addStartNewSearchItem(navigationController) {
            Analytics.logEvent("start_new_search_from_user_detail", parameters: nil)
        }
        
        floaty.addItem("Share this user", icon: UIImage(named: Ressources.Images.share)) { [unowned self] _ in
            self.shareUser()
        }
    }
    
    private func initSimpleNavigationBarView() {
        simpleNavigationBarView.setAlphaForBackgroundAndTitleLabel(1)
        simpleNavigationBarView.didTapLeftButton = { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
        
        simpleNavigationBarView.setRightButtonIcon(UIImage(named: Ressources.Images.share))
        simpleNavigationBarView.didTapRightButton = { [unowned self] in
            self.shareUser()
        }
    }
    
    private func shareUser() {
        guard let user = self.user, let url = URL(string: user.urlString) else { return }
        
        self.presentAlertOpenURLInBrowsers(url, alertTitle: "View \(user.name) in browser", alertMessage: user.urlString, shareMessage: "Share this user URL")
        
        Analytics.logEvent("share_user", parameters: nil)
    }
}

// MARK: - UITableViewDelegate
extension UserDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension UserDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
