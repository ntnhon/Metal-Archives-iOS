//
//  BandAphabeticallyResultViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 13/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Toaster
import FirebaseAnalytics

final class BrowseBandsResultViewController: RefreshableViewController {
    @IBOutlet private weak var simpleNavigationBarView: SimpleNavigationBarView!
    var parameter: String!
    var context: String!
    
    private var bandBrowsePagableManager: PagableManager<BandBrowse>!
    override func viewDidLoad() {
        super.viewDidLoad()
        initSimpleNavigationBarView()
        bandBrowsePagableManager = PagableManager<BandBrowse>(options: ["<PARAMETER>": parameter])
        bandBrowsePagableManager.delegate = self
        bandBrowsePagableManager.fetch()
    }

    override func initAppearance() {
        super.initAppearance()
        tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.contentInset = UIEdgeInsets(top: baseNavigationBarViewHeightWithoutTopInset, left: 0, bottom: UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0, right: 0)
        
        LoadingTableViewCell.register(with: tableView)
        BrowseBandsResultTableViewCell.register(with: tableView)
    }
    
    private func initSimpleNavigationBarView() {
        simpleNavigationBarView.setAlphaForBackgroundAndTitleLabel(1)
        simpleNavigationBarView.setTitle("Loading...")
        simpleNavigationBarView.setRightButtonIcon(nil)
        
        simpleNavigationBarView.didTapLeftButton = { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func updateTitle() {
        guard let totalRecords = bandBrowsePagableManager.totalRecords else {
            simpleNavigationBarView.setTitle("")
            return
        }
        
        simpleNavigationBarView.setTitle(context + " (\(bandBrowsePagableManager.objects.count)/\(totalRecords))")
    }
    
    override func refresh() {
        bandBrowsePagableManager.reset()
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: {
            self.bandBrowsePagableManager.fetch()
        })
        
        Analytics.logEvent("refresh_browse_bands_results", parameters: nil)
    }
}

//MARK: - PagableManagerDelegate
extension BrowseBandsResultViewController: PagableManagerDelegate {
    func pagableManagerDidBeginFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        simpleNavigationBarView.setTitle("Loading...")
    }
    
    func pagableManagerDidFailFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        Toast.displayMessageShortly(errorLoadingMessage)
    }
    
    func pagableManagerDidFinishFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        endRefreshing()
        updateTitle()
        tableView.reloadData()
    }
    
    func pagableManagerIsBeingBlocked<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        Toast.displayBlockedMessageWithDelay()
    }
}

//MARK: - UITableViewDelegate
extension BrowseBandsResultViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if bandBrowsePagableManager.objects.indices.contains(indexPath.row) {
            let band = bandBrowsePagableManager.objects[indexPath.row]
            pushBandDetailViewController(urlString: band.urlString, animated: true)
            
            Analytics.logEvent("select_a_browse_bands_result", parameters: ["band_name": band.name, "band_id": band.id])
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if bandBrowsePagableManager.moreToLoad && indexPath.row == bandBrowsePagableManager.objects.count {
            bandBrowsePagableManager.fetch()
            
        } else if !bandBrowsePagableManager.moreToLoad && indexPath.row == bandBrowsePagableManager.objects.count - 1 {
            Toast.displayMessageShortly(endOfListMessage)
        }
    }
}

//MARK: - UITableViewDataSource
extension BrowseBandsResultViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let manager = bandBrowsePagableManager else {
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
        if bandBrowsePagableManager.moreToLoad && indexPath.row == bandBrowsePagableManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let cell = BrowseBandsResultTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let band = bandBrowsePagableManager.objects[indexPath.row]
        cell.fill(with: band)
        cell.tappedThumbnailImageView = { [unowned self] in
            self.presentPhotoViewerWithCacheChecking(photoUrlString: band.imageURLString, description: band.name, fromImageView: cell.thumbnailImageView)
        }
        return cell
    }
}
