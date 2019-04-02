//
//  BrowseBandsAlphabeticallyViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 13/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import FirebaseAnalytics

final class BrowseBandsAlphabeticallyViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Browse Bands - Alphabetically"
    }
    
    override func initAppearance() {
        super.initAppearance()
        self.tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        self.tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.tableView.contentInset = UIEdgeInsets(top: -CGFloat.leastNormalMagnitude, left: 0, bottom: 0, right: 0)
        
        ViewMoreTableViewCell.register(with: self.tableView)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let bandAphabeticallyResultViewController as BrowseBandsResultViewController:
            if let letter = sender as? Letter {
                bandAphabeticallyResultViewController.parameter = "ajax-letter/l/" + letter.parameterString
                bandAphabeticallyResultViewController.context = "Bands by \"\(letter.description)\""
                
                Analytics.logEvent(AnalyticsEvent.PerformBrowseBands, parameters: [AnalyticsParameter.Letter: letter.description])
            }
        default:
            break
        }
    }
}

//MARK: - UITableViewDelegate
extension BrowseBandsAlphabeticallyViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let letter = Letter.allCases[indexPath.row]
        self.performSegue(withIdentifier: "ShowResults", sender: letter)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "For numbers, select #.\nFor non-Latin alphabets or for symbols, select ~.\n\nNote: leading \"The __\" are ignored (e.g. \"The Chasm\" appears under C, not T)"
    }
}

//MARK: - UITableViewDataSource
extension BrowseBandsAlphabeticallyViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Letter.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ViewMoreTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.displayAsSecondaryTitle()
        
        let letter = Letter.allCases[indexPath.row]
        cell.fill(message: letter.description)
        
        return cell
    }
}
