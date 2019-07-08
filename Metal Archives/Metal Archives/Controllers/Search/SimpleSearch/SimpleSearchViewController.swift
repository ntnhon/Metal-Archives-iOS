//
//  SimpleSearchViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import FirebaseAnalytics
import CoreData

final class SimpleSearchViewController: UITableViewController {
    private var searchTermTextField: BaseTextField!
    private var horizontalOptionsView: HorizontalOptionsView!
    var isBeingSelected: Bool = true {
        didSet {
            if isBeingSelected {
                searchTermTextField?.becomeFirstResponder()
            } else {
                searchTermTextField?.resignFirstResponder()
            }
        }
    }
    
    private let imFeelingLuckyView: ImFeelingLuckyView = .initFromNib()
    private var currentSimpleSearchType: SimpleSearchType = .bandName {
        didSet {
            searchTermTextField?.placeholder = currentSimpleSearchType.description
            searchTermTextField?.title = "Search by \(currentSimpleSearchType.description)"
        }
    }
    
    // Core Data
    private let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var searchHistories: [SearchHistory] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imFeelingLuckyView.delegate = self
        initAppearance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadSearchHistories()
    }
    
    private func initAppearance() {
        view.backgroundColor = Settings.currentTheme.backgroundColor
        tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        tableView.rowHeight = UITableView.automaticDimension
        tableView.contentInset = .init(top: -CGFloat.leastNormalMagnitude, left: 0, bottom: 0, right: 0)
        
        SimpleSearchTermTableViewCell.register(with: tableView)
        SimpleSearchTypeTableViewCell.register(with: tableView)
    }
    
    private func loadSearchHistories() {
        let fetchRequest = NSFetchRequest<SearchHistory>(entityName: "SearchHistory")
        
        do {
            searchHistories = try managedContext.fetch(fetchRequest)
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let simpleSearchResultVC as SimpleSearchResultViewController:
            simpleSearchResultVC.searchTerm = searchTermTextField.text
            simpleSearchResultVC.simpleSearchType = currentSimpleSearchType

            if let _ = sender as? ImFeelingLuckyView {
                simpleSearchResultVC.isFeelingLucky = true
                
                Analytics.logEvent(AnalyticsEvent.FeelingLucky, parameters: nil)
            } else {
                simpleSearchResultVC.isFeelingLucky = false
            }

            Analytics.logEvent(AnalyticsEvent.PerformSimpleSearch, parameters: [AnalyticsParameter.SearchType: currentSimpleSearchType.description, AnalyticsParameter.SearchTerm: searchTermTextField.text!])
            
        default:
            break
        }
    }
}

extension SimpleSearchViewController {
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = Settings.currentTheme.titleColor
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let footerView = view as? UITableViewHeaderFooterView {
            footerView.textLabel?.textColor = Settings.currentTheme.titleColor
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

//MARK: - ImFeelingLuckyViewDelegate
extension SimpleSearchViewController: ImFeelingLuckyViewDelegate {
    func didTapImFeelingLuckyButton() {
        performSegue(withIdentifier: "ShowSearchResult", sender: imFeelingLuckyView)
    }
}

//MARK: - HorizontalOptionsViewDelegate
extension SimpleSearchViewController: HorizontalOptionsViewDelegate {
    func horizontalOptionsView(_ horizontalOptionsView: HorizontalOptionsView, didSelectItemAt index: Int) {
        currentSimpleSearchType = SimpleSearchType(rawValue: index) ?? .bandName
        
        Analytics.logEvent(AnalyticsEvent.ChangeSimpleSearchType, parameters: [AnalyticsParameter.SearchType: currentSimpleSearchType.description])
    }
}

// MARK: - UITextFieldDelegate
extension SimpleSearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        performSegue(withIdentifier: "ShowSearchResult", sender: searchTermTextField)
        return true
    }
}

// MARK: - UITableViewDelegate && Datasource
extension SimpleSearchViewController {
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNormalMagnitude
        } else {
            return 20
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Search History"
        }
        
        return nil
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, 0): return searchTermTableViewCell(forRowAt: indexPath)
        case (0, 1): return searchTypeTableViewCell(forRowAt: indexPath)
        default: return UITableViewCell()
        }
    }
    
    private func searchTermTableViewCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SimpleSearchTermTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        searchTermTextField = cell.searchTermTextField
        searchTermTextField.delegate = self
        searchTermTextField.returnKeyType = .search
        searchTermTextField.inputAccessoryView = imFeelingLuckyView
        currentSimpleSearchType = .bandName //trigger didSet
        return cell
    }
    
    private func searchTypeTableViewCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SimpleSearchTypeTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.horizontalOptionsView.delegate = self
        return cell
    }
}
