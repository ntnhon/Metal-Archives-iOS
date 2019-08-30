//
//  BaseSubSettingsTableViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 30/08/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

class BaseSubSettingsTableViewController: UITableViewController {
    
    weak var simpleNavigationBarView: SimpleNavigationBarView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initAppearance()
    }
    
    func initAppearance() {
        tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        tableView.rowHeight = UITableView.automaticDimension
    
        tableView.contentInset = UIEdgeInsets(top: baseNavigationBarViewHeightWithoutTopInset - 1, left: 0, bottom: 0, right: 0)
    }
}
