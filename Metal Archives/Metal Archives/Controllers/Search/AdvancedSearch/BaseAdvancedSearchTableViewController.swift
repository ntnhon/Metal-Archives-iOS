//
//  BaseAdvancedSearchTableViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 12/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

class BaseAdvancedSearchTableViewController: BaseTableViewController {
    @IBOutlet private var titleLabels: [UILabel]!
    @IBOutlet private var detailLabels: [UILabel]!
    @IBOutlet private var switches: [UISwitch]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initAppearance()
    }
    
    func initAppearance() {
        view.backgroundColor = Settings.currentTheme.backgroundColor
        tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)

        titleLabels.forEach({
            $0.textColor = Settings.currentTheme.secondaryTitleColor
            $0.font = Settings.currentFontSize.secondaryTitleFont
        })
        
        detailLabels.forEach({
            $0.textColor = Settings.currentTheme.bodyTextColor
            $0.font = Settings.currentFontSize.bodyTextFont
        })
        
        switches.forEach({
            $0.tintColor = Settings.currentTheme.secondaryTitleColor
            $0.onTintColor = Settings.currentTheme.titleColor
        })
    }
}
