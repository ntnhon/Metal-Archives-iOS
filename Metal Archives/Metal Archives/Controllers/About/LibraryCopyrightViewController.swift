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
    
    // SimpleNavigationBarView
    weak var simpleNavigationBarView: SimpleNavigationBarView?
    
    var library: Library!
    
    deinit {
        print("LibraryCopyrightViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func initAppearance() {
        super.initAppearance()
        tableView.contentInset = UIEdgeInsets(top: baseNavigationBarViewHeightWithoutTopInset - 1, left: 0, bottom: 0, right: 0)
        
        tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        
        simpleNavigationBarView?.setTitle(library.name)
        SimpleTableViewCell.register(with: tableView)
    }
}

// MARK: - UITableViewDelegate
extension LibraryCopyrightViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
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
        
        cell.fill(with: library.copyright + "\n\n" + library.copyrightDetail)
        return cell
    }
}
