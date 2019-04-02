//
//  AdvancedSearchReleaseTypeListViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 13/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

protocol AdvancedSearchReleaseTypeListViewControllerDelegate {
    func didUpdateSelectedReleaseTypes(_ releaseTypes: [ReleaseType])
}

final class AdvancedSearchReleaseTypeListViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    var selectedReleaseTypes: [ReleaseType]! {
        didSet {
            self.delegate?.didUpdateSelectedReleaseTypes(self.selectedReleaseTypes)
        }
    }
    var delegate: AdvancedSearchReleaseTypeListViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
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
extension AdvancedSearchReleaseTypeListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let releaseType = ReleaseType.allCases[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath)
        
        if self.selectedReleaseTypes.contains(releaseType) {
            self.selectedReleaseTypes.removeAll(where: {$0 == releaseType})
            cell?.accessoryType = .none
        } else {
            self.selectedReleaseTypes.append(releaseType)
            cell?.accessoryType = .checkmark
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Release Type"
    }
}

//MARK: - UITableViewDataSource
extension AdvancedSearchReleaseTypeListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ReleaseType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let releaseType = ReleaseType.allCases[indexPath.row]
        let cell = SimpleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.displayAsSecondaryTitle()
        cell.fill(with: releaseType.description)
        
        if self.selectedReleaseTypes.contains(releaseType) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
}
