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
    
    private var selectedGenreString: String?
    
    private var filteredUpcomingAlbums: [UpcomingAlbum]?

    @IBOutlet private weak var simpleNavigationBarView: SimpleNavigationBarView!
    
    private var upcomingAlbumsPagableManager = PagableManager<UpcomingAlbum>()
    
    deinit {
        print("UpcomingAlbumsViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initAndHandleSimpleNavigationBarViewActions()
        upcomingAlbumsPagableManager.delegate = self
        upcomingAlbumsPagableManager.fetch()
    }
    
    override func initAppearance() {
        super.initAppearance()
        tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        tableView.contentInset = UIEdgeInsets(top: baseNavigationBarViewHeightWithoutTopInset, left: 0, bottom: UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0, right: 0)
        
        LoadingTableViewCell.register(with: tableView)
        UpcomingAlbumTableViewCell.register(with: tableView)
    }
    
    override func refresh() {
        upcomingAlbumsPagableManager.reset()
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.upcomingAlbumsPagableManager.fetch()
        }
        
        Analytics.logEvent("refresh_upcoming_albums", parameters: nil)
    }
    
    private func updateTitle() {
        if let selectedGenre = selectedGenreString {
            simpleNavigationBarView.setTitle("Filtered by \"\(selectedGenre.description)\"")
        } else {
            guard let totalRecords = upcomingAlbumsPagableManager.totalRecords else {
                return
            }
            
            simpleNavigationBarView.setTitle("Upcoming Albums (\(upcomingAlbumsPagableManager.objects.count)/\(totalRecords))")
        }
    }
    
    private func updateSimpleNavigationBarRightButton() {
        if let _ = selectedGenreString {
            simpleNavigationBarView.setRightButtonIcon(#imageLiteral(resourceName: "X"))
            simpleNavigationBarView.didTapRightButton = { [unowned self] in
                self.selectedGenreString = nil
                self.reload()
            }
        } else {
            simpleNavigationBarView.setRightButtonIcon(#imageLiteral(resourceName: "funnel"))
            simpleNavigationBarView.didTapRightButton = { [unowned self] in
                self.showFilterOptions()
            }
        }
    }
    
    private func initAndHandleSimpleNavigationBarViewActions() {
        simpleNavigationBarView.setTitle("Loading...")
        simpleNavigationBarView.setAlphaForBackgroundAndTitleLabel(1)
        updateSimpleNavigationBarRightButton()
        
        simpleNavigationBarView.didTapLeftButton = { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func showFilterOptions() {
        let filterOptionsViewController = UpcomingAlbumsFilterOptionsViewController()
        
        let navigationViewController = UINavigationController(rootViewController: filterOptionsViewController)
        
        navigationViewController.modalPresentationStyle = .popover
        navigationViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        navigationViewController.preferredContentSize = CGSize(width: 250, height: screenHeight * 2 / 3)
        
        navigationViewController.popoverPresentationController?.delegate = self
        navigationViewController.popoverPresentationController?.sourceView = view
        navigationViewController.popoverPresentationController?.sourceRect = simpleNavigationBarView.rightButton.positionIn(view: view)
        
        filterOptionsViewController.didSelectGenreString = { [unowned self] selectedGenreString, byAndOperator in
            self.selectedGenreString = selectedGenreString
            self.filter(byAndOperator: byAndOperator)
            Analytics.logEvent("filter_in_upcoming_albums", parameters: ["genre": selectedGenreString ?? ""])
        }
        
        filterOptionsViewController.didTapManageButton = { [unowned self] in
            self.showFilterManagement()
            Analytics.logEvent("open_genre_filter_management_in_upcoming_albums", parameters: nil)
        }
        
        present(navigationViewController, animated: true, completion: nil)
        
        Analytics.logEvent("show_genre_filter_in_upcoming_albums", parameters: nil)
    }
    
    private func showFilterManagement() {
        let upcomingAlbumsFilterManagementViewController = UpcomingAlbumsFilterManagementViewController()
        navigationController?.pushViewController(upcomingAlbumsFilterManagementViewController, animated: true)
    }
    
    private func filter(byAndOperator: Bool) {
        defer {
            reload()
        }
        
        guard let selectedGenreString = selectedGenreString else { return }
        
        let predicateString = selectedGenreString.genreStringToKeywords().toPredicateString(byAndOperator: byAndOperator)
        let predicate = NSPredicate(format: predicateString)
        
        filteredUpcomingAlbums = (upcomingAlbumsPagableManager.objects as NSArray).filtered(using: predicate) as? [UpcomingAlbum]
    }
    
    private func reload() {
        tableView.reloadData()
        updateSimpleNavigationBarRightButton()
        updateTitle()
        if tableView.numberOfRows(inSection: 0) > 0 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
    }
}

// MARK: - UIPopoverPresentationControllerDelegate
extension UpcomingAlbumsViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

//MARK: - PagableManagerProtocol
extension UpcomingAlbumsViewController: PagableManagerDelegate {
    func pagableManagerDidBeginFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        simpleNavigationBarView.setTitle("Loading...")
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
        
        if let _ = selectedGenreString {
            guard let upcomingAlbum = filteredUpcomingAlbums?[indexPath.row] else { return }
            takeActionFor(actionableObject: upcomingAlbum)
            Analytics.logEvent("select_an_item_in_filtered_upcoming_albums", parameters: ["release_id": upcomingAlbum.release.id, "release_title": upcomingAlbum.release.title])
            return
        }
        
        if upcomingAlbumsPagableManager.moreToLoad && indexPath.row == upcomingAlbumsPagableManager.objects.count {
            //Loading cell
            return
        }
        
        let upcomingAlbum = upcomingAlbumsPagableManager.objects[indexPath.row]
        takeActionFor(actionableObject: upcomingAlbum)
        
        Analytics.logEvent("select_an_item_in_upcoming_albums", parameters: ["release_id": upcomingAlbum.release.id, "release_title": upcomingAlbum.release.title])
    }
}

//MARK: - UITableViewDatasource
extension UpcomingAlbumsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _ = selectedGenreString {
            return filteredUpcomingAlbums?.count ?? 0
        }
        
        if upcomingAlbumsPagableManager.moreToLoad {
            if upcomingAlbumsPagableManager.objects.count == 0 {
                return 0
            }
            
            return upcomingAlbumsPagableManager.objects.count + 1
        } else {
            return upcomingAlbumsPagableManager.objects.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let _ = selectedGenreString {
            let cell = UpcomingAlbumTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            guard let upcomingAlbum = filteredUpcomingAlbums?[indexPath.row] else {
                return cell
            }
            
            cell.tappedThumbnailImageView = { [unowned self] in
                self.presentPhotoViewerWithCacheChecking(photoUrlString: upcomingAlbum.release.imageURLString, description: upcomingAlbum.release.title, fromImageView: cell.thumbnailImageView)
                
                Analytics.logEvent("view_filtered_upcoming_album_thumbnail", parameters: ["release_id": upcomingAlbum.release.id, "release_title": upcomingAlbum.release.title])
            }
            
            cell.fill(with: upcomingAlbum)
            
            return cell
        } else {
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
                
                Analytics.logEvent("view_upcoming_album_thumbnail", parameters: ["release_id": upcomingAlbum.release.id, "release_title": upcomingAlbum.release.title])
            }
            
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let _ = selectedGenreString {
            // Don't load more in filter mode
            return
        }
        
        if upcomingAlbumsPagableManager.moreToLoad && indexPath.row == upcomingAlbumsPagableManager.objects.count {
            upcomingAlbumsPagableManager.fetch()
            
        } else if !upcomingAlbumsPagableManager.moreToLoad && indexPath.row == upcomingAlbumsPagableManager.objects.count - 1 {
            Toast.displayMessageShortly(endOfListMessage)
        }
    }
}
