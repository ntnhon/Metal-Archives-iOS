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
    private weak var searchTermTextField: BaseTextField!
    private weak var horizontalOptionsView: HorizontalOptionsView!
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
            updateSearchArea()
        }
    }
    
    // Core Data
    private let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var searchHistories: [SearchHistory] = []
    private var doNotRecordHistory = false

    override func viewDidLoad() {
        super.viewDidLoad()
        imFeelingLuckyView.delegate = self
        initAppearance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadSearchHistories()
        tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateSearchArea()
    }
    
    private func updateSearchArea() {
        searchTermTextField?.placeholder = currentSimpleSearchType.description
        searchTermTextField?.title = "Search by \(currentSimpleSearchType.description)"
        horizontalOptionsView?.selectedIndex = currentSimpleSearchType.rawValue
    }
    
    private func initAppearance() {
        view.backgroundColor = Settings.currentTheme.backgroundColor
        tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        tableView.rowHeight = UITableView.automaticDimension
        tableView.contentInset = .init(top: -2, left: 0, bottom: UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0, right: 0)
        
        tableView.register(SearchHistoryTableHeaderView.self, forHeaderFooterViewReuseIdentifier: "Header")
        SimpleSearchTermTableViewCell.register(with: tableView)
        SimpleSearchTypeTableViewCell.register(with: tableView)
        SimpleSearchTermHistoryTableViewCell.register(with: tableView)
        SimpleSearchResultHistoryTableViewCell.register(with: tableView)
        SimpleTableViewCell.register(with: tableView)
    }
    
    private func loadSearchHistories() {
        let fetchRequest = NSFetchRequest<SearchHistory>(entityName: "SearchHistory")
        
        do {
            searchHistories = try managedContext.fetch(fetchRequest)
            searchHistories.reverse()
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
            simpleSearchResultVC.doNotRecordHistory = doNotRecordHistory

            if let _ = sender as? ImFeelingLuckyView {
                simpleSearchResultVC.isFeelingLucky = true
                
                Analytics.logEvent("feeling_lucky", parameters: nil)
            } else {
                simpleSearchResultVC.isFeelingLucky = false
            }

            Analytics.logEvent("perform_simple_search", parameters: ["search_type": currentSimpleSearchType.description, "search_term": searchTermTextField.text ?? ""])
            
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

// MARK: - UIScrollViewDelegate
extension SimpleSearchViewController {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 44 {
            searchTermTextField?.resignFirstResponder()
        }
    }
}

//MARK: - ImFeelingLuckyViewDelegate
extension SimpleSearchViewController: ImFeelingLuckyViewDelegate {
    func didTapImFeelingLuckyButton() {
        doNotRecordHistory = false
        performSegue(withIdentifier: "ShowSearchResult", sender: imFeelingLuckyView)
    }
}

//MARK: - HorizontalOptionsViewDelegate
extension SimpleSearchViewController: HorizontalOptionsViewDelegate {
    func horizontalOptionsView(_ horizontalOptionsView: HorizontalOptionsView, didSelectItemAt index: Int) {
        currentSimpleSearchType = SimpleSearchType(rawValue: index) ?? .bandName
        
        Analytics.logEvent("change_simple_search_type", parameters: ["search_type": currentSimpleSearchType.description])
    }
}

// MARK: - UITextFieldDelegate
extension SimpleSearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        doNotRecordHistory = false
        performSegue(withIdentifier: "ShowSearchResult", sender: searchTermTextField)
        return true
    }
}

// MARK: - UITableViewDelegate && Datasource
extension SimpleSearchViewController {
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 1
        } else {
            return 32
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "Header") as! SearchHistoryTableHeaderView
        
        headerView.didTapClearAll = { [unowned self] in
            SearchHistory.clearAll(withManagedContext: self.managedContext)
            self.searchHistories.removeAll()
            self.tableView.reloadData()
            
            Analytics.logEvent("clear_search_history", parameters: nil)
        }
        
        headerView.isClearAllLabelHidden = searchHistories.count == 0
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.section == 1, searchHistories.count > 0 else { return }
        
        let searchHistory = searchHistories[indexPath.row]
        
        defer {
            searchHistory.moveToTop(withManagedContext: managedContext)
        }
        
        if let term = searchHistory.term {
            searchTermTextField.text = term
            currentSimpleSearchType = SimpleSearchType(rawValue: Int(searchHistory.searchType)) ?? .bandName
            doNotRecordHistory = true
            
            Analytics.logEvent("select_search_history_term", parameters: ["term": term])
            
            performSegue(withIdentifier: "ShowSearchResult", sender: searchTermTextField)
        } else {
            let objectType = SearchResultObjectType(rawValue: Int(searchHistory.objectType)) ?? .band
            let urlString = searchHistory.urlString ?? ""
            switch objectType {
            case .band:
                Analytics.logEvent("select_search_history_band", parameters: ["band": searchHistory.nameOrTitle ?? ""])
                pushBandDetailViewController(urlString: urlString, animated: true)
                
            case .release:
                Analytics.logEvent("select_search_history_release", parameters: ["release": searchHistory.nameOrTitle ?? ""])
                pushReleaseDetailViewController(urlString: urlString, animated: true)
                
            case .artist:
                Analytics.logEvent("select_search_history_artist", parameters: ["artist": searchHistory.nameOrTitle ?? ""])
                pushArtistDetailViewController(urlString: urlString, animated: true)
                
            case .label:
                Analytics.logEvent("select_search_history_label", parameters: ["label": searchHistory.nameOrTitle ?? ""])
                pushLabelDetailViewController(urlString: urlString, animated: true)
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else {
            return max(1, searchHistories.count)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, 0): return searchTermTableViewCell(forRowAt: indexPath)
        case (0, 1): return searchTypeTableViewCell(forRowAt: indexPath)
        default: return searchHistoryCell(forRowAt: indexPath)
        }
    }
    
    private func searchTermTableViewCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SimpleSearchTermTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        searchTermTextField = cell.searchTermTextField
        searchTermTextField.delegate = self
        searchTermTextField.returnKeyType = .search
        searchTermTextField.inputAccessoryView = imFeelingLuckyView
        return cell
    }
    
    private func searchTypeTableViewCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SimpleSearchTypeTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        horizontalOptionsView = cell.horizontalOptionsView
        cell.horizontalOptionsView.delegate = self
        return cell
    }
    
    private func searchHistoryCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        guard searchHistories.count > 0 else {
            let cell = SimpleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            cell.displayAsItalicBodyText()
            cell.fill(with: "History is empty")
            return cell
        }
        
        let searchHistory = searchHistories[indexPath.row]
        
        if let _ = searchHistory.term {
            let cell = SimpleSearchTermHistoryTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            cell.fill(with: searchHistory)
            return cell
        } else {
            let cell = SimpleSearchResultHistoryTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            cell.fill(with: searchHistory)
            cell.didTapThumbnailImageView = { [unowned self] in
                if let thumgnailUrlString = searchHistory.thumbnailUrlString {
                    self.searchTermTextField?.resignFirstResponder()
                    self.presentPhotoViewerWithCacheChecking(photoUrlString: thumgnailUrlString, description: searchHistory.nameOrTitle!, fromImageView: cell.thumbnailImageView)
                }
            }
            return cell
        }
    }
}
