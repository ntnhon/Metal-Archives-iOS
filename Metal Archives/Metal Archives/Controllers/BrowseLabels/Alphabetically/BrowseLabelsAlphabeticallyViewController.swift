//
//  BrowseLabelsAlphabeticallyViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import FirebaseAnalytics

final class BrowseLabelsAlphabeticallyViewController: BaseViewController {
    @IBOutlet private weak var simpleNavigationBarView: SimpleNavigationBarView!
    @IBOutlet private weak var tableView: UITableView!
    
    private var letters = Letter.allCases
    override func viewDidLoad() {
        super.viewDidLoad()
        //Remove "~"
        letters.removeAll { $0 == Letter.tilde }
    }

    override func initAppearance() {
        super.initAppearance()
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        let tableViewTopInset = simpleNavigationBarView.bounds.height - UIApplication.shared.statusBarFrame.height
        tableView.contentInset = UIEdgeInsets(top: tableViewTopInset, left: 0, bottom: 0, right: 0)
        
        tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        
        ViewMoreTableViewCell.register(with: tableView)
        initSimpleNavigationBarView()
    }
    
    private func initSimpleNavigationBarView() {
        simpleNavigationBarView.setAlphaForBackgroundAndTitleLabel(1)
        simpleNavigationBarView.setTitle("Browse Labels - Alphabetically")
        simpleNavigationBarView.setRightButtonIcon(nil)
        
        simpleNavigationBarView.didTapLeftButton = { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let browseLabelsAlphabeticallyResultViewController as BrowseLabelsAlphabeticallyResultViewController:
            if let letter = sender as? Letter {
                browseLabelsAlphabeticallyResultViewController.letter = letter
                
                Analytics.logEvent(AnalyticsEvent.PerformBrowseLabels, parameters: ["Module": "Alphabetically", AnalyticsParameter.Letter: letter.description])
            }
            
        default:
            break
        }
    }
}

//MARK: - UITableViewDelegate
extension BrowseLabelsAlphabeticallyViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let letter = letters[indexPath.row]
        performSegue(withIdentifier: "ShowResults", sender: letter)
    }
}

//MARK: - UITableViewDataSource
extension BrowseLabelsAlphabeticallyViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return letters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ViewMoreTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.displayAsSecondaryTitle()
        
        let letter = letters[indexPath.row]
        cell.fill(message: letter.description)
        
        return cell
    }
}
