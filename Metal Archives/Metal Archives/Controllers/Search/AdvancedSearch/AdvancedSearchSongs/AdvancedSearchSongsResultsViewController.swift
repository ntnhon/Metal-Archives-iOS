//
//  AdvancedSearchSongsResultsViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 13/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Toaster
import FirebaseAnalytics

final class AdvancedSearchSongsResultsViewController: RefreshableViewController {
    var optionsList: String!
    private var songAdvancedSearchResultPagableManager: PagableManager<AdvancedSearchResultSong>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initSongAdvancedSearchResultPagableManager()
        self.songAdvancedSearchResultPagableManager.fetch()
    }
    
    override func initAppearance() {
        super.initAppearance()
        AdvancedSongTableViewCell.register(with: self.tableView)
        LoadingTableViewCell.register(with: self.tableView)
    }
    
    override func refresh() {
        self.songAdvancedSearchResultPagableManager.reset()
        self.tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.songAdvancedSearchResultPagableManager.fetch()
        }
        
        Analytics.logEvent(AnalyticsEvent.RefreshAdvancedSearchSongResults, parameters: nil)
    }
    
    func initSongAdvancedSearchResultPagableManager() {
        guard let formattedOptionsList = self.optionsList.addingPercentEncoding(withAllowedCharacters: customURLQueryAllowedCharacterSet) else {
            assertionFailure("Error adding percent encoding to option list.")
            return
        }
        
        self.songAdvancedSearchResultPagableManager = PagableManager<AdvancedSearchResultSong>(options: ["<OPTIONS_LIST>": formattedOptionsList])
        self.songAdvancedSearchResultPagableManager.delegate = self
    }
    
    private func updateTitle() {
        guard let totalRecords = self.songAdvancedSearchResultPagableManager.totalRecords else {
            self.title = "No result found"
            return
        }
        
        if totalRecords == 0 {
            self.title = "No result found"
        } else if totalRecords == 1 {
            self.title = "Loaded \(self.songAdvancedSearchResultPagableManager.objects.count) of \(totalRecords) result"
        } else {
            self.title = "Loaded \(self.songAdvancedSearchResultPagableManager.objects.count) of \(totalRecords) results"
        }
    }
}

//MARK: - PagableManagerDelegate
extension AdvancedSearchSongsResultsViewController: PagableManagerDelegate {
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
extension AdvancedSearchSongsResultsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let manager = self.songAdvancedSearchResultPagableManager else {
            return
        }
        
        if manager.objects.indices.contains(indexPath.row) {
            let result = manager.objects[indexPath.row]
            self.takeActionFor(actionableObject: result)
            
            Analytics.logEvent(AnalyticsEvent.SelectAnAdvancedSearchResult, parameters: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let _ = self.songAdvancedSearchResultPagableManager.totalRecords else {
            return
        }
        
        if self.songAdvancedSearchResultPagableManager.moreToLoad && indexPath.row == self.songAdvancedSearchResultPagableManager.objects.count {
            self.songAdvancedSearchResultPagableManager.fetch()
        } else if !self.songAdvancedSearchResultPagableManager.moreToLoad && indexPath.row == self.songAdvancedSearchResultPagableManager.objects.count - 1 {
            Toast.displayMessageShortly(endOfListMessage)
        }
    }
}

//MARK: - UITableViewDataSource
extension AdvancedSearchSongsResultsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let manager = self.songAdvancedSearchResultPagableManager else {
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
        if self.songAdvancedSearchResultPagableManager.moreToLoad && indexPath.row == self.songAdvancedSearchResultPagableManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let cell = AdvancedSongTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let result = self.songAdvancedSearchResultPagableManager.objects[indexPath.row]
        cell.fill(with: result)
        return cell
    }
}

