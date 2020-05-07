//
//  UserReviewOrderViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 15/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class UserReviewOrderViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    var currentOrder: UserReviewOrder = .dateDescending
    var selectedOrder: ((UserReviewOrder) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        SimpleTableViewCell.register(with: tableView)
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.backgroundColor = Settings.currentTheme.bodyTextColor
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preferredContentSize = tableView.contentSize
    }
}

extension UserReviewOrderViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        currentOrder = UserReviewOrder(rawValue: indexPath.row) ?? .dateDescending
        selectedOrder?(currentOrder)
        dismiss(animated: false, completion: nil)
    }
}

extension UserReviewOrderViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserReviewOrder.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SimpleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.selectionStyle = .none
        cell.displayAsBodyText()
        cell.inverseColors()
        
        let order = UserReviewOrder.allCases[indexPath.row]
        cell.fill(with: order.description)
        
        if order == currentOrder {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
}
