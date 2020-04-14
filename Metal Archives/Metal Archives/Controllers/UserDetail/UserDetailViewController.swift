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
import MBProgressHUD
import Toaster

final class UserDetailViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var simpleNavigationBarView: SimpleNavigationBarView!
    @IBOutlet private weak var floaty: Floaty!
    
    var urlString: String!
    
    private var userProfile: UserProfile?
    
    var historyRecordableDelegate: HistoryRecordable?
    
    deinit {
        print("UserDetailViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        initFloaty()
        initSimpleNavigationBarView()
        fetchUserProfile()
    }
    
    private func configureTableView() {
        LoadingTableViewCell.register(with: tableView)
        UserInfoTableViewCell.register(with: tableView)
        
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
        guard let userProfile = self.userProfile, let url = URL(string: urlString) else { return }
        
        self.presentAlertOpenURLInBrowsers(url, alertTitle: "View \(userProfile.username ?? "") in browser", alertMessage: urlString, shareMessage: "Share this user URL")
        
        Analytics.logEvent("share_user", parameters: nil)
    }
    
    private func fetchUserProfile() {
        floaty.isHidden = true
        showHUD(hideNavigationBar: true)
        
        RequestHelper.UserDetail.fetchUserProfile(urlString: urlString) { [weak self] (userProfile, error) in
            guard let self = self else { return }
        
            self.hideHUD()
            
            if let error = error {
                Toast.displayMessageShortly(error.localizedDescription)
                self.dismiss(animated: true, completion: nil)
            } else if let userProfile = userProfile {
                self.floaty.isHidden = false
                self.userProfile = userProfile
                self.tableView.reloadData()
                self.simpleNavigationBarView.setTitle(userProfile.username)
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension UserDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNormalMagnitude
        }
        
        return UITableView.automaticDimension
    }
}

// MARK: - UITableViewDataSource
extension UserDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return userProfile != nil ? 1 : 0
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let userProfile = userProfile else {
                return UITableViewCell()
            }
            
            let userInfoCell = UserInfoTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            userInfoCell.bind(with: userProfile)
            return userInfoCell
        }
        
        return userReviewCell(forRowAt: indexPath)
    }
    
    private func userReviewCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
