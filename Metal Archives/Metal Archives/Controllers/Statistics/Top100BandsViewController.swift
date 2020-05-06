//
//  Top100BandsViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Toaster
import FirebaseAnalytics

final class Top100BandsViewController: BaseViewController {
    @IBOutlet private weak var top100NavigationBarView: Top100NavigationBarView!
    @IBOutlet private weak var tableView: UITableView!

    private var segmentedControl: UISegmentedControl!
    private var top100Bands: Top100Bands!
    
    private var numberOfTries = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        initTop100NavigationBarView()
        fetchData()
        
        Analytics.logEvent("view_top_100_bands", parameters: nil)
    }

    override func initAppearance() {
        super.initAppearance()
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.backgroundColor = Settings.currentTheme.backgroundColor
        tableView.contentInset = UIEdgeInsets(top: baseNavigationBarViewHeightWithoutTopInset, left: 0, bottom: UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0, right: 0)
        
        tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        
        BandTopTableViewCell.register(with: tableView)
    }
    
    private func initTop100NavigationBarView() {
        top100NavigationBarView.addBandTopTypeSegments()
        
        top100NavigationBarView.didTapBackButton = { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
        
        top100NavigationBarView.didChangeBandTopType = { [unowned self] in
            self.tableView.reloadData()
            
            Analytics.logEvent("ChangeSectionInTop100Bands", parameters: ["section": self.top100NavigationBarView.selectedBandTopType.description])
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

        RequestHelper.StatisticDetail.fetchTop100Bands { [weak self] result in
            guard let self = self else { return }
            self.hideHUD()
            
            switch result {
            case .success(let top100Bands):
                self.top100Bands = top100Bands
                self.tableView.reloadData()
                
            case .failure(_):
                self.fetchData()
            }
        }
    }
}

//MARK: - UITableViewDelegate
extension Top100BandsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var bandTop: BandTop?
        
        switch top100NavigationBarView.selectedBandTopType {
        case .release: bandTop = top100Bands.byReleases[indexPath.row]
        case .fullLength: bandTop = top100Bands.byFullLengths[indexPath.row]
        case .review: bandTop = top100Bands.byReviews[indexPath.row]
        }
        if let `bandTop` = bandTop {
            pushBandDetailViewController(urlString: bandTop.urlString, animated: true)
            
            Analytics.logEvent("select_an_item_in_top_bands", parameters: ["section": top100NavigationBarView.selectedBandTopType.description, "band_name": bandTop.name, "band_id": bandTop.id])
        }
    }
}

//MARK: - UITableViewDataSource
extension Top100BandsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let _ = top100Bands else {
            return 0
        }
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = BandTopTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let bandTop: BandTop
        
        switch top100NavigationBarView.selectedBandTopType  {
        case .release: bandTop = top100Bands.byReleases[indexPath.row]
        case .fullLength: bandTop = top100Bands.byFullLengths[indexPath.row]
        case .review: bandTop = top100Bands.byReviews[indexPath.row]
        }
        cell.fill(with: bandTop, order: indexPath.row + 1)
        
        cell.tappedThumbnailImageView = { [unowned self] in
            self.presentPhotoViewerWithCacheChecking(photoUrlString: bandTop.imageURLString, description: bandTop.name, fromImageView: cell.thumbnailImageView)
            
            Analytics.logEvent("view_top_100_bands_thumbnail", parameters: ["band_name": bandTop.name, "band_id": bandTop.id])
        }
        
        return cell
    }
}

// MARK: - UIScrollViewDelegate
extension Top100BandsViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        top100NavigationBarView.transformWith(scrollView)
    }
}
