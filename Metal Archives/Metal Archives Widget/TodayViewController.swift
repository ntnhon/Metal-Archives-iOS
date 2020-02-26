//
//  TodayViewController.swift
//  Metal Archives Widget
//
//  Created by Thanh-Nhon Nguyen on 20/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    @IBOutlet private weak var tableView: UITableView!
    
    private var bandAdditionPagableManager: PagableManager<BandAddition>!
    private var bandUpdatePagableManager: PagableManager<BandUpdate>!
    private var latestReviewPagableManager: PagableManager<LatestReview>!
    private var upcomingAlbumPagableManager: PagableManager<UpcomingAlbum>!
    
    private let choosenWidgetSection = UserDefaults.choosenWidgetSections()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        self.initTableViewAppearance()
        self.registerCells()
        self.fetch()
        self.extensionContext?.widgetLargestAvailableDisplayMode = .compact
        
        self.tableView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if self.extensionContext?.widgetActiveDisplayMode == .compact {
            self.preferredContentSize = CGSize(width: self.tableView.contentSize.width, height: 200)//200 or 300 or whatever, iOS doesn't care cause it will always allow a fixed height. The idea is to change the preferredContentSize to force animation happen
        } else {
            self.preferredContentSize = self.tableView.contentSize
        }
    }
    
    private func registerCells() {
        LoadingTableViewCell.register(with: self.tableView)
        BandAdditionOrUpdateTableViewCell.register(with: self.tableView)
        LatestReviewTableViewCell.register(with: self.tableView)
        UpcomingAlbumTableViewCell.register(with: self.tableView)
    }
    
    private func initTableViewAppearance() {
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.tintColor = Theme.light.titleColor
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
//        switch activeDisplayMode {
//        case .expanded:
//            self.preferredContentSize = self.tableView.contentSize
//        case .compact:
//            self.preferredContentSize = maxSize
//        }
        self.preferredContentSize = self.tableView.contentSize
    }
    
    private func fetch() {
        let thisMonth = Calendar.current.component(.month, from: Date())
        let thisYear = Calendar.current.component(.year, from: Date())
        
        let monthYearParameter = "\(thisYear)-\(String(format: "%02d", thisMonth))"
        
        self.choosenWidgetSection.forEach { (widgetSection) in
            switch widgetSection {
            case .bandAdditions:
                self.bandAdditionPagableManager = PagableManager<BandAddition>(options: ["<YEAR_MONTH>": monthYearParameter])
                self.bandAdditionPagableManager.delegate = self
                self.bandAdditionPagableManager.fetch()
                
            case .bandUpdates:
                self.bandUpdatePagableManager = PagableManager<BandUpdate>(options: ["<YEAR_MONTH>": monthYearParameter])
                self.bandUpdatePagableManager.delegate = self
                self.bandUpdatePagableManager.fetch()
                
            case .latestReviews:
                self.latestReviewPagableManager = PagableManager<LatestReview>(options: ["<YEAR_MONTH>": monthYearParameter])
                self.latestReviewPagableManager.delegate = self
                self.latestReviewPagableManager.fetch()
                
            case .upcomingAlbums:
                self.upcomingAlbumPagableManager = PagableManager<UpcomingAlbum>()
                self.upcomingAlbumPagableManager.delegate = self
                self.upcomingAlbumPagableManager.fetch()
                
            }
        }
    }
}

extension TodayViewController: PagableManagerDelegate {
    func pagableManagerDidFailFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        
    }
    
    func pagableManagerDidFinishFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        self.tableView.reloadData()
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }
}

//MARK: - UITableViewDelegate
extension TodayViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let widgetSection = self.choosenWidgetSection[indexPath.section]
        var url: URL?
        switch widgetSection {
        case .bandAdditions:
            let band = self.bandAdditionPagableManager.objects[indexPath.row]
            url = URL(string: "ma://band/\(band.urlString)")
        case .bandUpdates:
            let band = self.bandUpdatePagableManager.objects[indexPath.row]
            url = URL(string: "ma://band/\(band.urlString)")
        case .latestReviews:
            let review = self.latestReviewPagableManager.objects[indexPath.row]
            url = URL(string: "ma://review/\(review.reviewURLString)")
        case .upcomingAlbums:
            let album = self.upcomingAlbumPagableManager.objects[indexPath.row]
            url = URL(string: "ma://release/\(album.release.urlString)")
        }
        
        if let `url` = url {
            self.extensionContext?.open(url, completionHandler: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.choosenWidgetSection[section].headerTitle
    }
}

