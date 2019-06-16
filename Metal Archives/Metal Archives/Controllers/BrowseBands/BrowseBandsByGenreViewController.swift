//
//  BrowseBandsByGenreViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 16/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import FirebaseAnalytics

final class BrowseBandsByGenreViewController: BaseViewController {
    @IBOutlet private weak var simpleNavigationBarView: SimpleNavigationBarView!
    @IBOutlet private weak var tableView: UITableView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func initAppearance() {
        super.initAppearance()
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        let tableViewTopInset = simpleNavigationBarView.bounds.height - UIApplication.shared.statusBarFrame.height
        tableView.contentInset = UIEdgeInsets(top: tableViewTopInset - 1, left: 0, bottom: 0, right: 0)
        
        tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        
        ViewMoreTableViewCell.register(with: tableView)
        initSimpleNavigationBarView()
    }
    
    private func initSimpleNavigationBarView() {
        simpleNavigationBarView.setAlphaForBackgroundAndTitleLabel(1)
        simpleNavigationBarView.setTitle("Browse Bands - By Genre")
        simpleNavigationBarView.setRightButtonIcon(nil)
        
        simpleNavigationBarView.didTapLeftButton = { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let bandAphabeticallyResultViewController as BrowseBandsResultViewController:
            if let genre = sender as? Genre {
                bandAphabeticallyResultViewController.parameter = "ajax-genre/g/" + genre.parameterString
                bandAphabeticallyResultViewController.context = "Bands play \(genre.description)"
                
                Analytics.logEvent(AnalyticsEvent.PerformBrowseBands, parameters: [AnalyticsParameter.Genre: genre.description])
            }
        default:
            break
        }
    }
}

//MARK: - UITableViewDelegate
extension BrowseBandsByGenreViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let genre = Genre.allCases[indexPath.row]
        
        performSegue(withIdentifier: "ShowResults", sender: genre)
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "For genre fine-tuning, use the advanced search."
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = Settings.currentTheme.titleColor
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let footerView = view as? UITableViewHeaderFooterView {
            footerView.textLabel?.textColor = Settings.currentTheme.titleColor
        }
    }
}

//MARK: - UITableViewDataSource
extension BrowseBandsByGenreViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Genre.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ViewMoreTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.displayAsSecondaryTitle()
        
        let genre = Genre.allCases[indexPath.row]
        cell.fill(message: genre.description)
        return cell
    }
}
