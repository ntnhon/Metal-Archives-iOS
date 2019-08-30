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
    
    private let customGenres = UserDefaults.customGenres()

    var didSelectGenreString: ((_ genreString: String?, _ byAndOperator: Bool) -> Void)?
    var didTapManageButton: (() -> Void)?
    
    deinit {
        print("UpcomingAlbumsFilterOptionsViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addManageBarButton()
        initTableView()
    }
    
    private func addManageBarButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(manageBarButtonTapped))
    }
    
    @objc private func manageBarButtonTapped() {
        dismiss(animated: true, completion: nil)
        didTapManageButton?()
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
        
        let genreString: String
        if indexPath.section == 0 {
            genreString = Genre.allCases[indexPath.row].description
            didSelectGenreString?(genreString, false)
        } else {
            genreString = customGenres[indexPath.row]
            didSelectGenreString?(genreString, true)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard customGenres.count > 0 else {
            return nil
        }
        
        if section == 0 {
            return "Default entries"
        } else {
            return "Custom entries"
        }
    }
}

// MARK: - UITableViewDataSource
extension UpcomingAlbumsFilterOptionsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return customGenres.count > 0 ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return Genre.allCases.count
        }
        
        return customGenres.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SimpleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.displayAsBodyText()
        cell.inverseColors()
        
        let genreString: String
        if indexPath.section == 0 {
            genreString = Genre.allCases[indexPath.row].description
        } else {
            genreString = customGenres[indexPath.row]
        }
        
        cell.fill(with: genreString)
        return cell
    }
}
