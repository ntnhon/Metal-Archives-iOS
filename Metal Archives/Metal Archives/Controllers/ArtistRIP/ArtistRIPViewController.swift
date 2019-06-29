//
//  ArtistRIPViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Toaster
import FirebaseAnalytics

final class ArtistRIPViewController: RefreshableViewController {
    var year: String! = "Any" {
        didSet {
            artistRipNavigationBarView.setMonthButtonTitle(year)
        }
    }
    
    @IBOutlet private weak var artistRipNavigationBarView: LatestReviewsNavigationBarView!
    private var artistRIPPagableManager: PagableManager<ArtistRIP>!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        initManager()
        initAndHandleArtistRipNavigationBarViewActions()
        artistRIPPagableManager.fetch()
    }

    override func initAppearance() {
        super.initAppearance()
        tableView.contentInset = UIEdgeInsets(top: baseNavigationBarViewHeightWithoutTopInset, left: 0, bottom: 0, right: 0)
        
        LoadingTableViewCell.register(with: tableView)
        ArtistRIPTableViewCell.register(with: tableView)
    }
    
    private func initManager() {
        if let `year` = year, let yearInt = Int(year) {
            artistRIPPagableManager = PagableManager<ArtistRIP>(options: ["<YEAR>": "\(yearInt)"])
        } else {
            artistRIPPagableManager = PagableManager<ArtistRIP>(options: ["<YEAR>": ""])
        }
        
        artistRIPPagableManager.delegate = self
    }
    
    override func refresh() {
        artistRIPPagableManager.reset()
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.artistRIPPagableManager.fetch()
        }
        
        Analytics.logEvent(AnalyticsEvent.RefreshArtistRIP, parameters: nil)
    }
    
    private func updateTitle() {
        guard let totalRecords = artistRIPPagableManager.totalRecords else {
            artistRipNavigationBarView.setTitle("No result found")
            return
        }
        
        artistRipNavigationBarView.setTitle("Loaded \(artistRIPPagableManager.objects.count) of \(totalRecords)")
    }
    
    private func initAndHandleArtistRipNavigationBarViewActions() {
        artistRipNavigationBarView.setMonthButtonTitle("Any")
        
        artistRipNavigationBarView.didTapBackButton = { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
        
        artistRipNavigationBarView.didTapMonthButton = { [unowned self] in
            let yearListViewController = UIStoryboard(name: "ArtistRIP", bundle: nil).instantiateViewController(withIdentifier: "YearListViewController") as! YearListViewController
            
            yearListViewController.modalPresentationStyle = .popover
            yearListViewController.popoverPresentationController?.permittedArrowDirections = .any
            yearListViewController.preferredContentSize = CGSize(width: 120, height: screenHeight*2/3)
            
            yearListViewController.popoverPresentationController?.delegate = self
            yearListViewController.popoverPresentationController?.sourceView = self.artistRipNavigationBarView.monthButton
            
            yearListViewController.delegate = self
            yearListViewController.selectedYear = self.year
            self.present(yearListViewController, animated: true, completion: nil)
        }
    }
}

//MARK: - YearListViewControllerDelegate
extension ArtistRIPViewController: YearListViewControllerDelegate {
    func didChangeYear(_ year: String) {
        self.year = year
        initManager()
        tableView.reloadData()
        artistRIPPagableManager.fetch()
        
        Analytics.logEvent(AnalyticsEvent.ChangeArtistRIPYear, parameters: [AnalyticsParameter.Year: year])
    }
}

//MARK: - UIPopoverPresentationControllerDelegate
extension ArtistRIPViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

//MARK: - PagableManager
extension ArtistRIPViewController: PagableManagerDelegate {
    func pagableManagerDidBeginFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        artistRipNavigationBarView.setTitle("Loading...")
    }
    
    func pagableManagerDidFailFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        Toast.displayMessageShortly(errorLoadingMessage)
    }
    
    func pagableManagerDidFinishFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        endRefreshing()
        updateTitle()
        tableView.reloadData()
        
        Analytics.logEvent(AnalyticsEvent.FetchMore, parameters: nil)
    }
    
    func pagableManagerIsBeingBlocked<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        Toast.displayBlockedMessageWithDelay()
    }
}

// MARK: - UIScrollViewDelegate
extension ArtistRIPViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        artistRipNavigationBarView.transformWith(scrollView)
    }
}

//MARK: - UITableViewDelegate
extension ArtistRIPViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if artistRIPPagableManager.objects.indices.contains(indexPath.row) {
            let artist = artistRIPPagableManager.objects[indexPath.row]
            takeActionFor(actionableObject: artist)
            
            Analytics.logEvent(AnalyticsEvent.SelectAnArtistRIP, parameters: [AnalyticsParameter.ArtistName: artist.name, AnalyticsParameter.ArtistID: artist.id])
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if artistRIPPagableManager.moreToLoad && indexPath.row == artistRIPPagableManager.objects.count {
            artistRIPPagableManager.fetch()
            
        } else if !artistRIPPagableManager.moreToLoad  && indexPath.row == artistRIPPagableManager.objects.count - 1 {
            Toast.displayMessageShortly(endOfListMessage)
        }
    }
}

//MARK: - UITableViewDataSource
extension ArtistRIPViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let manager = artistRIPPagableManager else {
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
        if artistRIPPagableManager.moreToLoad && indexPath.row == artistRIPPagableManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let cell = ArtistRIPTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        
        let artist = artistRIPPagableManager.objects[indexPath.row]
        cell.fill(with: artist)
        cell.tappedThumbnailImageView = { [unowned self] in
            self.presentPhotoViewerWithCacheChecking(photoUrlString: artist.imageURLString, description: artist.name, fromImageView: cell.thumbnailImageView)
        }
        return cell
    }
}
