//
//  AdvancedSearchSongsResultsViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 13/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Toaster
import FirebaseAnalytics

final class AdvancedSearchSongsResultsViewController: RefreshableViewController {
    var optionsList: String!
    private var songAdvancedSearchResultPagableManager: PagableManager<AdvancedSearchResultSong>!
    weak var simpleNavigationBarView: SimpleNavigationBarView?
    deinit {
        print("AdvancedSearchSongsResultsViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSongAdvancedSearchResultPagableManager()
        songAdvancedSearchResultPagableManager.fetch()
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
        tableView.contentInset = UIEdgeInsets(top: baseNavigationBarViewHeightWithoutTopInset, left: 0, bottom: 0, right: 0)
        AdvancedSongTableViewCell.register(with: tableView)
        LoadingTableViewCell.register(with: tableView)
    }
    
    override func refresh() {
        songAdvancedSearchResultPagableManager.reset()
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.songAdvancedSearchResultPagableManager.fetch()
        }
        
        Analytics.logEvent("refresh_advanced_search_song_results", parameters: nil)
    }
    
    func initSongAdvancedSearchResultPagableManager() {
        guard let formattedOptionsList = optionsList.addingPercentEncoding(withAllowedCharacters: customURLQueryAllowedCharacterSet) else {
            assertionFailure("Error adding percent encoding to option list.")
            return
        }
        
        songAdvancedSearchResultPagableManager = PagableManager<AdvancedSearchResultSong>(options: ["<OPTIONS_LIST>": formattedOptionsList])
        songAdvancedSearchResultPagableManager.delegate = self
    }
    
    private func updateTitle() {
        guard let totalRecords = songAdvancedSearchResultPagableManager.totalRecords else {
            simpleNavigationBarView?.setTitle("No result found")
            return
        }
        
        if totalRecords == 0 {
            simpleNavigationBarView?.setTitle("No result found")
        } else if totalRecords == 1 {
            simpleNavigationBarView?.setTitle("Loaded \(songAdvancedSearchResultPagableManager.objects.count) of \(totalRecords) result")
        } else {
            simpleNavigationBarView?.setTitle("Loaded \(songAdvancedSearchResultPagableManager.objects.count) of \(totalRecords) results")
        }
    }
}

//MARK: - PagableManagerDelegate
extension AdvancedSearchSongsResultsViewController: PagableManagerDelegate {
    func pagableManagerDidBeginFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        simpleNavigationBarView?.setTitle("Loading...")
    }
    
    func pagableManagerDidFailFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        endRefreshing()
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
extension AdvancedSearchSongsResultsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let manager = songAdvancedSearchResultPagableManager else {
            return
        }
        
        if manager.objects.indices.contains(indexPath.row) {
            let result = manager.objects[indexPath.row]
            takeActionFor(actionableObject: result)
            
            Analytics.logEvent("select_an_advanced_search_result", parameters: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let _ = songAdvancedSearchResultPagableManager.totalRecords else {
            return
        }
        
        if songAdvancedSearchResultPagableManager.moreToLoad && indexPath.row == songAdvancedSearchResultPagableManager.objects.count {
            songAdvancedSearchResultPagableManager.fetch()
        } else if !songAdvancedSearchResultPagableManager.moreToLoad && indexPath.row == songAdvancedSearchResultPagableManager.objects.count - 1 {
            Toast.displayMessageShortly(endOfListMessage)
        }
    }
}

//MARK: - UITableViewDataSource
extension AdvancedSearchSongsResultsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let manager = songAdvancedSearchResultPagableManager else {
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
        if songAdvancedSearchResultPagableManager.moreToLoad && indexPath.row == songAdvancedSearchResultPagableManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let cell = AdvancedSongTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let result = songAdvancedSearchResultPagableManager.objects[indexPath.row]
        cell.fill(with: result)
        cell.tappedThumbnailImageView = { [unowned self]  in
            self.presentPhotoViewerWithCacheChecking(photoUrlString: result.release.imageURLString, description: result.release.title, fromImageView: cell.thumbnailImageView)
        }
        return cell
    }
}

// MARK: - UIScrollViewDelegate
extension AdvancedSearchSongsResultsViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        simpleNavigationBarView?.transformWith(scrollView)
    }
}
