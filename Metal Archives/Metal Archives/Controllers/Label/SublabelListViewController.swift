//
//  SublabelListViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 25/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class SublabelListViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!

    var sublabels: [LabelLite]!
    var parentLabelName: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "\(self.parentLabelName!)'s sub-labels (\(sublabels.count))"
    }
    
    override func initAppearance() {
        super.initAppearance()
        self.tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        self.tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.tableFooterView = UIView(frame: .zero)
        
        SubLabelTableViewCell.register(with: self.tableView)
    }

}

//MARK: - UITableViewDelegate
extension SublabelListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let sublabel = self.sublabels[indexPath.row]
        self.pushLabelDetailViewController(urlString: sublabel.urlString, animated: true)
    }
}

//MARK: - UITableViewDataSource
extension SublabelListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sublabels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SubLabelTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let sublabel = self.sublabels[indexPath.row]
        cell.fill(with: sublabel)
        return cell
    }
}
