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

    private var rightBarButtonItem: UIBarButtonItem!
    private var upcomingAlbumsPagableManager = PagableManager<UpcomingAlbum>()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Upcoming Albums"
        self.upcomingAlbumsPagableManager.delegate = self
        self.initRightBarButtonItem()
    }
    
    override func initAppearance() {
        super.initAppearance()
        LoadingTableViewCell.register(with: self.tableView)
        UpcomingAlbumTableViewCell.register(with: self.tableView)
    }
    
    private func initRightBarButtonItem() {
        self.rightBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = self.rightBarButtonItem
    }
    
    override func refresh() {
        self.upcomingAlbumsPagableManager.reset()
        self.tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.upcomingAlbumsPagableManager.fetch()
        }
        
        Analytics.logEvent(AnalyticsEvent.RefreshUpcomingAlbums, parameters: nil)
    }
    
    private func updateRightBarButtonTitle() {
        guard let totalRecords = self.upcomingAlbumsPagableManager.totalRecords else {
            return
        }
        
        self.rightBarButtonItem.title = "Loaded \(self.upcomingAlbumsPagableManager.objects.count) of \(totalRecords)"
    }
}

//MARK: - PagableManagerProtocol
extension UpcomingAlbumsViewController: PagableManagerDelegate {
    func pagableManagerDidFailFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        self.endRefreshing()
        Toast.displayMessageShortly(errorLoadingMessage)
    }
    
    func pagableManagerDidFinishFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        self.refreshSuccessfully()
        self.updateRightBarButtonTitle()
        self.tableView.reloadData()
        
        Analytics.logEvent(AnalyticsEvent.FetchMore, parameters: nil)
    }
    
    func pagableManagerIsBeingBlocked<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        Toast.displayBlockedMessageWithDelay()
    }
}

//MARK: - UITableViewDelegate
extension UpcomingAlbumsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if self.upcomingAlbumsPagableManager.moreToLoad && indexPath.row == self.upcomingAlbumsPagableManager.objects.count {
            //Loading cell
            return
        }
        
        let upcomingAlbum = self.upcomingAlbumsPagableManager.objects[indexPath.row]
        self.takeActionFor(actionableObject: upcomingAlbum)
        
        Analytics.logEvent(AnalyticsEvent.SelectAnItemInUpcomingAlbums, parameters: [AnalyticsParameter.ReleaseTitle: upcomingAlbum.release.title, AnalyticsParameter.ReleaseID: upcomingAlbum.release.id])
    }
}

//MARK: - UITableViewDatasource
extension UpcomingAlbumsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.refreshControl.isRefreshing {
            return 0
        }
        
        if self.upcomingAlbumsPagableManager.moreToLoad {
            return self.upcomingAlbumsPagableManager.objects.count + 1
        } else {
            return self.upcomingAlbumsPagableManager.objects.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.upcomingAlbumsPagableManager.moreToLoad && indexPath.row == self.upcomingAlbumsPagableManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let cell = UpcomingAlbumTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let upcomingAlbum = self.upcomingAlbumsPagableManager.objects[indexPath.row]
        cell.fill(with: upcomingAlbum)
        
        cell.tappedThumbnailImageView = { [unowned self] in
            self.presentPhotoViewerWithCacheChecking(photoUrlString: upcomingAlbum.release.imageURLString, description: upcomingAlbum.release.title, fromImageView: cell.thumbnailImageView)
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if self.upcomingAlbumsPagableManager.moreToLoad && indexPath.row == self.upcomingAlbumsPagableManager.objects.count {
            self.upcomingAlbumsPagableManager.fetch()
            
        } else if !self.upcomingAlbumsPagableManager.moreToLoad && indexPath.row == self.upcomingAlbumsPagableManager.objects.count - 1 {
            Toast.displayMessageShortly(endOfListMessage)
        }
    }
}
