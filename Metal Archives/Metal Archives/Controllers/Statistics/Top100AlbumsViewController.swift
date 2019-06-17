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
    }
    
    override func initAppearance() {
        super.initAppearance()
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.contentInset = UIEdgeInsets(top: baseNavigationBarViewHeightWithoutTopInset, left: 0, bottom: 0, right: 0)
        
        tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
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
            
            Analytics.logEvent(AnalyticsEvent.ChangeSectionInTop100Albums, parameters: [AnalyticsParameter.SectionName: self.top100NavigationBarView.selectedAlbumTopType.description])
        }
    }
    
    private func fetchData() {
        if numberOfTries == Settings.numberOfRetries {
            Toast.displayMessageShortly("Error loading content. Please check your internet connection and retry.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.navigationController?.popViewController(animated: true)
            }
            return
        }
        
        numberOfTries += 1
        MetalArchivesAPI.fetchTop100Albums { [weak self] (top100Albums, error) in
            if let _ = error {
                self?.fetchData()
            } else if let `top100Albums` = top100Albums {
                DispatchQueue.main.async {
                    self?.top100Albums = top100Albums
                    self?.tableView.reloadData()
                }
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
        
        Analytics.logEvent(AnalyticsEvent.SelectAnItemInTop100Albums, parameters: [AnalyticsParameter.SectionName: top100NavigationBarView.selectedAlbumTopType.description, AnalyticsParameter.ReleaseTitle: album.release.title, AnalyticsParameter.ReleaseID: album.release.id])
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
