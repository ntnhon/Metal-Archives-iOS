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
import SlideMenuControllerSwift
import Toaster

final class RightMenuViewController: BaseViewController {
    @IBOutlet private weak var myProfileStackView: UIStackView!
    @IBOutlet private weak var fullNameLabel: UILabel!
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var levelAndPointsLabel: UILabel!
    @IBOutlet private weak var genresLabel: UILabel!
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var registerButton: UIButton!
    
    private lazy var slideMenuController: SlideMenuController = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.slideMenuController!
    }()
    
    private let options: [[RightMenuOption]] = [[.collection, .wishlist, .tradeList], [.bands, .artists, .labels, .releases], [.logOut]]
    
    private var myProfile: MyProfile?

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
        if LoginService.isLoggedIn {
            loginButton.isHidden = true
            registerButton.isHidden = true
            tableView.isHidden = false
        } else {
            loginButton.isHidden = false
            registerButton.isHidden = false
            tableView.isHidden = true
        }
        
        myProfileStackView.isHidden = myProfile == nil
    }
    
    private func fetchMyProfileIfApplicable() {
        guard myProfile == nil else { return }
        
        LoginService.fetchMyProfile(username: KeychainService.getUsername()) { [weak self] (myProfile, error) in
            guard let self = self else { return }
            
            if let error = error {
                Toast.displayMessageShortly(error.localizedDescription)
            } else if let myProfile = myProfile {
                self.myProfile = myProfile
                self.bindMyProfile()
                self.properlyShowHideUIComponents()
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
        let alert = UIAlertController(title: "Log in", message: nil, preferredStyle: .alert)
        
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
                } else {
                    KeychainService.save(username: username, password: password)
                    self.tableView.reloadData()
                    self.fetchMyProfileIfApplicable()
                    self.properlyShowHideUIComponents()
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
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    private func pushMyBookmarksViewController(_ myBookmark: MyBookmark) {
        let myBookmarksViewController = UIStoryboard(name: "MyProfile", bundle: Bundle.main).instantiateViewController(withIdentifier: "MyBookmarksViewController") as! MyBookmarksViewController
        myBookmarksViewController.myBookmark = myBookmark
        (slideMenuController.mainViewController as? UINavigationController)?.pushViewController(myBookmarksViewController, animated: true)
    }
}

// MARK: - UITableViewDelegate
extension RightMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        closeRight()
        let option = options[indexPath.section][indexPath.row]
        switch option {
        case .collection: print("Collection")
        case .wishlist: print("Wishlist")
        case .tradeList: print("Trade list")
        case .bands: pushMyBookmarksViewController(.bands)
        case .artists: pushMyBookmarksViewController(.artists)
        case .labels: pushMyBookmarksViewController(.labels)
        case .releases: pushMyBookmarksViewController(.releases)
        case .logOut:
            let alert = UIAlertController(title: "You will be logged out", message: "Please confirm.", preferredStyle: .alert)
            
            let yesAction = UIAlertAction(title: "Yes, log me out", style: .default) { _ in
                KeychainService.removeUserCredential()
                LoginService.logOut()
                Toast.displayMessageShortly("You are logged out")
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
