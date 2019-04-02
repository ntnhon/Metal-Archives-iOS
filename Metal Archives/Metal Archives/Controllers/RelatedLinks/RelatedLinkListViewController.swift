//
//  BandRelatedLinkListViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 20/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class RelatedLinkListViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!

    var relatedLinks: [RelatedLink]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "\(relatedLinks.count) links"
    }
    
    override func initAppearance() {
        super.initAppearance()
        self.tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        self.tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.tableView.contentInset = UIEdgeInsets(top: -CGFloat.leastNormalMagnitude, left: 0, bottom: 0, right: 0)
        
        RelatedLinkTableViewCell.register(with: self.tableView)
    }

}

//MARK: - UITableViewDelegate
extension RelatedLinkListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let relatedLink = self.relatedLinks[indexPath.row]
        self.presentAlertOpenURLInBrowsers(URL(string: relatedLink.urlString)!, alertTitle: "Open this link in browser", alertMessage: relatedLink.urlString, shareMessage: "Share this link")
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //Hide 1st section header
        return CGFloat.leastNormalMagnitude
    }
}

//MARK: - UITableViewDataSource
extension RelatedLinkListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.relatedLinks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let relatedLink = self.relatedLinks[indexPath.row]
        let cell = RelatedLinkTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.bind(relatedLink: relatedLink)
        
        return cell
    }
}