//MARK: - UITableViewDataSource
extension TodayViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.choosenWidgetSection.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let widgetSection = self.choosenWidgetSection[section]
        
        switch widgetSection {
        case .bandAdditions:
            guard let _ = self.bandAdditionPagableManager.totalRecords else {
                return 1
            }
            
            if self.choosenWidgetSection.count == 1 {
                if self.bandAdditionPagableManager.objects.count > 5 {
                    return 5
                } else {
                    return self.bandAdditionPagableManager.objects.count
                }
            }
            
            if self.bandAdditionPagableManager.objects.count > 3 {
                return 3
            } else {
                return self.bandAdditionPagableManager.objects.count
            }
            
        case .bandUpdates:
            guard let _ = self.bandUpdatePagableManager.totalRecords else {
                return 1
            }
            
            if self.choosenWidgetSection.count == 1 {
                if self.bandUpdatePagableManager.objects.count > 5 {
                    return 5
                } else {
                    return self.bandUpdatePagableManager.objects.count
                }
            }
            
            if self.bandUpdatePagableManager.objects.count > 3 {
                return 3
            } else {
                return self.bandUpdatePagableManager.objects.count
            }
            
        case .latestReviews:
            guard let _ = self.latestReviewPagableManager.totalRecords else {
                return 1
            }
            
            if self.choosenWidgetSection.count == 1 {
                if self.latestReviewPagableManager.objects.count > 5 {
                    return 5
                } else {
                    return self.latestReviewPagableManager.objects.count
                }
            }
            
            if self.latestReviewPagableManager.objects.count > 3 {
                return 3
            } else {
                return self.latestReviewPagableManager.objects.count
            }
            
        case .upcomingAlbums:
            guard let _ = self.upcomingAlbumPagableManager.totalRecords else {
                return 1
            }
            
            if self.choosenWidgetSection.count == 1 {
                if self.upcomingAlbumPagableManager.objects.count > 5 {
                    return 5
                } else {
                    return self.upcomingAlbumPagableManager.objects.count
                }
            }
            
            if self.upcomingAlbumPagableManager.objects.count > 3 {
                return 3
            } else {
                return self.upcomingAlbumPagableManager.objects.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let widgetSection = self.choosenWidgetSection[indexPath.section]
        
        switch widgetSection {
        case .bandAdditions: return self.cellForBandAddition(atIndexPath: indexPath)
        case .bandUpdates: return self.cellForBandUpdate(atIndexPath: indexPath)
        case .latestReviews: return self.cellForLatestReview(atIndexPath: indexPath)
        case .upcomingAlbums: return self.cellForUpcomingAlbum(atIndexPath: indexPath)
        }
    }
}

//MARK: - Cells
extension TodayViewController {
    private func cellForBandAddition(atIndexPath indexPath: IndexPath) -> UITableViewCell {
        guard let _ = self.bandAdditionPagableManager.totalRecords else {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.animate()
            return loadingCell
        }
        
        let cell = BandAdditionOrUpdateTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let band = self.bandAdditionPagableManager.objects[indexPath.row]
        cell.fill(with: band)
        return cell
    }
    
    private func cellForBandUpdate(atIndexPath indexPath: IndexPath) -> UITableViewCell {
        guard let _ = self.bandUpdatePagableManager.totalRecords else {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.animate()
            return loadingCell
        }
        
        let cell = BandAdditionOrUpdateTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let band = self.bandUpdatePagableManager.objects[indexPath.row]
        cell.fill(with: band)
        return cell
    }
    
    private func cellForLatestReview(atIndexPath indexPath: IndexPath) -> UITableViewCell {
        guard let _ = self.latestReviewPagableManager.totalRecords else {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.animate()
            return loadingCell
        }
        let cell = LatestReviewTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let review = self.latestReviewPagableManager.objects[indexPath.row]
        cell.fill(with: review)
        return cell
    }
    
    private func cellForUpcomingAlbum(atIndexPath indexPath: IndexPath) -> UITableViewCell {
        guard let _ = self.upcomingAlbumPagableManager.totalRecords else {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.animate()
            return loadingCell
        }
        let cell = UpcomingAlbumTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let album = self.upcomingAlbumPagableManager.objects[indexPath.row]
        cell.fill(with: album)
        return cell
    }
}
