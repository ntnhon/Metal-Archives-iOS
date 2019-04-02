//
//  MonthListViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 20/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

protocol MonthListViewControllerDelegate {
    func didSelectAMonth(_ month: MonthInYear)
}

final class MonthListViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    var delegate: MonthListViewControllerDelegate?
    var selectedMonth: MonthInYear!
    private var didScrollToSelectedMonth = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initAppearance()
    }
    
    private func initAppearance() {
        self.view.backgroundColor = Settings.currentTheme.bodyTextColor
        self.tableView.backgroundColor = Settings.currentTheme.bodyTextColor
        self.tableView.rowHeight = UITableView.automaticDimension
        
        SimpleTableViewCell.register(with: self.tableView)
    }
    
    private func scrollToSelectedMonth() {
        guard let selectedMonthIndex = monthList.firstIndex(of: selectedMonth) else { return }
        self.tableView.scrollToRow(at: IndexPath(row: selectedMonthIndex, section: 0), at: .middle, animated: false)
        self.didScrollToSelectedMonth = true
    }
}

//MARK: - UITableViewDelegate
extension MonthListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedMonth = monthList[indexPath.row]
        self.delegate?.didSelectAMonth(selectedMonth)
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.indexPathsForVisibleRows?.last?.row {
            if !self.didScrollToSelectedMonth {
                self.scrollToSelectedMonth()
            }
        }
    }
}

//MARK: - UITableViewDataSource
extension MonthListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return monthList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SimpleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let month = monthList[indexPath.row]
        cell.inverseColors()
        cell.fill(with: month.longDisplayString)
        
        if month == self.selectedMonth {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
}
