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
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func initAppearance() {
        super.initAppearance()
        let tableViewTopInset: CGFloat
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        tableViewTopInset = top100NavigationBarView.bounds.height - UIApplication.shared.statusBarFrame.height
        tableView.contentInset = UIEdgeInsets(top: tableViewTopInset, left: 0, bottom: 0, right: 0)
        
        tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
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
            
            Analytics.logEvent(AnalyticsEvent.ChangeSectionInTop100Bands, parameters: [AnalyticsParameter.SectionName: self.top100NavigationBarView.selectedBandTopType.description])
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
        MetalArchivesAPI.fetchTop100Bands { [weak self] (top100Bands, error) in
            if let _ = error {
                self?.fetchData()
            } else if let `top100Bands` = top100Bands {
                DispatchQueue.main.async {
                    self?.top100Bands = top100Bands
                    self?.tableView.reloadData()
                }
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
            
            Analytics.logEvent(AnalyticsEvent.SelectAnItemInTop100Bands, parameters: [AnalyticsParameter.SectionName: top100NavigationBarView.selectedBandTopType.description, AnalyticsParameter.BandName: bandTop.name, AnalyticsParameter.BandID: bandTop.id])
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
