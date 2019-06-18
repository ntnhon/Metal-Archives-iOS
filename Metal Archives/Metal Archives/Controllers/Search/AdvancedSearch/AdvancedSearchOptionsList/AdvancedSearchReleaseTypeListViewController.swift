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
            delegate?.didUpdateSelectedReleaseTypes(selectedReleaseTypes)
        }
    }
    var delegate: AdvancedSearchReleaseTypeListViewControllerDelegate?
    weak var simpleNavigationBarView: SimpleNavigationBarView?
    deinit {
        print("AdvancedSearchReleaseTypeListViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        simpleNavigationBarView?.setTitle("Release Type")
        simpleNavigationBarView?.setRightButtonIcon(nil)
    }

    override func initAppearance() {
        super.initAppearance()
        tableView.contentInset = UIEdgeInsets(top: baseNavigationBarViewHeightWithoutTopInset - 1, left: 0, bottom: 0, right: 0)
        tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        tableView.rowHeight = UITableView.automaticDimension
        
        SimpleTableViewCell.register(with: tableView)
    }
}

//MARK: - UITableViewDelegate
extension AdvancedSearchReleaseTypeListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let releaseType = ReleaseType.allCases[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath)
        
        if selectedReleaseTypes.contains(releaseType) {
            selectedReleaseTypes.removeAll(where: {$0 == releaseType})
            cell?.accessoryType = .none
        } else {
            selectedReleaseTypes.append(releaseType)
            cell?.accessoryType = .checkmark
        }
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
        
        if selectedReleaseTypes.contains(releaseType) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
}
