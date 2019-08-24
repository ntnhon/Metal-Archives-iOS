//
//  UpcomingAlbumsFilterOptionsViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 24/08/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class UpcomingAlbumsFilterOptionsViewController: BaseViewController {
    private var tableView: UITableView!

    var didSelectGenre: ((_ genre: Genre?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initTableView()
    }
    
    private func initTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        view.addSubview(tableView)
        tableView.fillSuperview()
        
        SimpleTableViewCell.register(with: tableView)
    }
}

// MARK: - UITableViewDelegate
extension UpcomingAlbumsFilterOptionsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedGenre = Genre(rawValue: indexPath.row)
        didSelectGenre?(selectedGenre)
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
extension UpcomingAlbumsFilterOptionsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Genre.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SimpleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.displayAsBodyText()
        cell.inverseColors()
        
        let genre = Genre.allCases[indexPath.row]
        cell.fill(with: genre.description)
        return cell
    }
}
