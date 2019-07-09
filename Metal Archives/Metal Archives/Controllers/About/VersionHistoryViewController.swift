//
//  VersionHistoryViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 02/04/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import FirebaseAnalytics

final class VersionHistoryViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    // SimpleNavigationBarView
    weak var simpleNavigationBarView: SimpleNavigationBarView?
    
    private var versionHistoryList: [VersionHistory]!
    
    deinit {
        print("VersionHistoryViewController is deallocated")
    }
    
    override func viewDidLoad() {
        loadHistories()
        super.viewDidLoad()
        Analytics.logEvent("view_version_history", parameters: nil)
    }
    
    override func initAppearance() {
        super.initAppearance()
        tableView.contentInset = UIEdgeInsets(top: baseNavigationBarViewHeightWithoutTopInset - 1, left: 0, bottom: 0, right: 0)
        
        tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        
        simpleNavigationBarView?.setTitle("Version History")
        DetailTableViewCell.register(with: tableView)
    }
    
    private func loadHistories() {
        guard let url = Bundle.main.url(forResource: "VersionHistory", withExtension: "plist") else  {
            assertionFailure("Error loading list of version history. File not found.")
            return
        }
        
        guard let array = NSArray(contentsOf: url) as? [[String: String]] else {
            assertionFailure("Error loading list of version history. Unknown format.")
            return
        }
        
        versionHistoryList = Array()
        
        array.forEach({
            if let number = $0["number"], let date = $0["date"], let features = $0["features"] {
                let versionHistory = VersionHistory(number: number, date: date, features: features)
                versionHistoryList.append(versionHistory)
            }
        })
    }
}

//MARK: - UITableViewDelegate
extension VersionHistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - UITableViewDataSource
extension VersionHistoryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return versionHistoryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = DetailTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let versionHistory = versionHistoryList[indexPath.row]
        cell.fill(withTitle: versionHistory.number, detail: "\(versionHistory.date)\n\n\(versionHistory.features)")
        return cell
    }
}
