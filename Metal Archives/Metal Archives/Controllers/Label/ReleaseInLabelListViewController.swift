//
//  ReleaseInLabelListViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 25/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Toaster
import FirebaseAnalytics

final class ReleaseInLabelListViewController: RefreshableViewController {
    var releaseInLabelPagableManager: PagableManager<ReleaseInLabel>!
    var labelName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.releaseInLabelPagableManager.delegate = self
        self.updateTitle()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ToastCenter.default.cancelAll()
    }
    
    override func initAppearance() {
        super.initAppearance()
        
        ReleaseInLabelTableViewCell.register(with: self.tableView)
        LoadingTableViewCell.register(with: self.tableView)
    }
    
    override func refresh() {
        self.title = ""
        self.releaseInLabelPagableManager.reset()
        self.tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.releaseInLabelPagableManager.fetch()
        }
        
        Analytics.logEvent(AnalyticsEvent.RefreshReleasesInLabelList, parameters: nil)
    }
    
    private func updateTitle() {
        guard let totalRecords = self.releaseInLabelPagableManager.totalRecords else {
            return
        }
        self.title = "\(self.labelName!)'s Releases (\(self.releaseInLabelPagableManager.objects.count)/\(totalRecords))"
    }
}

//MARK: - PagableManagerProtocol
extension ReleaseInLabelListViewController: PagableManagerDelegate {
    func pagableManagerDidFailFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        self.endRefreshing()
        Toast.displayMessageShortly(errorLoadingMessage)
    }
    
    func pagableManagerDidFinishFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        self.refreshSuccessfully()
        self.updateTitle()
        self.tableView.reloadData()
        
        Analytics.logEvent(AnalyticsEvent.FetchMore, parameters: nil)
    }
    
    func pagableManagerIsBeingBlocked<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        Toast.displayBlockedMessageWithDelay()
    }
}

//MARK: - UITableViewDelegate
extension ReleaseInLabelListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let release = self.releaseInLabelPagableManager.objects[indexPath.row]
        self.takeActionFor(actionableObject: release)
        
        Analytics.logEvent(AnalyticsEvent.ViewLabelRelease, parameters: nil)
    }
}

//MARK: - UITableViewDataSource
extension ReleaseInLabelListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.refreshControl.isRefreshing {
            return 0
        }
        
        if self.releaseInLabelPagableManager.moreToLoad {
            return self.releaseInLabelPagableManager.objects.count + 1
        }
        
        return self.releaseInLabelPagableManager.objects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.releaseInLabelPagableManager.moreToLoad && indexPath.row == self.releaseInLabelPagableManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let cell = ReleaseInLabelTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let release = self.releaseInLabelPagableManager.objects[indexPath.row]
        cell.fill(with: release)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.releaseInLabelPagableManager.moreToLoad && indexPath.row == self.releaseInLabelPagableManager.objects.count {
            self.releaseInLabelPagableManager.fetch()
        } else if !self.releaseInLabelPagableManager.moreToLoad && indexPath.row == self.releaseInLabelPagableManager.objects.count - 1 {
            Toast.displayMessageShortly(endOfListMessage)
        }
    }
}
