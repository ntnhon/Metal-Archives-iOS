//
//  CurrentRosterListViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 25/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Toaster
import FirebaseAnalytics

enum CurrentRosterListViewControllerType {
    case current, lastKnown
}

final class CurrentRosterListViewController: RefreshableViewController {
    
    var type: CurrentRosterListViewControllerType = .current
    var currentRosterPagableManager: PagableManager<BandCurrentRoster>!
    var labelName: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.currentRosterPagableManager.delegate = self
        self.updateTitle()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ToastCenter.default.cancelAll()
    }
    
    override func initAppearance() {
        super.initAppearance()
        BandCurrentRosterTableViewCell.register(with: self.tableView)
        LoadingTableViewCell.register(with: self.tableView)
    }
    
    override func refresh() {
        self.title = ""
        self.currentRosterPagableManager.reset()
        self.tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.currentRosterPagableManager.fetch()
        }
        
        Analytics.logEvent(AnalyticsEvent.RefreshCurrentRoster, parameters: nil)
    }
    
    private func updateTitle() {
        guard let totalRecords = self.currentRosterPagableManager.totalRecords else {
            self.title = ""
            return
        }
        
        switch self.type {
        case .current:
            self.title = "\(self.labelName!)'s Current Roster (\(self.currentRosterPagableManager.objects.count)/\(totalRecords))"
            
        case .lastKnown:
            self.title = "\(self.labelName!)'s Last Known Roster (\(self.currentRosterPagableManager.objects.count)/\(totalRecords))"
        }
    }
}

//MARK: - PagableManagerProtocol
extension CurrentRosterListViewController: PagableManagerDelegate {
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
extension CurrentRosterListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let band = self.currentRosterPagableManager.objects[indexPath.row]
        self.pushBandDetailViewController(urlString: band.urlString, animated: true)
        
        Analytics.logEvent(AnalyticsEvent.ViewLabelCurrentRoster, parameters: nil)
    }
}

//MARK: - UITableViewDataSource
extension CurrentRosterListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.refreshControl.isRefreshing {
            return 0
        }
        
        if self.currentRosterPagableManager.moreToLoad {
            return self.currentRosterPagableManager.objects.count + 1
        }
        
        return self.currentRosterPagableManager.objects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.currentRosterPagableManager.moreToLoad && indexPath.row == self.currentRosterPagableManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let cell = BandCurrentRosterTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let band = self.currentRosterPagableManager.objects[indexPath.row]
        cell.fill(with: band)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.currentRosterPagableManager.moreToLoad && indexPath.row == self.currentRosterPagableManager.objects.count {
            self.currentRosterPagableManager.fetch()
        } else if !self.currentRosterPagableManager.moreToLoad && indexPath.row == self.currentRosterPagableManager.objects.count - 1 {
            Toast.displayMessageShortly(endOfListMessage)
        }
    }
}
