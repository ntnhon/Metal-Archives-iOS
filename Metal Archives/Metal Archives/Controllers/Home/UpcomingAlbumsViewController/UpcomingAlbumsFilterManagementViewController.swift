//
//  UpcomingAlbumsFilterManagementViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/08/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class UpcomingAlbumsFilterManagementViewController: BaseViewController {
    private var simpleNavigationBarView: SimpleNavigationBarView!
    private var tableView: UITableView!
    
    private var customGenres: [String] = []
    
    deinit {
        print("UpcomingAlbumsFilterManagementViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSimpleNavigationBarView()
        initTableView()
    }
    
    private func initSimpleNavigationBarView() {
        simpleNavigationBarView = SimpleNavigationBarView(frame: .zero)
        view.addSubview(simpleNavigationBarView)
        simpleNavigationBarView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor)
        
        simpleNavigationBarView.setAlphaForBackgroundAndTitleLabel(1)
        simpleNavigationBarView.setTitle("Manage genres filter")
        simpleNavigationBarView.setRightButtonIcon(#imageLiteral(resourceName: "plus"))
        
        simpleNavigationBarView.didTapLeftButton = { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
        
        simpleNavigationBarView.didTapRightButton = { [unowned self] in
            self.displayAlertToAddNewGenre()
        }
    }
    
    private func initTableView() {
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        
        view.addSubview(tableView)
        tableView.anchor(top: simpleNavigationBarView.bottomAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        
        SimpleTableViewCell.register(with: tableView)
    }
    
    private func displayAlertToAddNewGenre() {
        let alert = UIAlertController(title: "Enter new genre", message: nil, preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: nil)
        
        let addAction = UIAlertAction(title: "Add 🤘", style: .default) { [unowned self] (_) in
            guard let textField = alert.textFields?.first else { return }
            print(textField.text)
        }
        alert.addAction(addAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate
extension UpcomingAlbumsFilterManagementViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Your custom genres"
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let predefinedGenres = Genre.allCases.map({$0.description}).joined(separator: ", ")
        
        return "PREDEFINED GENRES:\n\(predefinedGenres)."
    }
}

// MARK: - UITableViewDataSource
extension UpcomingAlbumsFilterManagementViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if customGenres.count == 0 {
            return 1
        }
        
        return customGenres.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SimpleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        
        if customGenres.count == 0 {
            cell.displayAsItalicBodyText()
            cell.fill(with: "Tap + button to add a new genre")
        } else {
            cell.displayAsBodyText()
            cell.fill(with: customGenres[indexPath.row])
        }
        
        return cell
    }
}
