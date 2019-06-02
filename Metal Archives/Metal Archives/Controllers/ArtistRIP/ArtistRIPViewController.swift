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

class ArtistRIPViewController: RefreshableViewController {
    var year: String! = "Any" {
        didSet {
            if let `year` = year {
                self.yearBarButtonItem.title = year
            }
        }
    }
    
    private var artistRIPPagableManager: PagableManager<ArtistRIP>!
    private var yearBarButtonItem: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initManager()
        self.artistRIPPagableManager.fetch()
        self.initYearBarButtonItem()
    }

    override func initAppearance() {
        super.initAppearance()
        LoadingTableViewCell.register(with: self.tableView)
        ArtistRIPTableViewCell.register(with: self.tableView)
    }
    
    private func initManager() {
        if let `year` = year, let yearInt = Int(year) {
            self.artistRIPPagableManager = PagableManager<ArtistRIP>(options: ["<YEAR>": "\(yearInt)"])
        } else {
            self.artistRIPPagableManager = PagableManager<ArtistRIP>(options: ["<YEAR>": ""])
        }
        
        self.artistRIPPagableManager.delegate = self
    }
    
    override func refresh() {
        self.artistRIPPagableManager.reset()
        self.tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.artistRIPPagableManager.fetch()
        }
        
        Analytics.logEvent(AnalyticsEvent.RefreshArtistRIP, parameters: nil)
    }
    
    private func updateTitle() {
        guard let totalRecords = self.artistRIPPagableManager.totalRecords else {
            self.title = "No result found"
            return
        }
        
        self.title = "Loaded \(self.artistRIPPagableManager.objects.count) of \(totalRecords)"
    }
    
    private func initYearBarButtonItem() {
        self.yearBarButtonItem = UIBarButtonItem(title: "Any", style: .done, target: self, action: #selector(didTapYearBarButtonItem))
        self.navigationItem.rightBarButtonItem = self.yearBarButtonItem
    }
    
    @objc private func didTapYearBarButtonItem() {
        let yearListViewController = UIStoryboard(name: "ArtistRIP", bundle: nil).instantiateViewController(withIdentifier: "YearListViewController") as! YearListViewController
        
        yearListViewController.modalPresentationStyle = .popover
        yearListViewController.popoverPresentationController?.permittedArrowDirections = .any
        yearListViewController.preferredContentSize = CGSize(width: 120, height: screenHeight*2/3)
        
        yearListViewController.popoverPresentationController?.delegate = self
        yearListViewController.popoverPresentationController?.barButtonItem = self.yearBarButtonItem
        
        yearListViewController.delegate = self
        yearListViewController.selectedYear = self.year
        self.present(yearListViewController, animated: true, completion: nil)
    }
}

//MARK: - YearListViewControllerDelegate
extension ArtistRIPViewController: YearListViewControllerDelegate {
    func didChangeYear(_ year: String) {
        self.year = year
        self.initManager()
        self.artistRIPPagableManager.fetch()
        
        Analytics.logEvent(AnalyticsEvent.ChangeArtistRIPYear, parameters: [AnalyticsParameter.Year: self.year!])
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
        self.title = "Loading..."
    }
    
    func pagableManagerDidFailFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        Toast.displayMessageShortly(errorLoadingMessage)
    }
    
    func pagableManagerDidFinishFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        self.endRefreshing()
        self.updateTitle()
        self.tableView.reloadData()
        
        Analytics.logEvent(AnalyticsEvent.FetchMore, parameters: nil)
    }
    
    func pagableManagerIsBeingBlocked<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        Toast.displayBlockedMessageWithDelay()
    }
}

//MARK: - UITableViewDelegate
extension ArtistRIPViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if self.artistRIPPagableManager.objects.indices.contains(indexPath.row) {
            let artist = self.artistRIPPagableManager.objects[indexPath.row]
            self.takeActionFor(actionableObject: artist)
            
            Analytics.logEvent(AnalyticsEvent.SelectAnArtistRIP, parameters: [AnalyticsParameter.ArtistName: artist.name, AnalyticsParameter.ArtistID: artist.id])
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.artistRIPPagableManager.moreToLoad && indexPath.row == self.artistRIPPagableManager.objects.count {
            self.artistRIPPagableManager.fetch()
            
        } else if !self.artistRIPPagableManager.moreToLoad  && indexPath.row == self.artistRIPPagableManager.objects.count - 1 {
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
        guard let manager = self.artistRIPPagableManager else {
            return 0
        }
        
        if self.refreshControl.isRefreshing {
            return 0
        }
        
        if manager.moreToLoad {
            return manager.objects.count + 1
        }
        
        return manager.objects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.artistRIPPagableManager.moreToLoad && indexPath.row == self.artistRIPPagableManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let cell = ArtistRIPTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        
        let artist = self.artistRIPPagableManager.objects[indexPath.row]
        cell.fill(with: artist)
        return cell
    }
}
