//
//  MyBookmarksViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 10/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Toaster
import Alamofire

final class MyBookmarksViewController: RefreshableViewController {
    @IBOutlet private weak var simpleNavigationBarView: SimpleNavigationBarView!
    
    var myBookmark: MyBookmark = .bands
    
    // Band
    private var bandBookmarkPagableManager: PagableManager<BandBookmark>!
    private var bandBookmarkOrder: BandOrReleaseBookmarkOrder = .lastModifiedDescending
    
    // Release
    private var releaseBookmarkPagableManager: PagableManager<ReleaseBookmark>!
    private var releaseBookmarkOrder: BandOrReleaseBookmarkOrder = .lastModifiedDescending
    
    deinit {
        print("MyBookmarksViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleSimpleNavigationBarViewActions()
        setUpTableView()
        initPagableManagers()
        
        switch myBookmark {
        case .bands: bandBookmarkPagableManager.fetch()
        case .artists: break
        case .labels: break
        case .releases: releaseBookmarkPagableManager.fetch()
        }
    }
    
    private func handleSimpleNavigationBarViewActions() {
        simpleNavigationBarView.setAlphaForBackgroundAndTitleLabel(1)
        simpleNavigationBarView.setTitle(myBookmark.description)
        
        simpleNavigationBarView.didTapLeftButton = { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
        
        simpleNavigationBarView.setRightButtonIcon(#imageLiteral(resourceName: "sort"))
        simpleNavigationBarView.didTapRightButton = { [unowned self] in
            switch self.myBookmark {
            case .bands: self.displayBandOrReleaseBookmarkOrderViewController(type: .band)
            case .artists: break
            case .labels: break
            case .releases: self.displayBandOrReleaseBookmarkOrderViewController(type: .release)
            }
        }
    }
    
    private func setUpTableView() {
        LoadingTableViewCell.register(with: tableView)
        BandBookmarkTableViewCell.register(with: tableView)
        ReleaseBookmarkTableViewCell.register(with: tableView)
    }
    
    private func initPagableManagers() {
        switch myBookmark {
        case .bands:
            bandBookmarkPagableManager = PagableManager<BandBookmark>(options: bandBookmarkOrder.options)
            bandBookmarkPagableManager.delegate = self
            
        case .releases:
            releaseBookmarkPagableManager = PagableManager<ReleaseBookmark>(options: releaseBookmarkOrder.options)
            releaseBookmarkPagableManager.delegate = self
            
        default: break
        }
    }
    
    override func refresh() {
        switch myBookmark {
        case .bands:
            bandBookmarkPagableManager.reset()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                self.bandBookmarkPagableManager.fetch()
            }
            
        case .artists: break
        case .labels: break
        case .releases:
            releaseBookmarkPagableManager.reset()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                self.releaseBookmarkPagableManager.fetch()
            }
        }
        
        tableView.reloadData()
    }
}

// MARK: - Popover
extension MyBookmarksViewController {
    private func displayBandOrReleaseBookmarkOrderViewController(type: BandOrReleaseBookmarkOrderViewController.BookmarkType) {
        let bandOrReleaseBookmarkOrderViewController = UIStoryboard(name: "MyProfile", bundle: nil).instantiateViewController(withIdentifier: "BandOrReleaseBookmarkOrderViewController") as! BandOrReleaseBookmarkOrderViewController
        
        switch type {
        case .band: bandOrReleaseBookmarkOrderViewController.currentOrder = bandBookmarkOrder
        case .release: bandOrReleaseBookmarkOrderViewController.currentOrder = releaseBookmarkOrder
        }
        
        bandOrReleaseBookmarkOrderViewController.modalPresentationStyle = .popover
        bandOrReleaseBookmarkOrderViewController.popoverPresentationController?.permittedArrowDirections = .any
        
        bandOrReleaseBookmarkOrderViewController.popoverPresentationController?.delegate = self
        bandOrReleaseBookmarkOrderViewController.popoverPresentationController?.sourceView = view
    
        bandOrReleaseBookmarkOrderViewController.popoverPresentationController?.sourceRect = simpleNavigationBarView.rightButton.frame
        
        bandOrReleaseBookmarkOrderViewController.selectedBandOrReleaseBookmarkOrder = { [unowned self] (bandOrReleaseBookmarkOrder) in
            switch type {
            case .band: self.bandBookmarkOrder = bandOrReleaseBookmarkOrder
            case .release: self.releaseBookmarkOrder = bandOrReleaseBookmarkOrder
            }
            
            self.initPagableManagers()
            self.refresh()
        }
        
        present(bandOrReleaseBookmarkOrderViewController, animated: true, completion: nil)
    }
}

// MARK: - UIPopoverPresentationControllerDelegate
extension MyBookmarksViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

// MARK: - PagableManagerDelegate
extension MyBookmarksViewController: PagableManagerDelegate {
    func pagableManagerDidBeginFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        showHUD()
    }
    
