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
    @IBOutlet private weak var simpleNavigationBarView: SimpleNavigationBarView!
    
    private var newsArchivesPagableManager = PagableManager<News>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newsArchivesPagableManager.delegate = self
        newsArchivesPagableManager.fetch()
    }
 
    override func refresh() {
        newsArchivesPagableManager.reset()
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.newsArchivesPagableManager.fetch()
        }
    }

    override func initAppearance() {
        super.initAppearance()
        tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        tableView.contentInset = UIEdgeInsets(top: baseNavigationBarViewHeightWithoutTopInset, left: 0, bottom: UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0, right: 0)
        
        LoadingTableViewCell.register(with: tableView)
        NewsDetailTableViewCell.register(with: tableView)
        initSimpleNavigationBarView()
    }
    
    private func initSimpleNavigationBarView() {
        simpleNavigationBarView.setAlphaForBackgroundAndTitleLabel(1)
        simpleNavigationBarView.setTitle("News Archives")
        simpleNavigationBarView.setRightButtonIcon(nil)
        
        simpleNavigationBarView.didTapLeftButton = { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - PagableManagerProtocol
extension NewsArchiveViewController: PagableManagerDelegate {
    func pagableManagerDidBeginFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        showHUD()
    }
    
    func pagableManagerDidFailFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        hideHUD()
        endRefreshing()
        Toast.displayMessageShortly(errorLoadingMessage)
    }
    
    func pagableManagerDidFinishFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        hideHUD()
        refreshSuccessfully()
        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate
extension NewsArchiveViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if newsArchivesPagableManager.moreToLoad && indexPath.row == newsArchivesPagableManager.objects.count {
            //Loading cell
            return
        }
        
        let news = newsArchivesPagableManager.objects[indexPath.row]
        guard let url = URL(string: news.urlString) else { return }
        presentAlertOpenURLInBrowsers(url, alertTitle: "View this article in browser", alertMessage: news.title, shareMessage: "Share this article URL")
        
        Analytics.logEvent("select_an_item_in_news", parameters: nil)
    }
}

// MARK: - UITableViewDatasource
extension NewsArchiveViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if newsArchivesPagableManager.moreToLoad {
            if newsArchivesPagableManager.objects.count == 0 {
                return 0
            }
            
            return newsArchivesPagableManager.objects.count + 1
        } else {
            return newsArchivesPagableManager.objects.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if newsArchivesPagableManager.moreToLoad && indexPath.row == newsArchivesPagableManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let newsDetailCell = NewsDetailTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let news = newsArchivesPagableManager.objects[indexPath.row]
        newsDetailCell.fill(with: news)
        return newsDetailCell
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if newsArchivesPagableManager.moreToLoad && indexPath.row == newsArchivesPagableManager.objects.count {
            
            newsArchivesPagableManager.fetch()
            
        } else if !newsArchivesPagableManager.moreToLoad && indexPath.row == newsArchivesPagableManager.objects.count - 1 {
            Toast.displayMessageShortly(endOfListMessage)
        }
    }
}

// MARK: - UIScrollViewDelegate
extension NewsArchiveViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        simpleNavigationBarView.transformWith(scrollView)
    }
}
