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
    
    @IBOutlet private weak var latestReviewsNavigationBarView: LatestReviewsNavigationBarView!

    private var selectedMonth: MonthInYear = monthList[0] {
        didSet {
            latestReviewsNavigationBarView.setMonthButtonTitle(selectedMonth.shortDisplayString)
            updateLatestReviewsPagableManager()
            refresh()
        }
    }
    
    private var latestReviewsPagableManager = PagableManager<LatestReview>(options: ["<YEAR_MONTH>": monthList[0].requestParameterString])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleLatestReviewsNavigationBarViewActions()
        updateLatestReviewsPagableManager()
        latestReviewsPagableManager.fetch()
    }
    
    override func initAppearance() {
        super.initAppearance()
        tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        tableView.contentInset = UIEdgeInsets(top: baseNavigationBarViewHeightWithoutTopInset, left: 0, bottom: UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0, right: 0)
        
        LoadingTableViewCell.register(with: tableView)
        LatestReviewTableViewCell.register(with: tableView)
    }
    
    override func refresh() {
        latestReviewsPagableManager.reset()
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.latestReviewsPagableManager.fetch()
        }
        
        Analytics.logEvent("refresh_latest_reviews", parameters: nil)
    }
    
    private func updateLatestReviewsPagableManager() {
        latestReviewsPagableManager = PagableManager<LatestReview>(options: ["<YEAR_MONTH>": selectedMonth.requestParameterString])
        latestReviewsPagableManager.delegate = self
    }
    
    private func handleLatestReviewsNavigationBarViewActions() {
        let thisMonthString = monthList[0].shortDisplayString
        latestReviewsNavigationBarView.setMonthButtonTitle(thisMonthString)
        
        latestReviewsNavigationBarView.didTapBackButton = { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
        
        latestReviewsNavigationBarView.didTapMonthButton = { [unowned self] in
            let monthListViewController = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "MonthListViewController") as! MonthListViewController
            
            monthListViewController.modalPresentationStyle = .popover
            monthListViewController.popoverPresentationController?.permittedArrowDirections = .any
            monthListViewController.preferredContentSize = CGSize(width: 220, height: screenHeight*2/3)
            
            monthListViewController.popoverPresentationController?.delegate = self
            monthListViewController.popoverPresentationController?.sourceView = self.latestReviewsNavigationBarView.monthButton
            
            monthListViewController.delegate = self
            monthListViewController.selectedMonth = self.selectedMonth
            self.present(monthListViewController, animated: true, completion: nil)
        }
    }
    
    private func updateTitle() {
        guard let totalRecords = latestReviewsPagableManager.totalRecords else {
            return
        }
        
        latestReviewsNavigationBarView.setTitle("Loaded \(latestReviewsPagableManager.objects.count) of \(totalRecords)")
    }
}

//MARK: - PagableManagerProtocol
extension LatestReviewsViewController: PagableManagerDelegate {
    func pagableManagerDidBeginFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        latestReviewsNavigationBarView.setTitle("Loading...")
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
        updateTitle()
        tableView.reloadData()
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
        selectedMonth = month
        
        Analytics.logEvent("change_month_in_latest_reviews", parameters: ["month": month.shortDisplayString])
    }
}

// MARK: - UIScrollViewDelegate
extension LatestReviewsViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        latestReviewsNavigationBarView.transformWith(scrollView)
    }
}

//MARK: - UITableViewDelegate
extension LatestReviewsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if latestReviewsPagableManager.moreToLoad && indexPath.row == latestReviewsPagableManager.objects.count {
            //Loading cell
            return
        }
        
        let latestReview = latestReviewsPagableManager.objects[indexPath.row]
        takeActionFor(actionableObject: latestReview)
        
        Analytics.logEvent("select_an_item_in_latest_reviews", parameters: ["latest_review": latestReview.reviewURLString])
    }
}

//MARK: - UITableViewDataSource
extension LatestReviewsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if latestReviewsPagableManager.moreToLoad {
            if latestReviewsPagableManager.objects.count == 0 {
                return 0
            }
            return latestReviewsPagableManager.objects.count + 1
        } else {
            return latestReviewsPagableManager.objects.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if latestReviewsPagableManager.moreToLoad && indexPath.row == latestReviewsPagableManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let cell = LatestReviewTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let latestReview = latestReviewsPagableManager.objects[indexPath.row]
        cell.fill(with: latestReview)
        
        cell.tappedThumbnailImageView = { [unowned self] in
            self.presentPhotoViewerWithCacheChecking(photoUrlString: latestReview.release.imageURLString, description: latestReview.release.title, fromImageView: cell.thumbnailImageView)
            
            Analytics.logEvent("view_latest_review_thumbnail", parameters: ["latest_review": latestReview.reviewURLString])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if latestReviewsPagableManager.moreToLoad && indexPath.row == latestReviewsPagableManager.objects.count {
            
            latestReviewsPagableManager.fetch()
        } else if !latestReviewsPagableManager.moreToLoad && indexPath.row == latestReviewsPagableManager.objects.count - 1 {
            Toast.displayMessageShortly(endOfListMessage)
        }
    }
}
