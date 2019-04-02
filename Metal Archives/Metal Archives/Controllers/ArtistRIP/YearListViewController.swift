//
//  YearListViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

protocol YearListViewControllerDelegate {
    func didChangeYear(_ year: String)
}

final class YearListViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    var selectedYear: String!
    var delegate: YearListViewControllerDelegate?
    
    private let minimumYear = 1970
    private var yearList: [String]!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initYearList()
    }
    
    override func initAppearance() {
        super.initAppearance()
        self.view.backgroundColor = Settings.currentTheme.bodyTextColor
        self.tableView.backgroundColor = Settings.currentTheme.bodyTextColor
        self.tableView.rowHeight = UITableView.automaticDimension
        
        SimpleTableViewCell.register(with: self.tableView)
    }
    
    private func initYearList() {
        self.yearList = []
        
        let thisYear = Calendar.current.component(.year, from: Date())
        
        for i in 0..<thisYear - minimumYear {
            self.yearList.append("\(thisYear - i)")
        }
        
        self.yearList.insert("Any", at: 0)
    }
}

//MARK: - UITableViewDelegate
extension YearListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let `selectedYear` = self.selectedYear, let selectedYearIndex = self.yearList.firstIndex(of: "\(selectedYear)") {
            let selectedCell = tableView.cellForRow(at: IndexPath(row: selectedYearIndex, section: 0))
            selectedCell?.accessoryType = .none
        }
        
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        
        self.selectedYear = self.yearList[indexPath.row]
        
        self.delegate?.didChangeYear(self.selectedYear)
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - UITableViewDataSource
extension YearListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.yearList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SimpleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.inverseColors()
        
        let year = self.yearList[indexPath.row]
        cell.fill(with: year)
        
        cell.accessoryType = .none
        if let `selectedYear` = selectedYear {
            if year == selectedYear {
                cell.accessoryType = .checkmark
            }
        }
        
        return cell
    }
}
