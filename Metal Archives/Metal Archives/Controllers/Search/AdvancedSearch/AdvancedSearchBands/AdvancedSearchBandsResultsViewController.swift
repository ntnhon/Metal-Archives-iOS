//
//  AdvancedSearchBandsResultsViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 12/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Toaster
import FirebaseAnalytics

final class AdvancedSearchBandsResultsViewController: RefreshableViewController {
    var optionsList: String!
    private var bandAdvancedSearchResultPagableManager: PagableManager<AdvancedSearchResultBand>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initBandAdvancedSearchResultPagableManager()
        self.bandAdvancedSearchResultPagableManager.fetch()
    }

    override func initAppearance() {
        super.initAppearance()
        AdvancedBandNameTableViewCell.register(with: self.tableView)
        LoadingTableViewCell.register(with: self.tableView)
    }
    
    override func refresh() {
        self.bandAdvancedSearchResultPagableManager.reset()
        self.tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.bandAdvancedSearchResultPagableManager.fetch()
        }
        
        Analytics.logEvent(AnalyticsEvent.RefreshAdvancedSearchBandResults, parameters: nil)
    }
    
    func initBandAdvancedSearchResultPagableManager() {
        guard let formattedOptionsList = self.optionsList.addingPercentEncoding(withAllowedCharacters: customURLQueryAllowedCharacterSet) else {
            assertionFailure("Error adding percent encoding to option list.")
            return
        }
        
        self.bandAdvancedSearchResultPagableManager = PagableManager<AdvancedSearchResultBand>(options: ["<OPTIONS_LIST>": formattedOptionsList])
        self.bandAdvancedSearchResultPagableManager.delegate = self
    }
    
    private func updateTitle() {
        guard let totalRecords = self.bandAdvancedSearchResultPagableManager.totalRecords else {
            self.title = "No result found"
            return
        }
        
        if totalRecords == 0 {
            self.title = "No result found"
        } else if totalRecords == 1 {
            self.title = "Loaded \(self.bandAdvancedSearchResultPagableManager.objects.count) of \(totalRecords) result"
        } else {
            self.title = "Loaded \(self.bandAdvancedSearchResultPagableManager.objects.count) of \(totalRecords) results"
        }
    }
}

//MARK: - PagableManagerDelegate
extension AdvancedSearchBandsResultsViewController: PagableManagerDelegate {
    func pagableManagerDidBeginFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        self.title = "Loading..."
    }
    
    func pagableManagerDidFailFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        self.endRefreshing()
        Toast.displayMessageShortly(errorLoadingMessage)
    }
    
    func pagableManagerDidFinishFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        self.endRefreshing()
        self.updateTitle()
        self.tableView.reloadData()
        
        Analytics.logEvent(AnalyticsEvent.FetchMore, parameters: nil)
    }
    
    func pagableManagerIsBeingBlocked<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        Toast.displayBlockedMessageWithDelay()
    }
}

//MARK: - UITableViewDelegate
extension AdvancedSearchBandsResultsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let manager = self.bandAdvancedSearchResultPagableManager else {
            return
        }
        
        if manager.objects.indices.contains(indexPath.row) {
            let result = manager.objects[indexPath.row]
            self.pushBandDetailViewController(urlString: result.band.urlString, animated: true)
            
            Analytics.logEvent(AnalyticsEvent.SelectAnAdvancedSearchResult, parameters: [AnalyticsParameter.BandName: result.band.name, AnalyticsParameter.BandID: result.band.id])
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let _ = self.bandAdvancedSearchResultPagableManager.totalRecords else {
            return
        }
        
        if self.bandAdvancedSearchResultPagableManager.moreToLoad && indexPath.row == self.bandAdvancedSearchResultPagableManager.objects.count {
            self.bandAdvancedSearchResultPagableManager.fetch()
        } else if !self.bandAdvancedSearchResultPagableManager.moreToLoad && indexPath.row == self.bandAdvancedSearchResultPagableManager.objects.count - 1 {
            Toast.displayMessageShortly(endOfListMessage)
        }
    }
}

//MARK: - UITableViewDataSource
extension AdvancedSearchBandsResultsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let manager = self.bandAdvancedSearchResultPagableManager else {
            return 0
        }
        
        if self.refreshControl.isRefreshing {
            return 0
        }
        
        if manager.moreToLoad {
            return manager.objects.count + 1
        }
        
        return manager.objects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.bandAdvancedSearchResultPagableManager.moreToLoad && indexPath.row == self.bandAdvancedSearchResultPagableManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let cell = AdvancedBandNameTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let result = self.bandAdvancedSearchResultPagableManager.objects[indexPath.row]
        cell.fill(with: result)
        return cell
    }
}
