//
//  RightMenuViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 08/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class RightMenuViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!

    deinit {
        print("RightMenuViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initAppearance()
    }
    
    private func initAppearance() {
        view.backgroundColor = Settings.currentTheme.backgroundColor
        tableView.backgroundColor = Settings.currentTheme.backgroundColor
        tableView.separatorColor = Settings.currentTheme.secondaryTitleColor
        tableView.rowHeight = UITableView.automaticDimension
        //Hide 1st section's header
        tableView.contentInset = UIEdgeInsets(top: -CGFloat.leastNormalMagnitude, left: 0, bottom: 0, right: 0)
        
        LeftMenuOptionTableViewCell.register(with: self.tableView)
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 1
    }
}

// MARK: - UITableViewDelegate
extension RightMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //Hide 1est section's header
        if section == 0 {
            return CGFloat.leastNormalMagnitude
        }
        
        return 30
    }
}

// MARK: - UITableViewDataSource
extension RightMenuViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 2
        case 2: return 1
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        return cell
    }
}
