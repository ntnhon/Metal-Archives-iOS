//
//  LineupOptionListViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 01/06/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class LineupOptionListViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    var release: Release!
    var currentLineupType: LineUpType!
    
    var selectedLineupType: ((LineUpType) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SimpleTableViewCell.register(with: tableView)
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preferredContentSize = tableView.contentSize
    }
}

extension LineupOptionListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        currentLineupType = LineUpType(rawValue: indexPath.row) ?? .member
        selectedLineupType?(currentLineupType)
        dismiss(animated: false, completion: nil)
    }
}

extension LineupOptionListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LineUpType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SimpleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.selectionStyle = .none
        cell.displayAsBodyText()
        cell.inverseColors()
        
        let lineupType = LineUpType.allCases[indexPath.row]
        var description = ""
        switch lineupType {
        case .complete: description = release.completeLineupDescription
        case .member: description = release.bandMembersDescription
        case .guest: description = release.guestSessionDescription
        case .other: description = release.otherStaffDescription
        }
        
        cell.fill(with: description)
        
        if lineupType == currentLineupType {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
}
