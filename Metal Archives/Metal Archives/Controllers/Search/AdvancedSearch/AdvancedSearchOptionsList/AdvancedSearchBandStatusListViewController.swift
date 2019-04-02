//
//  AdvancedSearchBandStatusListViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 12/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

protocol AdvancedSearchBandStatusListViewControllerDelegate {
    func didUpdateSelectedStatus(_ selectedStatus: [BandStatus])
}

final class AdvancedSearchBandStatusListViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    var selectedStatus: [BandStatus]! {
        didSet {
            self.delegate?.didUpdateSelectedStatus(self.selectedStatus)
        }
    }
    var delegate: AdvancedSearchBandStatusListViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initAppearance()
    }
    
    override func initAppearance() {
        super.initAppearance()
        self.tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        self.tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        self.tableView.rowHeight = UITableView.automaticDimension
        
        SimpleTableViewCell.register(with: self.tableView)
    }
}

//MARK: - UITableViewDelegate
extension AdvancedSearchBandStatusListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedStatus = BandStatus.allCases[indexPath.row]
        let selectedCell = tableView.cellForRow(at: indexPath)
        
        if self.selectedStatus.contains(selectedStatus) {
            self.selectedStatus.removeAll(where: { $0 == selectedStatus })
            selectedCell?.accessoryType = .none
        } else {
            self.selectedStatus.append(selectedStatus)
            selectedCell?.accessoryType = .checkmark
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Band Status"
    }
}

//MARK: - UITableViewDataSource
extension AdvancedSearchBandStatusListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BandStatus.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let status = BandStatus.allCases[indexPath.row]
        let cell = SimpleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.fill(with: status.description)
        
        if self.selectedStatus.contains(status) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        cell.displayAsSecondaryTitle()
        
        cell.textLabel?.textColor = status.color
        
        return cell
    }
}
