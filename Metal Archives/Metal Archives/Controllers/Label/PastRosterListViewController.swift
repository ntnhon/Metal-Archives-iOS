//
//  PastRosterListViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 25/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Toaster
import FirebaseAnalytics

final class PastRosterListViewController: RefreshableViewController {
    var pastRosterPagableManager: PagableManager<BandPastRoster>!
    var labelName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateTitle()
        self.pastRosterPagableManager.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ToastCenter.default.cancelAll()
    }
    
    override func initAppearance() {
        super.initAppearance()
        
        BandPastRosterTableViewCell.register(with: self.tableView)
        LoadingTableViewCell.register(with: self.tableView)
    }
    
    override func refresh() {
        self.title = ""
        self.pastRosterPagableManager.reset()
        self.tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.pastRosterPagableManager.fetch()
        }
        
        Analytics.logEvent(AnalyticsEvent.RefreshPastRoster, parameters: nil)
    }

    private func updateTitle() {
        guard let totalRecords = self.pastRosterPagableManager.totalRecords else {
            return
        }
        
        self.title = "\(self.labelName!)'s Past Roster (\(self.pastRosterPagableManager.objects.count)/\(totalRecords))"
    }
}

//
extension PastRosterListViewController: PagableManagerDelegate {
    func pagableManagerIsBeingBlocked<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        self.endRefreshing()
        Toast.displayBlockedMessageWithDelay()
    }
    
    func pagableManagerDidFailFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        self.endRefreshing()
        Toast.displayMessageShortly(errorLoadingMessage)
    }
    
    func pagableManagerDidFinishFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        self.updateTitle()
        self.refreshSuccessfully()
        self.tableView.reloadData()
        
        Analytics.logEvent(AnalyticsEvent.FetchMore, parameters: nil)
    }
}

//MARK: - UITableViewDelegate
extension PastRosterListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let band = self.pastRosterPagableManager.objects[indexPath.row]
        self.pushBandDetailViewController(urlString: band.urlString, animated: true)
        
        Analytics.logEvent(AnalyticsEvent.ViewLabelPastRoster, parameters: nil)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.pastRosterPagableManager.moreToLoad && indexPath.row == self.pastRosterPagableManager.objects.count {
            self.pastRosterPagableManager.fetch()
        } else if !self.pastRosterPagableManager.moreToLoad && indexPath.row == self.pastRosterPagableManager.objects.count - 1 {
            Toast.displayMessageShortly(endOfListMessage)
        }
    }
}

//MARK: - UITableViewDataSource
extension PastRosterListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.refreshControl.isRefreshing {
            return 0
        }
        
        if self.pastRosterPagableManager.moreToLoad {
            return self.pastRosterPagableManager.objects.count + 1
        }
        
        return self.pastRosterPagableManager.objects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.pastRosterPagableManager.moreToLoad && indexPath.row == self.pastRosterPagableManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let cell = BandPastRosterTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let band = self.pastRosterPagableManager.objects[indexPath.row]
        cell.fill(with: band)
        return cell
    }
}
