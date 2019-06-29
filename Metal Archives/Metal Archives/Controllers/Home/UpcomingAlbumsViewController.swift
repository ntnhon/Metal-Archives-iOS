//
//  UpcomingAlbumsViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 20/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Toaster
import FirebaseAnalytics

final class UpcomingAlbumsViewController: RefreshableViewController {
    private var errorFetchingMoreUpcomingAlbums = false
    private var isFetching = false

    @IBOutlet private weak var simpleNavigationBarView: SimpleNavigationBarView!
    
    private var upcomingAlbumsPagableManager = PagableManager<UpcomingAlbum>()
    override func viewDidLoad() {
        super.viewDidLoad()
        initAndHandleSimpleNavigationBarViewActions()
        upcomingAlbumsPagableManager.delegate = self
    }
    
    override func initAppearance() {
        super.initAppearance()
        tableView.contentInset = UIEdgeInsets(top: baseNavigationBarViewHeightWithoutTopInset, left: 0, bottom: 0, right: 0)
        
        LoadingTableViewCell.register(with: tableView)
        UpcomingAlbumTableViewCell.register(with: tableView)
    }
    
    override func refresh() {
        upcomingAlbumsPagableManager.reset()
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.upcomingAlbumsPagableManager.fetch()
        }
        
        Analytics.logEvent(AnalyticsEvent.RefreshUpcomingAlbums, parameters: nil)
    }
    
    private func updateTitle() {
        guard let totalRecords = upcomingAlbumsPagableManager.totalRecords else {
            return
        }
        
        simpleNavigationBarView.setTitle("Upcoming Albums (\(upcomingAlbumsPagableManager.objects.count)/\(totalRecords))")
    }
    
    func initAndHandleSimpleNavigationBarViewActions() {
        simpleNavigationBarView.setTitle("Loading...")
        simpleNavigationBarView.setAlphaForBackgroundAndTitleLabel(1)
        simpleNavigationBarView.setRightButtonIcon(nil)
        
        simpleNavigationBarView.didTapLeftButton = { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
    }
}

//MARK: - PagableManagerProtocol
extension UpcomingAlbumsViewController: PagableManagerDelegate {
    func pagableManagerDidFailFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        endRefreshing()
        Toast.displayMessageShortly(errorLoadingMessage)
    }
    
    func pagableManagerDidFinishFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        refreshSuccessfully()
        updateTitle()
        tableView.reloadData()
        
        Analytics.logEvent(AnalyticsEvent.FetchMore, parameters: nil)
    }
    
    func pagableManagerIsBeingBlocked<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        Toast.displayBlockedMessageWithDelay()
    }
}

// MARK: - UIScrollViewDelegate
extension UpcomingAlbumsViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        simpleNavigationBarView.transformWith(scrollView)
    }
}

//MARK: - UITableViewDelegate
extension UpcomingAlbumsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if upcomingAlbumsPagableManager.moreToLoad && indexPath.row == upcomingAlbumsPagableManager.objects.count {
            //Loading cell
            return
        }
        
        let upcomingAlbum = upcomingAlbumsPagableManager.objects[indexPath.row]
        takeActionFor(actionableObject: upcomingAlbum)
        
        Analytics.logEvent(AnalyticsEvent.SelectAnItemInUpcomingAlbums, parameters: [AnalyticsParameter.ReleaseTitle: upcomingAlbum.release.title, AnalyticsParameter.ReleaseID: upcomingAlbum.release.id])
    }
}

//MARK: - UITableViewDatasource
extension UpcomingAlbumsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if refreshControl.isRefreshing {
            return 0
        }
        
        if upcomingAlbumsPagableManager.moreToLoad {
            return upcomingAlbumsPagableManager.objects.count + 1
        } else {
            return upcomingAlbumsPagableManager.objects.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if upcomingAlbumsPagableManager.moreToLoad && indexPath.row == upcomingAlbumsPagableManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let cell = UpcomingAlbumTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let upcomingAlbum = upcomingAlbumsPagableManager.objects[indexPath.row]
        cell.fill(with: upcomingAlbum)
        
        cell.tappedThumbnailImageView = { [unowned self] in
            self.presentPhotoViewerWithCacheChecking(photoUrlString: upcomingAlbum.release.imageURLString, description: upcomingAlbum.release.title, fromImageView: cell.thumbnailImageView)
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if upcomingAlbumsPagableManager.moreToLoad && indexPath.row == upcomingAlbumsPagableManager.objects.count {
            upcomingAlbumsPagableManager.fetch()
            
        } else if !upcomingAlbumsPagableManager.moreToLoad && indexPath.row == upcomingAlbumsPagableManager.objects.count - 1 {
            Toast.displayMessageShortly(endOfListMessage)
        }
    }
}
