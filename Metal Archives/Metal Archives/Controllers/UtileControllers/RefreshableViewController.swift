//
//  RefreshableViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Toaster

class RefreshableViewController: BaseViewController {
    @IBOutlet private(set) weak var tableView: UITableView!
    private(set) var refreshControl: UIRefreshControl!
    var numberOfTries = 0
    
    override func viewDidLoad() {
        self.addRefreshControl()
        super.viewDidLoad()
    }
    
    override func initAppearance() {
        super.initAppearance()
        self.tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        self.tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.tableFooterView = UIView(frame: .zero)
    }
    
    private func addRefreshControl() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.refreshControl.tintColor = Settings.currentTheme.bodyTextColor
        self.tableView.addSubview(refreshControl)
    }
    
    @objc func refresh() {
        
    }
    
    func endRefreshing() {
        if self.refreshControl.isRefreshing {
            self.refreshControl.endRefreshing()
        }
    }
    
    func refreshSuccessfully(message: String = "You are up to date! 🤘") {
        if self.refreshControl.isRefreshing {
            Toast.displayMessageShortly(message)
            self.refreshControl.endRefreshing()
        }
    }
}
