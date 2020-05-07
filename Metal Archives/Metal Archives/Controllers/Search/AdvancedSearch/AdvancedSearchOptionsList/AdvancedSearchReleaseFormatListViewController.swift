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
            delegate?.didUpdateSelectedReleaseFormats(selectedReleaseFormats)
        }
    }
    var delegate: AdvancedSearchReleaseFormatListViewControllerDelegate?
    weak var simpleNavigationBarView: SimpleNavigationBarView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        simpleNavigationBarView?.setTitle("Release Format")
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
extension AdvancedSearchReleaseFormatListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let releaseFormat = ReleaseFormat.allCases[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath)
        
        if selectedReleaseFormats.contains(releaseFormat) {
            selectedReleaseFormats.removeAll(where: {$0 == releaseFormat})
            cell?.accessoryType = .none
        } else {
            selectedReleaseFormats.append(releaseFormat)
            cell?.accessoryType = .checkmark
        }
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
        
        if selectedReleaseFormats.contains(releaseFormat) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
}
