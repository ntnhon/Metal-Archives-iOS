//
//  AdvancedSearchAlbumsResultsViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 13/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Toaster
import FirebaseAnalytics

final class AdvancedSearchAlbumsResultsViewController: RefreshableViewController {
    var optionsList: String!
    private var albumAdvancedSearchResultPagableManager: PagableManager<AdvancedSearchResultAlbum>!
    weak var simpleNavigationBarView: SimpleNavigationBarView?
    deinit {
        print("AdvancedSearchAlbumsResultsViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initAlbumAdvancedSearchResultPagableManager()
        albumAdvancedSearchResultPagableManager.fetch()
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
        AdvancedAlbumTableViewCell.register(with: tableView)
        LoadingTableViewCell.register(with: tableView)
    }
    
    override func refresh() {
        albumAdvancedSearchResultPagableManager.reset()
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.albumAdvancedSearchResultPagableManager.fetch()
        }
        
        Analytics.logEvent("refresh_advanced_search_album_results", parameters: nil)
    }
    
    func initAlbumAdvancedSearchResultPagableManager() {
        guard var formattedOptionsList = optionsList.addingPercentEncoding(withAllowedCharacters: customURLQueryAllowedCharacterSet) else {
            assertionFailure("Error adding percent encoding to option list.")
            return
        }
        
        // encode space by + instead of %20
        formattedOptionsList = formattedOptionsList.replacingOccurrences(of: "%20", with: "+")
        
        albumAdvancedSearchResultPagableManager = PagableManager<AdvancedSearchResultAlbum>(options: ["<OPTIONS_LIST>": formattedOptionsList])
        albumAdvancedSearchResultPagableManager.delegate = self
    }
    
    private func updateTitle() {
        guard let totalRecords = albumAdvancedSearchResultPagableManager.totalRecords else {
            simpleNavigationBarView?.setTitle("No result found")
            return
        }
        
        if totalRecords == 0 {
            simpleNavigationBarView?.setTitle("No result found")
        } else if totalRecords == 1 {
            simpleNavigationBarView?.setTitle("Loaded \(albumAdvancedSearchResultPagableManager.objects.count) of \(totalRecords) result")
        } else {
            simpleNavigationBarView?.setTitle("Loaded \(albumAdvancedSearchResultPagableManager.objects.count) of \(totalRecords) results")
        }
    }
}

//MARK: - PagableManagerDelegate
extension AdvancedSearchAlbumsResultsViewController: PagableManagerDelegate {
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
        endRefreshing()
        updateTitle()
        tableView.reloadData()
    }
    
    func pagableManagerIsBeingBlocked<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        hideHUD()
    }
}

//MARK: - UITableViewDelegate
extension AdvancedSearchAlbumsResultsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let manager = albumAdvancedSearchResultPagableManager else {
            return
        }
        
        if manager.objects.indices.contains(indexPath.row) {
            let result = manager.objects[indexPath.row]
            takeActionFor(actionableObject: result)
            
            Analytics.logEvent("select_an_advanced_search_result", parameters: ["release_title": result.release.title, "release_id": result.release.id])
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let _ = albumAdvancedSearchResultPagableManager.totalRecords else {
            return
        }
        
        if albumAdvancedSearchResultPagableManager.moreToLoad && indexPath.row == albumAdvancedSearchResultPagableManager.objects.count {
            albumAdvancedSearchResultPagableManager.fetch()
        } else if !albumAdvancedSearchResultPagableManager.moreToLoad && indexPath.row == albumAdvancedSearchResultPagableManager.objects.count - 1 {
            Toast.displayMessageShortly(endOfListMessage)
        }
    }
}

//MARK: - UITableViewDataSource
extension AdvancedSearchAlbumsResultsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let manager = albumAdvancedSearchResultPagableManager else {
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
        if albumAdvancedSearchResultPagableManager.moreToLoad && indexPath.row == albumAdvancedSearchResultPagableManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let cell = AdvancedAlbumTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let result = albumAdvancedSearchResultPagableManager.objects[indexPath.row]
        cell.fill(with: result)
        cell.tappedThumbnailImageView = { [unowned self]  in
            self.presentPhotoViewerWithCacheChecking(photoUrlString: result.release.imageURLString, description: result.release.title, fromImageView: cell.thumbnailImageView)
            Analytics.logEvent("view_advanced_search_result_thumbnail", parameters: ["release_title": result.release.title, "release_id": result.release.id])
        }
        return cell
    }
}

// MARK: - UIScrollViewDelegate
extension AdvancedSearchAlbumsResultsViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        simpleNavigationBarView?.transformWith(scrollView)
    }
}
