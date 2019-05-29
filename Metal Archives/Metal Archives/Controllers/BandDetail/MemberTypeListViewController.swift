//
//  MemberTypeListViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 29/05/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class MemberTypeListViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    weak var band: Band!
    var currentMemberType: MembersType = .complete
    var selectedMemberType: ((MembersType) -> Void)?
    
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

extension MemberTypeListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        currentMemberType = MembersType(rawValue: indexPath.row) ?? .complete
        selectedMemberType?(currentMemberType)
        dismiss(animated: false, completion: nil)
    }
}

extension MemberTypeListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MembersType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SimpleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.selectionStyle = .none
        cell.displayAsBodyText()
        cell.inverseColors()
        
        let membersType = MembersType.allCases[indexPath.row]
        var description = ""
        switch membersType {
        case .complete: description = band.completeLineupDescription
        case .lastKnown: description = band.lastKnownLineupDescription
        case .current: description = band.currentLineupDescription
        case .past: description = band.pastMembersDescription
        case .live: description = band.liveMusiciansDescription
        }
        
        cell.fill(with: description)
        
        if membersType == currentMemberType {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
}
