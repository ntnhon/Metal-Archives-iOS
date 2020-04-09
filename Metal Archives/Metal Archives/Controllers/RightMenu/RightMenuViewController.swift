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

final class RightMenuViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var booksImageView: UIImageView!
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var registerButton: UIButton!
    
    private lazy var slideMenuController: SlideMenuController = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.slideMenuController!
    }()

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
    }
    
    override func initAppearance() {
        super.initAppearance()
        
        booksImageView.tintColor = Settings.currentTheme.titleColor
        booksImageView.alpha = 0.5
        
        loginButton.tintColor = Settings.currentTheme.titleColor
        loginButton.setTitleColor(Settings.currentTheme.titleColor, for: .normal)
        
        registerButton.tintColor = Settings.currentTheme.titleColor
        registerButton.setTitleColor(Settings.currentTheme.titleColor, for: .normal)
        
        tableView.backgroundColor = .clear
        tableView.separatorColor = Settings.currentTheme.secondaryTitleColor
        tableView.rowHeight = UITableView.automaticDimension
        //Hide 1st section's header
        tableView.contentInset = UIEdgeInsets(top: -CGFloat.leastNormalMagnitude, left: 0, bottom: 0, right: 0)
        
        LeftMenuOptionTableViewCell.register(with: self.tableView)
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 1
    }
    
    private func properlyShowHideUIComponents() {
        if LoginService.isLoggedIn {
            loginButton.isHidden = true
            registerButton.isHidden = true
            booksImageView.isHidden = false
            tableView.isHidden = false
        } else {
            loginButton.isHidden = false
            registerButton.isHidden = false
            booksImageView.isHidden = true
            tableView.isHidden = true
        }
    }
    
    @IBAction private func loginButtonTapped() {
        let alert = UIAlertController(title: "Log in", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (usernameTextField) in
            usernameTextField.placeholder = "Username"
            usernameTextField.autocorrectionType = .no
            usernameTextField.clearButtonMode = .whileEditing
            usernameTextField.returnKeyType = .next
            usernameTextField.text = "ntnhon"
        }
        
        alert.addTextField { (passwordTextField) in
            passwordTextField.placeholder = "Password"
            passwordTextField.autocorrectionType = .no
            passwordTextField.clearButtonMode = .whileEditing
            passwordTextField.isSecureTextEntry = true
            passwordTextField.returnKeyType = .done
            passwordTextField.text = "blackjack2804"
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
}

// MARK: - UITableViewDelegate
extension RightMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //Hide 1est section's header
        if section == 0 {
            return CGFloat.leastNormalMagnitude
        }
        
        return 30
    }
}

// MARK: - UITableViewDataSource
extension RightMenuViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 2
        case 2: return 1
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        return cell
    }
}
