//
//  BrowseLabelsByCountryResultViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 20/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Toaster
import FirebaseAnalytics

final class BrowseLabelsByCountryResultViewController: RefreshableViewController {
    var country: Country?
    
    private var browseLabelsByCountryPagableManager: PagableManager<LabelBrowseByCountry>!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Browse Labels - By Country"
        self.initPagableManager()
        self.browseLabelsByCountryPagableManager.fetch()
    }
    
    override func initAppearance() {
        super.initAppearance()
        LoadingTableViewCell.register(with: self.tableView)
        BrowseLabelsByCountryResultTableViewCell.register(with: self.tableView)
    }
    
    private func initPagableManager() {
        if let country = self.country {
            self.browseLabelsByCountryPagableManager = PagableManager<LabelBrowseByCountry>(options: ["<COUNTRY>": country.iso])
        } else {
            self.browseLabelsByCountryPagableManager = PagableManager<LabelBrowseByCountry>(options: ["<COUNTRY>": "0"])
        }
        
        self.browseLabelsByCountryPagableManager.delegate = self
    }
    
    private func updateTitle() {
        guard let totalRecords = self.browseLabelsByCountryPagableManager.totalRecords else {
            self.title = "No result found"
            return
        }
        
        self.title = "Loaded \(self.browseLabelsByCountryPagableManager.objects.count) of \(totalRecords)"
    }
    
    override func refresh() {
        self.browseLabelsByCountryPagableManager.reset()
        self.tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.browseLabelsByCountryPagableManager.fetch()
        }
        
        Analytics.logEvent(AnalyticsEvent.RefreshBrowseLabelsByCountryResults, parameters: nil)
    }
}

//MARK: - PagableManagerDelegate
extension BrowseLabelsByCountryResultViewController: PagableManagerDelegate {
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
extension BrowseLabelsByCountryResultViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard self.browseLabelsByCountryPagableManager.objects.indices.contains(indexPath.row) else {
            return
            
        }
        
        let label = self.browseLabelsByCountryPagableManager.objects[indexPath.row]
        
        if let _ = label.websiteURLString {
            self.takeActionFor(actionableObject: label)
        } else {
            self.pushLabelDetailViewController(urlString: label.urlString, animated: true)
        }
        
        Analytics.logEvent(AnalyticsEvent.SelectABrowseLabelsResult, parameters: [AnalyticsParameter.LabelName: label.name, AnalyticsParameter.LabelID: label.id])
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.browseLabelsByCountryPagableManager.moreToLoad && indexPath.row == self.browseLabelsByCountryPagableManager.objects.count {
            self.browseLabelsByCountryPagableManager.fetch()
            
        } else if !self.browseLabelsByCountryPagableManager.moreToLoad && indexPath.row == self.browseLabelsByCountryPagableManager.objects.count - 1 {
            Toast.displayMessageShortly(endOfListMessage)
        }
    }
}

//MARK: - UITableViewDataSource
extension BrowseLabelsByCountryResultViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let manager = self.browseLabelsByCountryPagableManager else {
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
        if self.browseLabelsByCountryPagableManager.moreToLoad && indexPath.row == self.browseLabelsByCountryPagableManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let cell = BrowseLabelsByCountryResultTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let label = self.browseLabelsByCountryPagableManager.objects[indexPath.row]
        cell.fill(with: label)
        return cell
    }
}
