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
    
    private var versionHistoryList: [VersionHistory]!
    override func viewDidLoad() {
        self.loadHistories()
        super.viewDidLoad()
        self.title = "Version History"
        
        Analytics.logEvent(AnalyticsEvent.ViewVersionHistory, parameters: nil)
    }
    
    override func initAppearance() {
        super.initAppearance()
        self.tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        self.tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.tableFooterView = UIView(frame: .zero)
        
        DetailTableViewCell.register(with: self.tableView)
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
        
        self.versionHistoryList = Array()
        
        array.forEach({
            if let number = $0["number"], let date = $0["date"], let features = $0["features"] {
                let versionHistory = VersionHistory(number: number, date: date, features: features)
                self.versionHistoryList.append(versionHistory)
            }
        })
    }
}

//MARK: - UITableViewDelegate
extension VersionHistoryViewController: UITableViewDelegate {
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
        return self.versionHistoryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = DetailTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let versionHistory = self.versionHistoryList[indexPath.row]
        cell.fill(withTitle: versionHistory.number, detail: "\(versionHistory.date)\n\n\(versionHistory.features)")
        return cell
    }
}
