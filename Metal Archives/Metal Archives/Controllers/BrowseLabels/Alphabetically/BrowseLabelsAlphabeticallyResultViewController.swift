//
//  BrowseLabelsAlphabeticallyResultViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Toaster
import FirebaseAnalytics

final class BrowseLabelsAlphabeticallyResultViewController: RefreshableViewController {
    var letter: Letter!
    
    private var browseLabelsAlphabeticallyPagableManager: PagableManager<LabelBrowseAlphabetically>!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initPagableManager()
        self.browseLabelsAlphabeticallyPagableManager.fetch()
    }
    
    override func initAppearance() {
        super.initAppearance()
        LoadingTableViewCell.register(with: self.tableView)
        BrowseLabelsAlphabeticallyResultTableViewCell.register(with: self.tableView)
    }
    
    private func initPagableManager() {
        self.browseLabelsAlphabeticallyPagableManager = PagableManager<LabelBrowseAlphabetically>(options: ["<LETTER>": self.letter.parameterString])
        self.browseLabelsAlphabeticallyPagableManager.delegate = self
    }
    
    private func updateTitle() {
        guard let totalRecords = self.browseLabelsAlphabeticallyPagableManager.totalRecords else {
            self.title = "No result found"
            return
        }
        
        self.title = "Loaded \(self.browseLabelsAlphabeticallyPagableManager.objects.count) of \(totalRecords)"
    }
    
    override func refresh() {
        self.browseLabelsAlphabeticallyPagableManager.reset()
        self.tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.browseLabelsAlphabeticallyPagableManager.fetch()
        }
        
        Analytics.logEvent(AnalyticsEvent.RefreshBrowseLabelsAlphabeticallyResults, parameters: nil)
    }
}

//MARK: - PagableManagerDelegate
extension BrowseLabelsAlphabeticallyResultViewController: PagableManagerDelegate {
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
extension BrowseLabelsAlphabeticallyResultViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard self.browseLabelsAlphabeticallyPagableManager.objects.indices.contains(indexPath.row) else {
            return
            
        }
        
        let label = self.browseLabelsAlphabeticallyPagableManager.objects[indexPath.row]
        
        if let _ = label.websiteURLString {
            self.takeActionFor(actionableObject: label)
        } else {
            self.pushLabelDetailViewController(urlString: label.urlString, animated: true)
        }
        
        Analytics.logEvent(AnalyticsEvent.SelectABrowseLabelsResult, parameters: [AnalyticsParameter.LabelName: label.name, AnalyticsParameter.LabelID: label.id])
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.browseLabelsAlphabeticallyPagableManager.moreToLoad && indexPath.row == self.browseLabelsAlphabeticallyPagableManager.objects.count {
            self.browseLabelsAlphabeticallyPagableManager.fetch()
            
        } else if !self.browseLabelsAlphabeticallyPagableManager.moreToLoad && indexPath.row == self.browseLabelsAlphabeticallyPagableManager.objects.count - 1 {
            Toast.displayMessageShortly(endOfListMessage)
        }
    }
}

//MARK: - UITableViewDataSource
extension BrowseLabelsAlphabeticallyResultViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let manager = self.browseLabelsAlphabeticallyPagableManager else {
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
        if self.browseLabelsAlphabeticallyPagableManager.moreToLoad && indexPath.row == self.browseLabelsAlphabeticallyPagableManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let cell = BrowseLabelsAlphabeticallyResultTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let label = self.browseLabelsAlphabeticallyPagableManager.objects[indexPath.row]
        cell.fill(with: label)
        return cell
    }
}