    func pagableManagerDidFailFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        hideHUD()
        Toast.displayMessageShortly(errorLoadingMessage)
    }
    
    func pagableManagerDidFinishFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        hideHUD()
        endRefreshing()
        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate
extension MyBookmarksViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch myBookmark {
        case .bands:
            if bandBookmarkPagableManager.moreToLoad && indexPath.row == bandBookmarkPagableManager.objects.count {
                bandBookmarkPagableManager.fetch()
            }
            return
            
        case .artists: return
        case .labels: return
        case .releases:
            if releaseBookmarkPagableManager.moreToLoad && indexPath.row == releaseBookmarkPagableManager.objects.count {
                releaseBookmarkPagableManager.fetch()
            }
            return
        }
    }
}

// MARK: - UITableViewDataSource
extension MyBookmarksViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let moreToLoad: Bool
        let count: Int
        switch myBookmark {
        case .bands:
            guard let manager = bandBookmarkPagableManager else { return 0 }
            moreToLoad = manager.moreToLoad
            count = manager.objects.count
            
        case .artists: return 0
        case .labels: return 0
        case .releases:
            guard let manager = releaseBookmarkPagableManager else { return 0 }
            moreToLoad = manager.moreToLoad
            count = manager.objects.count
        }
        
        if moreToLoad {
            if count == 0 {
                return 0
            }
            
            return count + 1
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Display loading cell if applicable
        let shouldDisplayLoadingCell: Bool
        switch myBookmark {
        case .bands:
            shouldDisplayLoadingCell = bandBookmarkPagableManager.moreToLoad && indexPath.row == bandBookmarkPagableManager.objects.count
            
        case .artists: shouldDisplayLoadingCell = false
        case .labels: shouldDisplayLoadingCell = false
        case .releases:
            shouldDisplayLoadingCell = releaseBookmarkPagableManager.moreToLoad && indexPath.row == releaseBookmarkPagableManager.objects.count
        }
        
        if shouldDisplayLoadingCell {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        // Display normal cells
        switch myBookmark {
        case .bands:
            let cell = BandBookmarkTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            let bandBookmark = bandBookmarkPagableManager.objects[indexPath.row]
            cell.fill(with: bandBookmark)
            cell.tappedThumbnailImageView = { [unowned self] in
                self.presentPhotoViewerWithCacheChecking(photoUrlString: bandBookmark.imageURLString, description: bandBookmark.name, fromImageView: cell.thumbnailImageView)
            }
            return cell
            
        case .artists: return UITableViewCell()
        case .labels: return UITableViewCell()
        case .releases:
            let cell = ReleaseBookmarkTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            let releaseBookmark = releaseBookmarkPagableManager.objects[indexPath.row]
            cell.fill(with: releaseBookmark)
            cell.tappedThumbnailImageView = { [unowned self] in
                self.presentPhotoViewerWithCacheChecking(photoUrlString: releaseBookmark.imageURLString, description: releaseBookmark.title, fromImageView: cell.thumbnailImageView)
            }
            return cell
        }
    }
}
