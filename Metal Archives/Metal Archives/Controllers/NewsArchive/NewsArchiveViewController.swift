//
//  NewsArchiveViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Toaster
import FirebaseAnalytics

final class NewsArchiveViewController: RefreshableViewController {
    private var errorFetchingMoreNews = false
    private var isFetching = false
    
    private var newsArchivesPagableManager = PagableManager<News>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.newsArchivesPagableManager.delegate = self
        self.newsArchivesPagableManager.fetch()
    }
    
    override func refresh() {
        self.newsArchivesPagableManager.reset()
        self.tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.newsArchivesPagableManager.fetch()
        }
    }

    override func initAppearance() {
        super.initAppearance()
        LoadingTableViewCell.register(with: self.tableView)
        NewsDetailTableViewCell.register(with: self.tableView)
        
        self.title = "News Archive"
    }
}

//MARK: - PagableManagerProtocol
extension NewsArchiveViewController: PagableManagerDelegate {
    func pagableManagerDidFailFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        self.endRefreshing()
        Toast.displayMessageShortly(errorLoadingMessage)
    }
    
    func pagableManagerDidFinishFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        self.refreshSuccessfully()
        self.tableView.reloadData()
    }
    
    func pagableManagerIsBeingBlocked<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        Toast.displayBlockedMessageWithDelay()
    }
}

//MARK: - UITableViewDelegate
extension NewsArchiveViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if self.newsArchivesPagableManager.moreToLoad && indexPath.row == self.newsArchivesPagableManager.objects.count {
            //Loading cell
            return
        }
        
        let news = self.newsArchivesPagableManager.objects[indexPath.row]
        guard let url = URL(string: news.urlString) else { return }
        self.presentAlertOpenURLInBrowsers(url, alertTitle: "View this article in browser", alertMessage: news.title, shareMessage: "Share this article URL")
        
        Analytics.logEvent(AnalyticsEvent.SelectAnItemInNews, parameters: nil)
    }
}

//MARK: - UITableViewDatasource
extension NewsArchiveViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.refreshControl.isRefreshing {
            return 0
        }
        
        if self.newsArchivesPagableManager.moreToLoad {
            return self.newsArchivesPagableManager.objects.count + 1
        } else {
            return self.newsArchivesPagableManager.objects.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.newsArchivesPagableManager.moreToLoad && indexPath.row == self.newsArchivesPagableManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)

            //Fetch is on the way
            if !self.errorFetchingMoreNews {
                loadingCell.displayIsLoading()
                return loadingCell
            }
            
            //Fetch failed
            loadingCell.didsplayError("Error loading more news.\n Tap to reload.")
            return loadingCell
        }
        
        let newsDetailCell = NewsDetailTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let news = self.newsArchivesPagableManager.objects[indexPath.row]
        newsDetailCell.fill(with: news)
        return newsDetailCell
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if self.newsArchivesPagableManager.moreToLoad && indexPath.row == self.newsArchivesPagableManager.objects.count {
            
            self.newsArchivesPagableManager.fetch()
            
        } else if !self.newsArchivesPagableManager.moreToLoad && indexPath.row == self.newsArchivesPagableManager.objects.count - 1 {
            Toast.displayMessageShortly(endOfListMessage)
        }
    }
}
