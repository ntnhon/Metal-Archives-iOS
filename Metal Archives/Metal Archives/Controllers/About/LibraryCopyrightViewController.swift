//
//  LibraryCopyrightViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 16/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class LibraryCopyrightViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    var library: Library!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.library.name
    }
    
    override func initAppearance() {
        super.initAppearance()
        self.tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        self.tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.tableFooterView = UIView(frame: .zero)
        
        SimpleTableViewCell.register(with: self.tableView)
    }
}

//MARK: - UITableViewDataSource
extension LibraryCopyrightViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SimpleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.selectionStyle = .none
        
        cell.fill(with: self.library.copyright + "\n\n" + self.library.copyrightDetail)
        return cell
    }
}
