//
//  AdvancedSearchReleaseFormatListViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 13/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

protocol AdvancedSearchReleaseFormatListViewControllerDelegate {
    func didUpdateSelectedReleaseFormats(_ releaseTypes: [ReleaseFormat])
}

final class AdvancedSearchReleaseFormatListViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    var selectedReleaseFormats: [ReleaseFormat]! {
        didSet {
            self.delegate?.didUpdateSelectedReleaseFormats(self.selectedReleaseFormats)
        }
    }
    var delegate: AdvancedSearchReleaseFormatListViewControllerDelegate?
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
extension AdvancedSearchReleaseFormatListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let releaseFormat = ReleaseFormat.allCases[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath)
        
        if self.selectedReleaseFormats.contains(releaseFormat) {
            self.selectedReleaseFormats.removeAll(where: {$0 == releaseFormat})
            cell?.accessoryType = .none
        } else {
            self.selectedReleaseFormats.append(releaseFormat)
            cell?.accessoryType = .checkmark
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Release Format"
    }
}

//MARK: - UITableViewDataSource
extension AdvancedSearchReleaseFormatListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ReleaseFormat.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let releaseFormat = ReleaseFormat.allCases[indexPath.row]
        let cell = SimpleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.displayAsSecondaryTitle()
        cell.fill(with: releaseFormat.description)
        
        if self.selectedReleaseFormats.contains(releaseFormat) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
}
