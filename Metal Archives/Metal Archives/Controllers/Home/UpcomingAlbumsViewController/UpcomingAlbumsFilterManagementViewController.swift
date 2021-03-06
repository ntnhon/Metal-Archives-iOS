//
//  UpcomingAlbumsFilterManagementViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/08/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import FirebaseAnalytics

final class UpcomingAlbumsFilterManagementViewController: BaseViewController {
    private var simpleNavigationBarView: SimpleNavigationBarView!
    private var tableView: UITableView!
    
    private var customGenres: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        initSimpleNavigationBarView()
        initTableView()
        customGenres = UserDefaults.customGenres()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            UserDefaults.setCustomGenres(customGenres)
        }
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
        let alert = UIAlertController(title: "Enter new genre", message: "Needless to say \"metal\" in the genre.\n👎 Blackened death metal\n👍 Blackened death", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: nil)
        
        let addAction = UIAlertAction(title: "Add 🤘", style: .default) { [unowned self] (_) in
            guard let textField = alert.textFields?.first, let genre = textField.text else { return }
            self.customGenres.append(genre)
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [IndexPath(row: self.customGenres.count-1, section: 0)], with: .fade)
            self.tableView.endUpdates()
            Analytics.logEvent("add_genre_in_filter_management", parameters: nil)
        }
        alert.addAction(addAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (_) in
            Analytics.logEvent("cancel_add_genre_in_filter_management", parameters: nil)
        }
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
        return "Click + button to create custom genres"
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let predefinedGenres = Genre.allCases.map({$0.description}).joined(separator: ", ")
        
        return "DEFAULT ENTRIES:\n\(predefinedGenres)."
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return swipeActionsConfiguration(forRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return swipeActionsConfiguration(forRowAt: indexPath)
    }
    
    private func swipeActionsConfiguration(forRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard customGenres.count > 0 else {
            return nil
        }
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [unowned self] (_, _, completionHanlder) in
            self.customGenres.remove(at: indexPath.row)
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.tableView.endUpdates()
            
            if self.customGenres.count == 0 {
                self.tableView.reloadData()
            }
            
            completionHanlder(true)
            Analytics.logEvent("remove_genre_in_filter_management", parameters: nil)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

// MARK: - UITableViewDataSource
extension UpcomingAlbumsFilterManagementViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customGenres.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SimpleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.displayAsBodyText()
        cell.fill(with: customGenres[indexPath.row])
        return cell
    }
}
