//
//  SimpleSearchTypeListViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 04/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

protocol SimpleSearchTypeListViewControllerDelegate {
    func didChangeSimpleSearchType(_ simpleSearchType: SimpleSearchType)
}

final class SimpleSearchTypeListViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!

    var currentSimpleSearchType: SimpleSearchType!
    var delegate: SimpleSearchTypeListViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func initAppearance() {
        super.initAppearance()
        self.title = "Search Type"
        
        self.tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        self.tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        self.tableView.rowHeight = UITableView.automaticDimension
        
        SimpleTableViewCell.register(with: self.tableView)
    }

}

//MARK: - UITableViewDelegate
extension SimpleSearchTypeListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        self.currentSimpleSearchType = SimpleSearchType(rawValue: indexPath.row)
        tableView.reloadData()
        self.delegate?.didChangeSimpleSearchType(self.currentSimpleSearchType)
    }
}

//MARK: - UITableViewDataSource
extension SimpleSearchTypeListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SimpleSearchType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SimpleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.selectionStyle = .none
        
        let simpleSearchType = SimpleSearchType.allCases[indexPath.row]
        cell.fill(with: simpleSearchType.description)
        
        if self.currentSimpleSearchType == simpleSearchType {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        cell.displayAsSecondaryTitle()
        
        return cell
    }
}

