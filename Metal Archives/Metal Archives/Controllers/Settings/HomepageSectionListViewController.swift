//
//  HomepageSectionListViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 30/08/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

protocol HomepageSectionListViewControllerDelegate {
    func didChangeHomepageSectionOrder()
}

final class HomepageSectionListViewController: BaseSubSettingsTableViewController {
    private var sections: [HomepageSection] = UserDefaults.homepageSections()
    private var madeChanges: Bool = false
    
    var delegate: HomepageSectionListViewControllerDelegate?
    
    deinit {
        print("HomepageSectionListViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParent {
            if madeChanges {
                parent?.displayRestartAlert()
            }
            UserDefaults.setHomepageSections(sections)
            delegate?.didChangeHomepageSectionOrder()
        }
    }
    
    override func initAppearance() {
        super.initAppearance()
        simpleNavigationBarView?.setTitle("Homepage Section Order")
        
        tableView.isScrollEnabled = false
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.setEditing(true, animated: false)
        SimpleTableViewCell.register(with: tableView)
    }
}

// MARK: - UITableViewDelegate
extension HomepageSectionListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        return proposedDestinationIndexPath
    }
}

// MARK: - UITableViewDatasource
extension HomepageSectionListViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SimpleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.displayAsBodyText()
        let section = sections[indexPath.row]
        cell.fill(with: section.description)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movingSection = sections[sourceIndexPath.row]
        sections.remove(at: sourceIndexPath.row)
        sections.insert(movingSection, at: destinationIndexPath.row)
        madeChanges = true
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
