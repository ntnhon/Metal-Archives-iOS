//
//  LatestReviewsViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 23/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Toaster
import FirebaseAnalytics

final class LatestReviewsViewController: RefreshableViewController {
    private var errorFetchingMoreUpcomingAlbums = false
    private var isFetching = false
    
    private var rightBarButtonItem: UIBarButtonItem!
    
    private var selectedMonth: MonthInYear = monthList[0] {
        didSet {
            self.rightBarButtonItem.title = selectedMonth.shortDisplayString
            self.updateLatestReviewsPagableManager()
            self.refresh()
        }
    }
    
    private var latestReviewsPagableManager = PagableManager<LatestReview>(options: ["<YEAR_MONTH>": monthList[0].requestParameterString])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initRightBarButtonItem()
        self.updateLatestReviewsPagableManager()
    }
    
    override func initAppearance() {
        super.initAppearance()
        LoadingTableViewCell.register(with: self.tableView)
        LatestReviewTableViewCell.register(with: self.tableView)
    }
    
    override func refresh() {
        self.latestReviewsPagableManager.reset()
        self.tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.latestReviewsPagableManager.fetch()
        }
        
        Analytics.logEvent(AnalyticsEvent.RefreshLatestReviews, parameters: nil)
    }
    
    private func updateLatestReviewsPagableManager() {
        self.latestReviewsPagableManager = PagableManager<LatestReview>(options: ["<YEAR_MONTH>": self.selectedMonth.requestParameterString])
        self.latestReviewsPagableManager.delegate = self
    }
    
    private func initRightBarButtonItem() {
        let thisMonthString = monthList[0].shortDisplayString
        self.rightBarButtonItem = UIBarButtonItem(title: thisMonthString, style: .done, target: self, action: #selector(didTapRightBarButtonItem))
        self.navigationItem.rightBarButtonItem = self.rightBarButtonItem
    }
    
    @objc private func didTapRightBarButtonItem() {
        let monthListViewController = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "MonthListViewController") as! MonthListViewController
        
        monthListViewController.modalPresentationStyle = .popover
        monthListViewController.popoverPresentationController?.permittedArrowDirections = .any
        monthListViewController.preferredContentSize = CGSize(width: 220, height: screenHeight*2/3)
        
        monthListViewController.popoverPresentationController?.delegate = self
        monthListViewController.popoverPresentationController?.barButtonItem = self.rightBarButtonItem
        
        monthListViewController.delegate = self
        monthListViewController.selectedMonth = self.selectedMonth
        self.present(monthListViewController, animated: true, completion: nil)
    }
    
    private func updateTitle() {
        guard let totalRecords = self.latestReviewsPagableManager.totalRecords else {
            return
        }
        
        self.title = "Loaded \(self.latestReviewsPagableManager.objects.count) of \(totalRecords)"
    }
}

//MARK: - PagableManagerProtocol
extension LatestReviewsViewController: PagableManagerDelegate {
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

//MARK: - UIPopoverPresentationControllerDelegate
extension LatestReviewsViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

//MARK: - MonthListViewControllerDelegate
extension LatestReviewsViewController: MonthListViewControllerDelegate {
    func didSelectAMonth(_ month: MonthInYear) {
        self.selectedMonth = month
        
        Analytics.logEvent(AnalyticsEvent.ChangeMonthInLatestReviews, parameters: [AnalyticsParameter.Month: self.selectedMonth.shortDisplayString])
    }
}

//MARK: - UITableViewDelegate
extension LatestReviewsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if self.latestReviewsPagableManager.moreToLoad && indexPath.row == self.latestReviewsPagableManager.objects.count {
            //Loading cell
            return
        }
        
        let latestReview = self.latestReviewsPagableManager.objects[indexPath.row]
        self.takeActionFor(actionableObject: latestReview)
        
        Analytics.logEvent(AnalyticsEvent.SelectAnItemInLatestReviews, parameters: nil)
    }
}

//MARK: - UITableViewDataSource
extension LatestReviewsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.refreshControl.isRefreshing {
            return 0
        }
        
        if self.latestReviewsPagableManager.moreToLoad {
            return self.latestReviewsPagableManager.objects.count + 1
        } else {
            return self.latestReviewsPagableManager.objects.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.latestReviewsPagableManager.moreToLoad && indexPath.row == self.latestReviewsPagableManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)

            //Fetch is on the way
            if !self.errorFetchingMoreUpcomingAlbums {
                loadingCell.displayIsLoading()
                return loadingCell
            }
            
            //Fetch failed
            loadingCell.didsplayError("Error loading more upcoming albums.\n Tap to reload.")
            return loadingCell
        }
        
        let cell = LatestReviewTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let latestReview = self.latestReviewsPagableManager.objects[indexPath.row]
        cell.fill(with: latestReview)
        
        cell.tappedThumbnailImageView = { [unowned self] in
            self.presentPhotoViewerWithCacheChecking(photoUrlString: latestReview.release.imageURLString, description: latestReview.release.title, fromImageView: cell.thumbnailImageView)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if self.latestReviewsPagableManager.moreToLoad && indexPath.row == self.latestReviewsPagableManager.objects.count {
            
            self.latestReviewsPagableManager.fetch()
        } else if !self.latestReviewsPagableManager.moreToLoad && indexPath.row == self.latestReviewsPagableManager.objects.count - 1 {
            Toast.displayMessageShortly(endOfListMessage)
        }
    }
}
