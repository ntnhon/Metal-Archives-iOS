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
    @IBOutlet private weak var tableView: UITableView!
    
    private var letters = Letter.allCases
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Browse Labels - Alphabetically"
        
        //Remove "~"
        self.letters.removeAll { (letter) -> Bool in
            letter == Letter.tilde
        }
    }
    
    override func initAppearance() {
        super.initAppearance()
        self.tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        self.tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.tableFooterView = UIView(frame: .zero)
        
        ViewMoreTableViewCell.register(with: self.tableView)
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
        let letter = self.letters[indexPath.row]
        self.performSegue(withIdentifier: "ShowResults", sender: letter)
    }
}

//MARK: - UITableViewDataSource
extension BrowseLabelsAlphabeticallyViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.letters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ViewMoreTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.displayAsSecondaryTitle()
        
        let letter = self.letters[indexPath.row]
        cell.fill(message: letter.description)
        
        return cell
    }
}
