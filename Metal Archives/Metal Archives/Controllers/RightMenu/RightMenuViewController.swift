//
//  RightMenuViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 08/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Toaster
import MBProgressHUD
import Toaster
import FirebaseAnalytics
import SafariServices

final class RightMenuViewController: BaseViewController {
    @IBOutlet private weak var myProfileStackView: UIStackView!
    @IBOutlet private weak var fullNameLabel: UILabel!
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var levelAndPointsLabel: UILabel!
    @IBOutlet private weak var genresLabel: UILabel!
    
    @IBOutlet private weak var tableView: UITableView!
    
    @IBOutlet private weak var loginDescriptionLabel: UILabel!
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var registerButton: UIButton!
    
    private lazy var slideMenuController: SlideMenuController = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.slideMenuController!
    }()
    
    private let options: [[RightMenuOption]] = [[.collection, .wishlist, .tradeList], [.bands, .artists, .labels, .releases], [.logOut]]
    
    private var myProfile: UserProfile?

    deinit {
        print("RightMenuViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initAppearance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        properlyShowHideUIComponents()
        fetchMyProfileIfApplicable()
    }
    
    override func initAppearance() {
        super.initAppearance()
        
        fullNameLabel.textColor = Settings.currentTheme.bodyTextColor
        fullNameLabel.text = nil
        usernameLabel.textColor = Settings.currentTheme.bodyTextColor
        usernameLabel.text = nil
        levelAndPointsLabel.textColor = Settings.currentTheme.bodyTextColor
        levelAndPointsLabel.text = nil
        genresLabel.textColor = Settings.currentTheme.bodyTextColor
        genresLabel.text = nil
        
        loginDescriptionLabel.font = Settings.currentFontSize.bodyTextFont
        loginDescriptionLabel.textColor = Settings.currentTheme.bodyTextColor
        
        loginButton.tintColor = Settings.currentTheme.titleColor
        loginButton.setTitleColor(Settings.currentTheme.titleColor, for: .normal)
        
        registerButton.tintColor = Settings.currentTheme.titleColor
        registerButton.setTitleColor(Settings.currentTheme.titleColor, for: .normal)
        
        tableView.backgroundColor = .clear
        tableView.separatorColor = Settings.currentTheme.secondaryTitleColor
        tableView.rowHeight = UITableView.automaticDimension
        //Hide 1st section's header
        tableView.contentInset = UIEdgeInsets(top: -CGFloat.leastNormalMagnitude, left: 0, bottom: 0, right: 0)
        
        LeftMenuOptionTableViewCell.register(with: tableView)
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 1
    }
    
    private func properlyShowHideUIComponents() {
        loginDescriptionLabel.isHidden = LoginService.isLoggedIn
        loginButton.isHidden = LoginService.isLoggedIn
        registerButton.isHidden = LoginService.isLoggedIn
        tableView.isHidden = !LoginService.isLoggedIn
        
        myProfileStackView.isHidden = myProfile == nil || KeychainService.getUsername() == ""
    }
    
    private func fetchMyProfileIfApplicable() {
        guard myProfile == nil && KeychainService.getUsername() != "" else { return }
        
        RequestHelper.UserDetail.fetchUserProfile(username: KeychainService.getUsername()) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let myProfile):
                self.myProfile = myProfile
                self.bindMyProfile()
                self.properlyShowHideUIComponents()
                
            case .failure(let error):
                Toast.displayMessageShortly(error.localizedDescription)
            }
        }
    }
    
    private func bindMyProfile() {
        guard let myProfile = myProfile else { return }
    
        fullNameLabel.text = myProfile.fullName
        usernameLabel.text = "@\(myProfile.username!)"
        levelAndPointsLabel.text = "\(myProfile.rank!) • \(myProfile.points!) point(s)"
        genresLabel.text = myProfile.favoriteGenres
    }
    
    @IBAction private func loginButtonTapped() {
        let alert = UIAlertController(title: "Log in", message: "Enter your username and password", preferredStyle: .alert)
        
        alert.addTextField { (usernameTextField) in
            usernameTextField.placeholder = "Username"
            usernameTextField.autocorrectionType = .no
            usernameTextField.clearButtonMode = .whileEditing
            usernameTextField.returnKeyType = .next
        }
        
        alert.addTextField { (passwordTextField) in
            passwordTextField.placeholder = "Password"
            passwordTextField.autocorrectionType = .no
            passwordTextField.clearButtonMode = .whileEditing
            passwordTextField.isSecureTextEntry = true
            passwordTextField.returnKeyType = .done
        }
        
        let loginAction = UIAlertAction(title: "Log me in", style: .default) { [unowned self] _ in
            guard let username = alert.textFields?[0].text,
                let password = alert.textFields?[1].text else { return }
            
            MBProgressHUD.showAdded(to: self.slideMenuController.view, animated: true)
            LoginService.login(username: username, password: password) { [weak self] loginError in
                guard let self = self else { return }
                MBProgressHUD.hide(for: self.slideMenuController.view, animated: true)
                
                if let loginError = loginError {
                    Toast.displayMessageShortly(loginError.localizedDescription)
                    Analytics.logEvent("log_in_error", parameters: nil)
                } else {
                    KeychainService.save(username: username, password: password)
                    self.tableView.reloadData()
                    self.fetchMyProfileIfApplicable()
                    self.properlyShowHideUIComponents()
                    Analytics.logEvent("log_in_success", parameters: nil)
                }
            }
        }
        alert.addAction(loginAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction private func registerButtonTapped() {
        guard let url = URL(string: "https://www.metal-archives.com/user/signup") else { return }
        let safariController = SFSafariViewController(url: url)
        safariController.dismissButtonStyle = .close
        present(safariController, animated: true, completion: nil)
        Analytics.logEvent("open_register", parameters: nil)
    }
    
    private func pushMyBookmarksViewController(_ myBookmark: MyBookmark) {
        let myBookmarksViewController = UIStoryboard(name: "MyProfile", bundle: Bundle.main).instantiateViewController(withIdentifier: "MyBookmarksViewController") as! MyBookmarksViewController
        myBookmarksViewController.myBookmark = myBookmark
        (slideMenuController.mainViewController as? UINavigationController)?.pushViewController(myBookmarksViewController, animated: true)
    }
    
    private func pushMyCollectionViewController(_ myCollection: MyCollection) {
        let myCollectionViewController = UIStoryboard(name: "MyProfile", bundle: Bundle.main).instantiateViewController(withIdentifier: "MyCollectionViewController") as! MyCollectionViewController
        myCollectionViewController.myProfile = myProfile
        myCollectionViewController.myCollection = myCollection
        (slideMenuController.mainViewController as? UINavigationController)?.pushViewController(myCollectionViewController, animated: true)
    }
}

// MARK: - UITableViewDelegate
extension RightMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        closeRight()
        let option = options[indexPath.section][indexPath.row]
        switch option {
        case .collection:
            pushMyCollectionViewController(.collection)
            Analytics.logEvent("open_album_collection", parameters: nil)
            
        case .wishlist:
            pushMyCollectionViewController(.wanted)
            Analytics.logEvent("open_wanted_list", parameters: nil)
            
        case .tradeList:
            pushMyCollectionViewController(.trade)
            Analytics.logEvent("open_trade_list", parameters: nil)
            
        case .bands:
            pushMyBookmarksViewController(.bands)
            Analytics.logEvent("open_band_bookmarks", parameters: nil)
            
        case .artists:
            pushMyBookmarksViewController(.artists)
            Analytics.logEvent("open_artist_bookmarks", parameters: nil)
            
        case .labels:
            pushMyBookmarksViewController(.labels)
            Analytics.logEvent("open_label_bookmarks", parameters: nil)
            
        case .releases:
            pushMyBookmarksViewController(.releases)
            Analytics.logEvent("open_release_bookmarks", parameters: nil)
            
        case .logOut:
            let alert = UIAlertController(title: "You will be logged out", message: "Please confirm.", preferredStyle: .alert)
            
            let yesAction = UIAlertAction(title: "Yes, log me out", style: .default) { _ in
                KeychainService.removeUserCredential()
                LoginService.logOut()
                self.myProfile = nil
                self.myProfileStackView.isHidden = true
                Toast.displayMessageShortly("You are logged out")
                Analytics.logEvent("log_out", parameters: nil)
            }
            alert.addAction(yesAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "My collection"
        case 1: return "My bookmarks"
        default: return nil
        }
    }
}

// MARK: - UITableViewDataSource
extension RightMenuViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = LeftMenuOptionTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let option = options[indexPath.section][indexPath.row]
        cell.bind(with: option)
        return cell
    }
}
