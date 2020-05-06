//
//  Top100AlbumsViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Toaster
import FirebaseAnalytics

final class Top100AlbumsViewController: BaseViewController {
    @IBOutlet private weak var top100NavigationBarView: Top100NavigationBarView!
    @IBOutlet private weak var tableView: UITableView!

    private var top100Albums: Top100Albums!
    
    private var numberOfTries = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        initTop100NavigationBarView()
        fetchData()
        
        Analytics.logEvent("view_top_100_albums", parameters: nil)
    }
    
    override func initAppearance() {
        super.initAppearance()
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.backgroundColor = Settings.currentTheme.backgroundColor
        tableView.contentInset = UIEdgeInsets(top: baseNavigationBarViewHeightWithoutTopInset, left: 0, bottom: UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0, right: 0)
        
        tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        
        AlbumTopTableViewCell.register(with: tableView)
    }
    
    private func initTop100NavigationBarView() {
        top100NavigationBarView.addAlbumTopTypeSegments()
        
        top100NavigationBarView.didTapBackButton = { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
        
        top100NavigationBarView.didChangeAlbumTopType = { [unowned self] in
            self.tableView.reloadData()
            
            Analytics.logEvent("change_section_in_top_albums", parameters: ["section": self.top100NavigationBarView.selectedAlbumTopType.description])
        }
    }
    
    private func fetchData() {
        showHUD()
        
        if numberOfTries == Settings.numberOfRetries {
            Toast.displayMessageShortly("Error loading content. Please check your internet connection and retry.")
            hideHUD()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.navigationController?.popViewController(animated: true)
            }
            return
        }
        
        numberOfTries += 1
        
        RequestHelper.StatisticDetail.fetchTop100Albums { [weak self] result in
            guard let self = self else { return }
            self.hideHUD()
            
            switch result {
            case .success(let top100Albums):
                self.top100Albums = top100Albums
                self.tableView.reloadData()
                
            case .failure(_):
                self.fetchData()
            }
        }
    }
}

//MARK: - UITableViewDelegate
extension Top100AlbumsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let album: AlbumTop
        
        switch top100NavigationBarView.selectedAlbumTopType {
        case .review: album = top100Albums.byReviews[indexPath.row]
        case .mostOwned: album = top100Albums.mostOwned[indexPath.row]
        case .mostWanted: album = top100Albums.mostWanted[indexPath.row]
        }
        takeActionFor(actionableObject: album)
        
        Analytics.logEvent("select_an_item_in_top_albums", parameters: ["album_title": album.release.title, "album_id": album.release.id])
    }
}

//MARK: - UITableViewDataSource
extension Top100AlbumsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let _ = top100Albums else {
            return 0
        }
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = AlbumTopTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let album: AlbumTop
        
        switch top100NavigationBarView.selectedAlbumTopType {
        case .review: album = top100Albums.byReviews[indexPath.row]
        case .mostOwned: album = top100Albums.mostOwned[indexPath.row]
        case .mostWanted: album = top100Albums.mostWanted[indexPath.row]
        }
        cell.fill(with: album, order: indexPath.row + 1)
        cell.tappedThumbnailImageView = { [unowned self] in
            self.presentPhotoViewerWithCacheChecking(photoUrlString: album.imageURLString, description: album.release.title, fromImageView: cell.thumbnailImageView)
            
            Analytics.logEvent("view_top_100_albums_thumbnail", parameters: ["album_title": album.release.title, "album_id": album.release.id])
        }
        return cell
    }
}

// MARK: - UIScrollViewDelegate
extension Top100AlbumsViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        top100NavigationBarView.transformWith(scrollView)
    }
}
