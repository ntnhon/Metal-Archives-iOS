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
    
    // Artist
    private var artistBookmarkPagableManager: PagableManager<ArtistBookmark>!
    private var artistBookmarkOrder: ArtistOrLabelBookmarkOrder = .lastModifiedDescending
    
    // Label
    private var labelBookmarkPagableManager: PagableManager<LabelBookmark>!
    private var labelBookmarkOrder: ArtistOrLabelBookmarkOrder = .lastModifiedDescending
    
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
        case .artists: artistBookmarkPagableManager.fetch()
        case .labels: labelBookmarkPagableManager.fetch()
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
            case .artists: self.displayArtistOrLabelBookmarkOrderViewController(type: .artist)
            case .labels: self.displayArtistOrLabelBookmarkOrderViewController(type: .label)
            case .releases: self.displayBandOrReleaseBookmarkOrderViewController(type: .release)
            }
        }
    }
    
    private func setUpTableView() {
        LoadingTableViewCell.register(with: tableView)
        BandBookmarkTableViewCell.register(with: tableView)
        ReleaseBookmarkTableViewCell.register(with: tableView)
        ArtistBookmarkTableViewCell.register(with: tableView)
        LabelBookmarkTableViewCell.register(with: tableView)
    }
    
    private func initPagableManagers() {
        switch myBookmark {
        case .bands:
            bandBookmarkPagableManager = PagableManager<BandBookmark>(options: bandBookmarkOrder.options)
            bandBookmarkPagableManager.delegate = self
            
        case .artists:
            artistBookmarkPagableManager = PagableManager<ArtistBookmark>(options: artistBookmarkOrder.options)
            artistBookmarkPagableManager.delegate = self
            
        case .labels:
            labelBookmarkPagableManager = PagableManager<LabelBookmark>(options: labelBookmarkOrder.options)
            labelBookmarkPagableManager.delegate = self
            
        case .releases:
            releaseBookmarkPagableManager = PagableManager<ReleaseBookmark>(options: releaseBookmarkOrder.options)
            releaseBookmarkPagableManager.delegate = self
        }
    }
    
    override func refresh() {
        switch myBookmark {
        case .bands:
            bandBookmarkPagableManager.reset()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                self.bandBookmarkPagableManager.fetch()
            }
            
        case .artists:
            artistBookmarkPagableManager.reset()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                self.artistBookmarkPagableManager.fetch()
            }
            
        case .labels:
            labelBookmarkPagableManager.reset()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                self.labelBookmarkPagableManager.fetch()
            }
            
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
    
    private func displayArtistOrLabelBookmarkOrderViewController(type: ArtistOrLabelBookmarkOrderViewController.BookmarkType) {
        let artistOrLabelBookmarkOrderViewController = UIStoryboard(name: "MyProfile", bundle: nil).instantiateViewController(withIdentifier: "ArtistOrLabelBookmarkOrderViewController") as! ArtistOrLabelBookmarkOrderViewController
        
        switch type {
        case .artist: artistOrLabelBookmarkOrderViewController.currentOrder = artistBookmarkOrder
        case .label: artistOrLabelBookmarkOrderViewController.currentOrder = labelBookmarkOrder
        }
        
        artistOrLabelBookmarkOrderViewController.modalPresentationStyle = .popover
        artistOrLabelBookmarkOrderViewController.popoverPresentationController?.permittedArrowDirections = .any
        
        artistOrLabelBookmarkOrderViewController.popoverPresentationController?.delegate = self
        artistOrLabelBookmarkOrderViewController.popoverPresentationController?.sourceView = view
    
        artistOrLabelBookmarkOrderViewController.popoverPresentationController?.sourceRect = simpleNavigationBarView.rightButton.frame
        
        artistOrLabelBookmarkOrderViewController.selectedArtistOrLabelBookmarkOrder = { [unowned self] (artistOrLabelBookmarkOrder) in
            switch type {
            case .artist: self.artistBookmarkOrder = artistOrLabelBookmarkOrder
            case .label: self.labelBookmarkOrder = artistOrLabelBookmarkOrder
            }
            
            self.initPagableManagers()
            self.refresh()
        }
        
        present(artistOrLabelBookmarkOrderViewController, animated: true, completion: nil)
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
            
        case .artists:
            if artistBookmarkPagableManager.moreToLoad && indexPath.row == artistBookmarkPagableManager.objects.count {
                artistBookmarkPagableManager.fetch()
            }
            return
            
        case .labels:
            if labelBookmarkPagableManager.moreToLoad && indexPath.row == labelBookmarkPagableManager.objects.count {
                labelBookmarkPagableManager.fetch()
            }
            return
            
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
            
        case .artists:
            guard let manager = artistBookmarkPagableManager else { return 0 }
            moreToLoad = manager.moreToLoad
            count = manager.objects.count
            
        case .labels:
            guard let manager = labelBookmarkPagableManager else { return 0 }
            moreToLoad = manager.moreToLoad
            count = manager.objects.count
            
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
            
        case .artists:
            shouldDisplayLoadingCell = artistBookmarkPagableManager.moreToLoad && indexPath.row == artistBookmarkPagableManager.objects.count
            
        case .labels:
            shouldDisplayLoadingCell = labelBookmarkPagableManager.moreToLoad && indexPath.row == labelBookmarkPagableManager.objects.count
            
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
            
        case .artists:
            let cell = ArtistBookmarkTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            let artistBookmark = artistBookmarkPagableManager.objects[indexPath.row]
            cell.fill(with: artistBookmark)
            cell.tappedThumbnailImageView = { [unowned self] in
                self.presentPhotoViewerWithCacheChecking(photoUrlString: artistBookmark.imageURLString, description: artistBookmark.name, fromImageView: cell.thumbnailImageView)
            }
            return cell
            
        case .labels:
            let cell = LabelBookmarkTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            let labelBookmark = labelBookmarkPagableManager.objects[indexPath.row]
            cell.fill(with: labelBookmark)
            cell.tappedThumbnailImageView = { [unowned self] in
                self.presentPhotoViewerWithCacheChecking(photoUrlString: labelBookmark.imageURLString, description: labelBookmark.name, fromImageView: cell.thumbnailImageView)
            }
            return cell
            
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
