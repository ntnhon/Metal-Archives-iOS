//
//  BaseAdvancedSearchTableViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 12/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

class BaseAdvancedSearchTableViewController: UITableViewController {
    @IBOutlet private var titleLabels: [UILabel]!
    @IBOutlet private var detailLabels: [UILabel]!
    @IBOutlet private var switches: [UISwitch]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initAppearance()
    }
    
    func initAppearance() {
        self.view.backgroundColor = Settings.currentTheme.backgroundColor
        self.tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        self.tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.tableFooterView = UIView(frame: .zero)
        
        self.initPerformSearchBarButtonItem()
        
        self.titleLabels.forEach({
            $0.textColor = Settings.currentTheme.secondaryTitleColor
            $0.font = Settings.currentFontSize.secondaryTitleFont
        })
        
        self.detailLabels.forEach({
            $0.textColor = Settings.currentTheme.bodyTextColor
            $0.font = Settings.currentFontSize.bodyTextFont
        })
        
        self.switches.forEach({
            $0.tintColor = Settings.currentTheme.secondaryTitleColor
            $0.onTintColor = Settings.currentTheme.titleColor
        })
    }
    
    private func initPerformSearchBarButtonItem() {
        let button = UIBarButtonItem(image: UIImage(named: "search"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(didTapPerformSearchBarButtonItem))
        self.navigationItem.rightBarButtonItem = button
    }
    
    @objc private func didTapPerformSearchBarButtonItem() {
        self.performSearch()
    }
    
    func performSearch() {
        
    }
}
