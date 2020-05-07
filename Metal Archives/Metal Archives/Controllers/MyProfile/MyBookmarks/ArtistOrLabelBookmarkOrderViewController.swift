//
//  ArtistOrLabelBookmarkOrderViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 11/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class ArtistOrLabelBookmarkOrderViewController: BaseViewController {
    enum BookmarkType {
        case artist, label
    }
    
    @IBOutlet private weak var tableView: UITableView!
    
    var currentOrder: ArtistOrLabelBookmarkOrder = .lastModifiedDescending
    
    var selectedArtistOrLabelBookmarkOrder: ((ArtistOrLabelBookmarkOrder) -> Void)?

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

extension ArtistOrLabelBookmarkOrderViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        currentOrder = ArtistOrLabelBookmarkOrder(rawValue: indexPath.row) ?? .nameAscending
        selectedArtistOrLabelBookmarkOrder?(currentOrder)
        dismiss(animated: false, completion: nil)
    }
}

extension ArtistOrLabelBookmarkOrderViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ArtistOrLabelBookmarkOrder.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SimpleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.selectionStyle = .none
        cell.displayAsBodyText()
        cell.inverseColors()
        
        let order = ArtistOrLabelBookmarkOrder.allCases[indexPath.row]
        cell.fill(with: order.description)
        
        if order == currentOrder {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
}

