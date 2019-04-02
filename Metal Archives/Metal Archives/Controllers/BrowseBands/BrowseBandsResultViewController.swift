//
//  BandAphabeticallyResultViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 13/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Toaster
import FirebaseAnalytics

final class BrowseBandsResultViewController: RefreshableViewController {
    var parameter: String!
    var context: String!
    
    private var bandBrowsePagableManager: PagableManager<BandBrowse>!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bandBrowsePagableManager = PagableManager<BandBrowse>(options: ["<PARAMETER>": parameter])
        self.bandBrowsePagableManager.delegate = self
        self.bandBrowsePagableManager.fetch()
    }
    
    override func initAppearance() {
        super.initAppearance()
        LoadingTableViewCell.register(with: self.tableView)
        BrowseBandsResultTableViewCell.register(with: self.tableView)
    }
    
    private func updateTitle() {
        guard let totalRecords = self.bandBrowsePagableManager.totalRecords else {
            self.title = ""
            return
        }
        
        self.title = context + " (\(self.bandBrowsePagableManager.objects.count)/\(totalRecords))"
    }
    
    override func refresh() {
        self.bandBrowsePagableManager.reset()
        self.tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: {
            self.bandBrowsePagableManager.fetch()
        })
        
        Analytics.logEvent(AnalyticsEvent.RefreshBrowseBandsResults, parameters: nil)
    }
}

//MARK: - PagableManagerDelegate
extension BrowseBandsResultViewController: PagableManagerDelegate {
    func pagableManagerDidBeginFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        self.title = "Loading..."
    }
    
    func pagableManagerDidFailFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
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
extension BrowseBandsResultViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if self.bandBrowsePagableManager.objects.indices.contains(indexPath.row) {
            let band = self.bandBrowsePagableManager.objects[indexPath.row]
            self.pushBandDetailViewController(urlString: band.urlString, animated: true)
            
            Analytics.logEvent(AnalyticsEvent.SelectABrowseBandsResult, parameters: [AnalyticsParameter.BandName: band.name, AnalyticsParameter.BandID: band.id])
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.bandBrowsePagableManager.moreToLoad && indexPath.row == self.bandBrowsePagableManager.objects.count {
            self.bandBrowsePagableManager.fetch()
            
        } else if !self.bandBrowsePagableManager.moreToLoad && indexPath.row == self.bandBrowsePagableManager.objects.count - 1 {
            Toast.displayMessageShortly(endOfListMessage)
        }
    }
}

//MARK: - UITableViewDataSource
extension BrowseBandsResultViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let manager = self.bandBrowsePagableManager else {
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
        if self.bandBrowsePagableManager.moreToLoad && indexPath.row == self.bandBrowsePagableManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let cell = BrowseBandsResultTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let band = self.bandBrowsePagableManager.objects[indexPath.row]
        cell.fill(with: band)
        return cell
    }
}

