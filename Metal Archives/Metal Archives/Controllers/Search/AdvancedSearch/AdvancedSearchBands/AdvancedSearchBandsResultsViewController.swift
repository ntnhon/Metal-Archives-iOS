//
//  AdvancedSearchBandsResultsViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 12/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Toaster
import FirebaseAnalytics

final class AdvancedSearchBandsResultsViewController: RefreshableViewController {
    var optionsList: String!
    private var bandAdvancedSearchResultPagableManager: PagableManager<AdvancedSearchResultBand>!
    
    weak var simpleNavigationBarView: SimpleNavigationBarView?
    deinit {
        print("AdvancedSearchBandsResultsViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initBandAdvancedSearchResultPagableManager()
        bandAdvancedSearchResultPagableManager.fetch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        simpleNavigationBarView?.setRightButtonIcon(nil)
        simpleNavigationBarView?.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        simpleNavigationBarView?.isHidden = !isMovingToParent
    }

    override func initAppearance() {
        super.initAppearance()
        tableView.contentInset = UIEdgeInsets(top: baseNavigationBarViewHeightWithoutTopInset, left: 0, bottom: UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0, right: 0)
        AdvancedBandNameTableViewCell.register(with: tableView)
        LoadingTableViewCell.register(with: tableView)
    }
    
    override func refresh() {
        bandAdvancedSearchResultPagableManager.reset()
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.bandAdvancedSearchResultPagableManager.fetch()
        }
        
        Analytics.logEvent("refresh_advanced_search_band_results", parameters: nil)
    }
    
    func initBandAdvancedSearchResultPagableManager() {
        guard var formattedOptionsList = optionsList.addingPercentEncoding(withAllowedCharacters: customURLQueryAllowedCharacterSet) else {
            assertionFailure("Error adding percent encoding to option list.")
            return
        }
        
        // encode space by + instead of %20
        formattedOptionsList = formattedOptionsList.replacingOccurrences(of: "%20", with: "+")
        
        bandAdvancedSearchResultPagableManager = PagableManager<AdvancedSearchResultBand>(options: ["<OPTIONS_LIST>": formattedOptionsList])
        bandAdvancedSearchResultPagableManager.delegate = self
    }
    
    private func updateTitle() {
        guard let totalRecords = bandAdvancedSearchResultPagableManager.totalRecords else {
            simpleNavigationBarView?.setTitle("No result found")
            return
        }
        
        if totalRecords == 0 {
            simpleNavigationBarView?.setTitle("No result found")
        } else if totalRecords == 1 {
            simpleNavigationBarView?.setTitle("Loaded \(bandAdvancedSearchResultPagableManager.objects.count) of \(totalRecords) result")
        } else {
            simpleNavigationBarView?.setTitle("Loaded \(bandAdvancedSearchResultPagableManager.objects.count) of \(totalRecords) results")
        }
    }
}

//MARK: - PagableManagerDelegate
extension AdvancedSearchBandsResultsViewController: PagableManagerDelegate {
    func pagableManagerDidBeginFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        simpleNavigationBarView?.setTitle("Loading...")
        showHUD()
    }
    
    func pagableManagerDidFailFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        hideHUD()
        endRefreshing()
        Toast.displayMessageShortly(errorLoadingMessage)
    }
    
    func pagableManagerDidFinishFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        hideHUD()
        endRefreshing()
        updateTitle()
        tableView.reloadData()
    }
    
    func pagableManagerIsBeingBlocked<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        Toast.displayBlockedMessageWithDelay()
    }
}

//MARK: - UITableViewDelegate
extension AdvancedSearchBandsResultsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let manager = bandAdvancedSearchResultPagableManager else {
            return
        }
        
        if manager.objects.indices.contains(indexPath.row) {
            let result = manager.objects[indexPath.row]
            pushBandDetailViewController(urlString: result.band.urlString, animated: true)
            
            Analytics.logEvent("select_an_advanced_search_result", parameters: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let _ = bandAdvancedSearchResultPagableManager.totalRecords else {
            return
        }
        
        if bandAdvancedSearchResultPagableManager.moreToLoad && indexPath.row == bandAdvancedSearchResultPagableManager.objects.count {
            bandAdvancedSearchResultPagableManager.fetch()
        } else if !bandAdvancedSearchResultPagableManager.moreToLoad && indexPath.row == bandAdvancedSearchResultPagableManager.objects.count - 1 {
            Toast.displayMessageShortly(endOfListMessage)
        }
    }
}

//MARK: - UITableViewDataSource
extension AdvancedSearchBandsResultsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let manager = bandAdvancedSearchResultPagableManager else {
            return 0
        }
        
        if refreshControl.isRefreshing {
            return 0
        }
        
        if manager.moreToLoad {
            return manager.objects.count + 1
        }
        
        return manager.objects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if bandAdvancedSearchResultPagableManager.moreToLoad && indexPath.row == bandAdvancedSearchResultPagableManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let cell = AdvancedBandNameTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let result = bandAdvancedSearchResultPagableManager.objects[indexPath.row]
        cell.fill(with: result)
        cell.tappedThumbnailImageView = { [unowned self] in
            self.presentPhotoViewerWithCacheChecking(photoUrlString: result.band.imageURLString, description: result.band.name, fromImageView: cell.thumbnailImageView)
            
            Analytics.logEvent("view_advanced_search_result_thumbnail", parameters: nil)
        }
        return cell
    }
}

// MARK: - UIScrollViewDelegate
extension AdvancedSearchBandsResultsViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        simpleNavigationBarView?.transformWith(scrollView)
    }
}
