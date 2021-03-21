//
//  AdvancedSearchBandsResultsViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 12/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import FirebaseAnalytics
import Toaster
import UIKit

final class AdvancedSearchBandsResultsViewController: RefreshableViewController {
    var optionsList: String!
    private var pagableManager: PagableManager<AdvancedSearchResultBand>!
    weak var navigationBar: SimpleNavigationBarView?

    override func viewDidLoad() {
        super.viewDidLoad()
        initBandAdvancedSearchResultPagableManager()
        pagableManager.fetch()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBar?.setRightButtonIcon(nil)
        navigationBar?.isHidden = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationBar?.isHidden = !isMovingToParent
    }

    override func initAppearance() {
        super.initAppearance()
        tableView.contentInset = .init(top: baseNavigationBarViewHeightWithoutTopInset,
                                       left: 0,
                                       bottom: UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0,
                                       right: 0)
        AdvancedBandNameTableViewCell.register(with: tableView)
        LoadingTableViewCell.register(with: tableView)
    }

    override func refresh() {
        pagableManager.reset()
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.pagableManager.fetch()
        }
        Analytics.logEvent("refresh_advanced_search_band_results", parameters: nil)
    }

    private func initBandAdvancedSearchResultPagableManager() {
        //swiftlint:disable line_length
        guard var formattedOptionsList = optionsList.addingPercentEncoding(withAllowedCharacters: customURLQueryAllowedCharacterSet) else {
            assertionFailure("Error adding percent encoding to option list.")
            return
        }
        // encode space by + instead of %20
        formattedOptionsList = formattedOptionsList.replacingOccurrences(of: "%20", with: "+")
        pagableManager = PagableManager<AdvancedSearchResultBand>(options: ["<OPTIONS_LIST>": formattedOptionsList])
        pagableManager.delegate = self
        //swiftlint:enable line_length
    }

    private func updateTitle() {
        guard let totalRecords = pagableManager.totalRecords else {
            navigationBar?.setTitle("No result found")
            return
        }
        switch totalRecords {
        case 0: navigationBar?.setTitle("No result found")
        case 1: navigationBar?.setTitle("Loaded \(pagableManager.objects.count) of \(totalRecords) result")
        default: navigationBar?.setTitle("Loaded \(pagableManager.objects.count) of \(totalRecords) results")
        }
    }
}

// MARK: - PagableManagerDelegate
extension AdvancedSearchBandsResultsViewController: PagableManagerDelegate {
    func pagableManagerDidBeginFetching<T>(_ pagableManager: PagableManager<T>) where T: Pagable {
        navigationBar?.setTitle("Loading...")
        showHUD()
    }

    func pagableManagerDidFailFetching<T>(_ pagableManager: PagableManager<T>) where T: Pagable {
        hideHUD()
        endRefreshing()
        Toast.displayMessageShortly(errorLoadingMessage)
    }

    func pagableManagerDidFinishFetching<T>(_ pagableManager: PagableManager<T>) where T: Pagable {
        hideHUD()
        endRefreshing()
        updateTitle()
        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate
extension AdvancedSearchBandsResultsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let manager = pagableManager else { return }
        if manager.objects.indices.contains(indexPath.row) {
            let result = manager.objects[indexPath.row]
            pushBandDetailViewController(urlString: result.band.urlString, animated: true)
            Analytics.logEvent("select_an_advanced_search_result", parameters: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if pagableManager.totalRecords == nil { return }
        if pagableManager.moreToLoad && indexPath.row == pagableManager.objects.count {
            pagableManager.fetch()
        } else if !pagableManager.moreToLoad && indexPath.row == pagableManager.objects.count - 1 {
            Toast.displayMessageShortly(endOfListMessage)
        }
    }
}

// MARK: - UITableViewDataSource
extension AdvancedSearchBandsResultsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let manager = pagableManager else { return 0 }
        if manager.moreToLoad {
            return manager.objects.isEmpty ? 0 : manager.objects.count + 1
        }
        return manager.objects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if pagableManager.moreToLoad && indexPath.row == pagableManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let cell = AdvancedBandNameTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let result = pagableManager.objects[indexPath.row]
        cell.fill(with: result)
        cell.tappedThumbnailImageView = { [unowned self] in
            self.presentPhotoViewerWithCacheChecking(photoUrlString: result.band.imageURLString,
                                                     description: result.band.name,
                                                     fromImageView: cell.thumbnailImageView)
            Analytics.logEvent("view_advanced_search_result_thumbnail", parameters: nil)
        }
        return cell
    }
}

// MARK: - UIScrollViewDelegate
extension AdvancedSearchBandsResultsViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        navigationBar?.transformWith(scrollView)
    }
}
