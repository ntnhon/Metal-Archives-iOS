//
//  DiscographyOptionListViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 29/05/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class DiscographyOptionListViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    var discography: Discography!
    var currentDiscographyType: DiscographyType! = .complete
    
    var selectedDiscographyType: ((DiscographyType) -> Void)?

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

extension DiscographyOptionListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        currentDiscographyType = DiscographyType(rawValue: indexPath.row) ?? .complete
        selectedDiscographyType?(currentDiscographyType)
        dismiss(animated: false, completion: nil)
    }
}

extension DiscographyOptionListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DiscographyType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SimpleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.selectionStyle = .none
        cell.displayAsBodyText()
        cell.inverseColors()
        
        let discographyType = DiscographyType.allCases[indexPath.row]
        var description = ""
        switch discographyType {
        case .complete: description = discography.completeDescription
        case .main: description = discography.mainDescription
        case .lives: description = discography.livesDescription
        case .demos: description = discography.demosDescription
        case .misc: description = discography.miscDescription
        }
    
        cell.fill(with: description)
        
        if discographyType == currentDiscographyType {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
}
