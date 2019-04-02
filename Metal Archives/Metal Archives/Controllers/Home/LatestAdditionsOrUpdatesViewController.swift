//
//  LatestAdditionsViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 20/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Toaster
import FirebaseAnalytics

enum LatestAdditionsOrUpdatesViewControllerType {
    case additions, updates
}

final class LatestAdditionsOrUpdatesViewController: RefreshableViewController {

    private var segmentedControl: UISegmentedControl!
    private var messageLabel: UILabel!
    private var currentLatestAdditionType: AdditionOrUpdateType = .bands
    private var rightBarButtonItem: UIBarButtonItem!
    
    private var parameterOptions: [String: String]! = ["<YEAR_MONTH>": monthList[0].requestParameterString]
    private var selectedMonth: MonthInYear = monthList[0] {
        didSet {
            self.rightBarButtonItem.title = selectedMonth.shortDisplayString
            self.parameterOptions = ["<YEAR_MONTH>": selectedMonth.requestParameterString]
        }
    }
    
    var type: LatestAdditionsOrUpdatesViewControllerType!
    
    private var bandAdditionPagableManager: PagableManager<BandAddition>!
    private var bandUpdatePagableManager: PagableManager<BandUpdate>!
    
    private var labelAdditionPagableManager: PagableManager<LabelAddition>!
    private var labelUpdatePagableManager: PagableManager<LabelUpdate>!
    
    private var artistAdditionPagableManager: PagableManager<ArtistAddition>!
    private var artistUpdatePagableManager: PagableManager<ArtistUpdate>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initNavigationBarElements()
        self.initRightBarButtonItem()
        self.initNavBarAttributes()
        self.initPagableManagers()
        self.fetchData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = false
        }
    }
    
    override func initAppearance() {
        super.initAppearance()
        
        LoadingTableViewCell.register(with: self.tableView)
        BandAdditionOrUpdateTableViewCell.register(with: self.tableView)
        LabelAdditionOrUpdateTableViewCell.register(with: self.tableView)
        ArtistAdditionOrUpdateTableViewCell.register(with: self.tableView)
    }
    
    override func refresh() {
        switch self.currentLatestAdditionType {
        case .bands:
            if self.type! == .additions {
                self.initBandAdditionPagableManager()
                self.tableView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    self.bandAdditionPagableManager.fetch()
                }
            } else {
                self.initBandUpdatePagableManager()
                self.tableView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    self.bandUpdatePagableManager.fetch()
                }
            }
        case .labels:
            if self.type! == .additions {
                self.initLabelAdditionPagableManager()
                self.tableView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    self.labelAdditionPagableManager.fetch()
                }
            } else {
                self.initLabelUpdatePagableManager()
                self.tableView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    self.labelUpdatePagableManager.fetch()
                }
            }
        case .artists:
            if self.type! == .additions {
                self.initArtistAdditionPagableManager()
                self.tableView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    self.artistAdditionPagableManager.fetch()
                }
            } else {
                self.initArtistUpdatePagableManager()
                self.tableView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    self.artistUpdatePagableManager.fetch()
                }
            }
        }
        
        switch self.type! {
        case .additions:
            Analytics.logEvent(AnalyticsEvent.RefreshLatestAdditions, parameters: [AnalyticsParameter.SectionName: self.currentLatestAdditionType.description])
        case .updates:
            Analytics.logEvent(AnalyticsEvent.RefreshLatestUpdates, parameters: [AnalyticsParameter.SectionName: self.currentLatestAdditionType.description])
        }
        
    }
    
    private func updateMessageLabel() {
        var count: Int?
        var total: Int?
        switch self.currentLatestAdditionType {
        case .bands:
            if self.type! == .additions {
                count = self.bandAdditionPagableManager.objects.count
                total = self.bandAdditionPagableManager.totalRecords
            } else {
                count = self.bandUpdatePagableManager.objects.count
                total = self.bandUpdatePagableManager.totalRecords
            }
        case .labels:
            if self.type! == .additions {
                count = self.labelAdditionPagableManager.objects.count
                total = self.labelAdditionPagableManager.totalRecords
            } else {
                count = self.labelUpdatePagableManager.objects.count
                total = self.labelUpdatePagableManager.totalRecords
            }
        case .artists:
            if self.type! == .additions {
                count = self.artistAdditionPagableManager.objects.count
                total = self.artistAdditionPagableManager.totalRecords
            } else {
                count = self.artistUpdatePagableManager.objects.count
                total = self.artistUpdatePagableManager.totalRecords
            }
        }
        
        if let `count` = count, let `total` = total {
            self.messageLabel.text = "Loaded \(count) of \(total)"
        } else {
            self.messageLabel.text = "No result found"
        }
    }
    
    private func fetchData() {
        switch self.currentLatestAdditionType {
        case .bands:
            if self.type! == .additions {
                self.bandAdditionPagableManager.fetch()
            } else {
                self.bandUpdatePagableManager.fetch()
            }
        case .labels:
            if self.type! == .additions {
                self.labelAdditionPagableManager.fetch()
            } else {
                self.labelUpdatePagableManager.fetch()
            }
        case .artists:
            if self.type! == .additions {
                self.artistAdditionPagableManager.fetch()
            } else {
                self.artistUpdatePagableManager.fetch()
            }
        }
    }
    
    private func initNavBarAttributes() {
        
        switch self.type! {
        case .additions: self.title = "Latest Additions"
        case .updates: self.title = "Latest Updates"
        }
        
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
    }

    private func initNavigationBarElements() {
        var segmentTitles: [String] = []
        segmentTitles = AdditionOrUpdateType.allCases.map({$0.description})
        self.segmentedControl = UISegmentedControl(items: segmentTitles)
        self.segmentedControl.selectedSegmentIndex = self.currentLatestAdditionType.rawValue
        self.segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        
        
        self.messageLabel = UILabel()
        self.messageLabel.font = UIFont.systemFont(ofSize: 13)
        self.messageLabel.textAlignment = .center
        
        let stackView = UIStackView(arrangedSubviews: [self.segmentedControl!, self.messageLabel!])
        stackView.axis = .vertical
        
        self.navigationItem.titleView = stackView
    }

    private func initRightBarButtonItem() {
        let thisMonthString = monthList[0].shortDisplayString
        self.rightBarButtonItem = UIBarButtonItem(title: thisMonthString, style: .done, target: self, action: #selector(didTapRightBarButtonItem))
        self.navigationItem.rightBarButtonItem = self.rightBarButtonItem
    }
    
    private func initPagableManagers() {
        switch self.type! {
        case .additions:
            self.initBandAdditionPagableManager()
            self.initLabelAdditionPagableManager()
            self.initArtistAdditionPagableManager()
        case .updates:
            self.initBandUpdatePagableManager()
            self.initLabelUpdatePagableManager()
            self.initArtistUpdatePagableManager()
        }
    }
    
    private func initBandAdditionPagableManager() {
        self.bandAdditionPagableManager = PagableManager<BandAddition>(options: self.parameterOptions)
        self.bandAdditionPagableManager.delegate = self
    }
    
    private func initBandUpdatePagableManager() {
        self.bandUpdatePagableManager = PagableManager<BandUpdate>(options: self.parameterOptions)
        self.bandUpdatePagableManager.delegate = self
    }
    
    private func initLabelAdditionPagableManager() {
        self.labelAdditionPagableManager = PagableManager<LabelAddition>(options: self.parameterOptions)
        self.labelAdditionPagableManager.delegate = self
    }
    
    private func initLabelUpdatePagableManager() {
        self.labelUpdatePagableManager = PagableManager<LabelUpdate>(options: self.parameterOptions)
        self.labelUpdatePagableManager.delegate = self
    }
    
    private func initArtistAdditionPagableManager() {
        self.artistAdditionPagableManager = PagableManager<ArtistAddition>(options: self.parameterOptions)
        self.artistAdditionPagableManager.delegate = self
    }
    
    private func initArtistUpdatePagableManager() {
        self.artistUpdatePagableManager = PagableManager<ArtistUpdate>(options: self.parameterOptions)
        self.artistUpdatePagableManager.delegate = self
    }


    @objc private func segmentedControlValueChanged() {
        self.currentLatestAdditionType = AdditionOrUpdateType(rawValue: self.segmentedControl.selectedSegmentIndex) ?? .bands
        self.updateMessageLabel()
        self.tableView.scrollRectToVisible(CGRect.zero, animated: false)
        self.tableView.reloadData()
        
        
        switch self.type! {
        case .additions:
            Analytics.logEvent(AnalyticsEvent.ChangeSectionInLatestAdditions, parameters: [AnalyticsParameter.SectionName: self.currentLatestAdditionType.description])
        case .updates:
            Analytics.logEvent(AnalyticsEvent.ChangeSectionInLatestUpdates, parameters: [AnalyticsParameter.SectionName: self.currentLatestAdditionType.description])
        }
    }
    
    @objc private func didTapRightBarButtonItem() {
        let monthListViewController = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "MonthListViewController") as! MonthListViewController
        
        monthListViewController.modalPresentationStyle = .popover
        monthListViewController.popoverPresentationController?.permittedArrowDirections = .any
        monthListViewController.preferredContentSize = CGSize(width: 220, height: screenHeight*2/3)
        
        monthListViewController.popoverPresentationController?.delegate = self
        monthListViewController.popoverPresentationController?.barButtonItem = self.rightBarButtonItem

        monthListViewController.delegate = self
        monthListViewController.selectedMonth = self.selectedMonth
        self.present(monthListViewController, animated: true, completion: nil)
    }
}

//MARK: - UIPopoverPresentationControllerDelegate
extension LatestAdditionsOrUpdatesViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

//MARK: - PagableManagerProtocol
extension LatestAdditionsOrUpdatesViewController: PagableManagerDelegate {
    func pagableManagerDidBeginFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        self.messageLabel.text = "Loading..."
    }
    
    func pagableManagerDidFinishFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        self.updateMessageLabel()
        self.refreshSuccessfully()
        self.tableView.reloadData()
        
        switch self.type! {
        case .additions:
            Analytics.logEvent(AnalyticsEvent.FetchMore, parameters: ["Module": "Latest additions", AnalyticsParameter.SectionName: self.currentLatestAdditionType.description])
        case .updates:
            Analytics.logEvent(AnalyticsEvent.FetchMore, parameters: ["Module": "Latest updates", AnalyticsParameter.SectionName: self.currentLatestAdditionType.description])
        }
    }
    
    func pagableManagerDidFailFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        self.endRefreshing()
        self.updateMessageLabel()
        Toast.displayMessageShortly(errorLoadingMessage)
    }
    
    func pagableManagerIsBeingBlocked<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        Toast.displayBlockedMessageWithDelay()
    }
}

//MARK: - UITableViewDelegate
extension LatestAdditionsOrUpdatesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch self.currentLatestAdditionType {
        case .bands: self.didSelectRowInBandCase(at: indexPath)
        case .labels: self.didSelectRowInLabelCase(at: indexPath)
        case .artists: self.didSelectRowInArtistCase(at: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch self.currentLatestAdditionType {
        case .bands: self.willDisplayCellInBandCase(at: indexPath)
        case .labels: self.willDisplayCellInLabelCase(at: indexPath)
        case .artists: self.willDisplayCellInArtistCase(at: indexPath)
        }
    }
}

//MARK: - UITableViewDataSource
extension LatestAdditionsOrUpdatesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.refreshControl.isRefreshing {
            return 0
        }
        
        switch self.currentLatestAdditionType {
        case .bands: return self.numberOfRowsInBandCase()
        case .labels: return self.numberOfRowsInLabelCase()
        case .artists: return self.numberOfRowsInArtistCase()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.currentLatestAdditionType {
        case .bands: return self.cellForRowsInBandCase(at: indexPath)
        case .labels: return self.cellForRowsInLabelCase(at: indexPath)
        case .artists: return self.cellForRowsInArtistCase(at: indexPath)
        }
    }
}

//MARK: - MonthListViewControllerDelegate
extension LatestAdditionsOrUpdatesViewController: MonthListViewControllerDelegate {
    func didSelectAMonth(_ month: MonthInYear) {
        self.selectedMonth = month
        self.initPagableManagers()
        self.refresh()
        
        switch self.type! {
        case .additions:
            Analytics.logEvent(AnalyticsEvent.ChangeMonthInLatestAdditions, parameters: [AnalyticsParameter.Month: self.selectedMonth.shortDisplayString])
        case .updates:
            Analytics.logEvent(AnalyticsEvent.ChangeMonthInLatestUpdates, parameters: [AnalyticsParameter.Month: self.selectedMonth.shortDisplayString])
        }
    }
}

//MARK: - BandAdditionOrUpdate
extension LatestAdditionsOrUpdatesViewController {
    private func numberOfRowsInBandCase() -> Int {
        switch self.type! {
        case .additions:
            guard let _ = self.bandAdditionPagableManager else {
                return 0
            }
            
            if self.bandAdditionPagableManager.moreToLoad {
                return self.bandAdditionPagableManager.objects.count + 1
            }
            return self.bandAdditionPagableManager.objects.count
        case .updates:
            guard let _ = self.bandUpdatePagableManager else {
                return 0
            }
            
            if self.bandUpdatePagableManager.moreToLoad {
                return self.bandUpdatePagableManager.objects.count + 1
            }
            return self.bandUpdatePagableManager.objects.count
        }
    }
    
    private func cellForRowsInBandCase(at indexPath: IndexPath) -> UITableViewCell {
        switch self.type! {
        case .additions: return self.cellForRowsInBandAdditionCase(at: indexPath)
        case .updates: return self.cellForRowsInBandUpdateCase(at: indexPath)
        }
    }
    
    private func cellForRowsInBandAdditionCase(at indexPath: IndexPath) -> UITableViewCell {
        if self.bandAdditionPagableManager.moreToLoad && indexPath.row == self.bandAdditionPagableManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let cell = BandAdditionOrUpdateTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let band = self.bandAdditionPagableManager.objects[indexPath.row]
        cell.fill(with: band)
        return cell
    }
    
    private func cellForRowsInBandUpdateCase(at indexPath: IndexPath) -> UITableViewCell {
        if self.bandUpdatePagableManager.moreToLoad && indexPath.row == self.bandUpdatePagableManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let cell = BandAdditionOrUpdateTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let band = self.bandUpdatePagableManager.objects[indexPath.row]
        cell.fill(with: band)
        return cell
    }
    
    private func didSelectRowInBandCase(at indexPath: IndexPath) {
        var bandURLString: String?
        switch self.type! {
        case .additions:
            let band = self.bandAdditionPagableManager.objects[indexPath.row]
            bandURLString = band.urlString
            
            Analytics.logEvent(AnalyticsEvent.SelectAnItemInLatestAdditions, parameters: [AnalyticsParameter.ItemType: "Band", AnalyticsParameter.BandName: band.name, AnalyticsParameter.BandID: band.id])
            
        case .updates:
            let band = self.bandUpdatePagableManager.objects[indexPath.row]
            bandURLString = band.urlString
            
            Analytics.logEvent(AnalyticsEvent.SelectAnItemInLatestUpdates, parameters: [AnalyticsParameter.ItemType: "Band", AnalyticsParameter.BandName: band.name, AnalyticsParameter.BandID: band.id])
        }
        
        if let `bandURLString` = bandURLString {
            self.pushBandDetailViewController(urlString: bandURLString, animated: true)
        }
    }
    
    private func willDisplayCellInBandCase(at indexPath: IndexPath) {
        switch self.type! {
        case .additions:
            if self.bandAdditionPagableManager.moreToLoad && indexPath.row == self.bandAdditionPagableManager.objects.count {
                self.bandAdditionPagableManager.fetch()
            } else if !self.bandAdditionPagableManager.moreToLoad && indexPath.row == self.bandAdditionPagableManager.objects.count - 1 {
                Toast.displayMessageShortly(endOfListMessage)
            }
        case .updates:
            if self.bandUpdatePagableManager.moreToLoad && indexPath.row == self.bandUpdatePagableManager.objects.count {
                self.bandUpdatePagableManager.fetch()
            } else if !self.bandUpdatePagableManager.moreToLoad && indexPath.row == self.bandUpdatePagableManager.objects.count - 1 {
                Toast.displayMessageShortly(endOfListMessage)
            }
        }
    }
}

//MARK: - LabelAdditionOrUpdate
extension LatestAdditionsOrUpdatesViewController {
    private func numberOfRowsInLabelCase() -> Int {
        switch self.type! {
        case .additions:
            guard let _ = self.labelAdditionPagableManager else {
                return 0
            }
            
            if self.labelAdditionPagableManager.moreToLoad {
                return self.labelAdditionPagableManager.objects.count + 1
            }
            return self.labelAdditionPagableManager.objects.count
            
        case .updates:
            guard let _ = self.labelUpdatePagableManager else {
                return 0
            }
            
            if self.labelUpdatePagableManager.moreToLoad {
                return self.labelUpdatePagableManager.objects.count + 1
            }
            return self.labelUpdatePagableManager.objects.count
        }
    }
    
    private func cellForRowsInLabelCase(at indexPath: IndexPath) -> UITableViewCell {
        switch self.type! {
        case .additions: return self.cellForRowsInLabelAdditionCase(at: indexPath)
        case .updates: return self.cellForRowsInLabelUpdateCase(at: indexPath)
        }
    }
    
    private func cellForRowsInLabelAdditionCase(at indexPath: IndexPath) -> UITableViewCell {
        if self.labelAdditionPagableManager.moreToLoad && indexPath.row == self.labelAdditionPagableManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let cell = LabelAdditionOrUpdateTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let label = self.labelAdditionPagableManager.objects[indexPath.row]
        cell.fill(with: label)
        return cell
    }
    
    private func cellForRowsInLabelUpdateCase(at indexPath: IndexPath) -> UITableViewCell {
        if self.labelUpdatePagableManager.moreToLoad && indexPath.row == self.labelUpdatePagableManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let cell = LabelAdditionOrUpdateTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let label = self.labelUpdatePagableManager.objects[indexPath.row]
        cell.fill(with: label)
        return cell
    }
    
    private func didSelectRowInLabelCase(at indexPath: IndexPath) {
        var labelURLString: String?
        switch self.type! {
        case .additions:
            let label = self.labelAdditionPagableManager.objects[indexPath.row]
            labelURLString = label.urlString
            
            Analytics.logEvent(AnalyticsEvent.SelectAnItemInLatestAdditions, parameters: [AnalyticsParameter.ItemType: "Label", AnalyticsParameter.LabelName: label.name, AnalyticsParameter.LabelID: label.id])
            
        case .updates:
            let label = self.labelUpdatePagableManager.objects[indexPath.row]
            labelURLString = label.urlString
            
            Analytics.logEvent(AnalyticsEvent.SelectAnItemInLatestUpdates, parameters: [AnalyticsParameter.ItemType: "Label", AnalyticsParameter.LabelName: label.name, AnalyticsParameter.LabelID: label.id])
        }
        
        if let labelURLString = labelURLString {
            self.pushLabelDetailViewController(urlString: labelURLString, animated: true)
        }
    }
    
    private func willDisplayCellInLabelCase(at indexPath: IndexPath) {
        switch self.type! {
        case .additions:
            if self.labelAdditionPagableManager.moreToLoad && indexPath.row == self.labelAdditionPagableManager.objects.count {
                self.labelAdditionPagableManager.fetch()
                
            } else if !self.labelAdditionPagableManager.moreToLoad && indexPath.row == self.labelAdditionPagableManager.objects.count - 1 {
                Toast.displayMessageShortly(endOfListMessage)
            }
        case .updates:
            if self.labelUpdatePagableManager.moreToLoad && indexPath.row == self.labelUpdatePagableManager.objects.count {
                self.labelUpdatePagableManager.fetch()
                
            } else if !self.labelUpdatePagableManager.moreToLoad && indexPath.row == self.labelUpdatePagableManager.objects.count - 1 {
                Toast.displayMessageShortly(endOfListMessage)
            }
        }
    }
}

//MARK: - ArtistAdditionOrUpdate
extension LatestAdditionsOrUpdatesViewController {
    private func numberOfRowsInArtistCase() -> Int {
        switch self.type! {
        case .additions:
            guard let _ = self.artistAdditionPagableManager else {
                return 0
            }
            
            if self.artistAdditionPagableManager.moreToLoad {
                return self.artistAdditionPagableManager.objects.count + 1
            }
            return self.artistAdditionPagableManager.objects.count
        case .updates:
            guard let _ = self.artistUpdatePagableManager else {
                return 0
            }
            
            if self.artistUpdatePagableManager.moreToLoad {
                return self.artistUpdatePagableManager.objects.count + 1
            }
            return self.artistUpdatePagableManager.objects.count
        }
    }
    
    private func cellForRowsInArtistCase(at indexPath: IndexPath) -> UITableViewCell {
        switch self.type! {
        case .additions: return self.cellForRowsInArtistAdditionCase(at: indexPath)
        case .updates: return self.cellForRowsInArtistUpdateCase(at: indexPath)
        }
    }
    
    private func cellForRowsInArtistAdditionCase(at indexPath: IndexPath) -> UITableViewCell {
        if self.artistAdditionPagableManager.moreToLoad && indexPath.row == self.artistAdditionPagableManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let cell = ArtistAdditionOrUpdateTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        let artist = self.artistAdditionPagableManager.objects[indexPath.row]
        cell.fill(with: artist)
        return cell
    }
    
    private func cellForRowsInArtistUpdateCase(at indexPath: IndexPath) -> UITableViewCell {
        if self.artistUpdatePagableManager.moreToLoad && indexPath.row == self.artistUpdatePagableManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let cell = ArtistAdditionOrUpdateTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        let artist = self.artistUpdatePagableManager.objects[indexPath.row]
        cell.fill(with: artist)
        return cell
    }
    
    private func didSelectRowInArtistCase(at indexPath: IndexPath) {
        var artist: ArtistAdditionOrUpdate?
        switch self.type! {
        case .additions:
            artist = self.artistAdditionPagableManager.objects[indexPath.row]
            
            Analytics.logEvent(AnalyticsEvent.SelectAnItemInLatestAdditions, parameters: [AnalyticsParameter.ItemType: "Artist", AnalyticsParameter.ArtistName: artist!.nameInBand, AnalyticsParameter.ArtistID: artist!.id])
            
        case .updates:
            artist = self.artistUpdatePagableManager.objects[indexPath.row]
            
            Analytics.logEvent(AnalyticsEvent.SelectAnItemInLatestUpdates, parameters: [AnalyticsParameter.ItemType: "Artist", AnalyticsParameter.ArtistName: artist!.nameInBand, AnalyticsParameter.ArtistID: artist!.id])
        }
        
        if let `artist` = artist {
            self.takeActionFor(actionableObject: artist)
        }
    }
    
    private func willDisplayCellInArtistCase(at indexPath: IndexPath) {
        switch self.type! {
        case .additions:
            if self.artistAdditionPagableManager.moreToLoad && indexPath.row == self.artistAdditionPagableManager.objects.count {
                self.artistAdditionPagableManager.fetch()
                
            } else if !self.artistAdditionPagableManager.moreToLoad && indexPath.row == self.artistAdditionPagableManager.objects.count - 1 {
                Toast.displayMessageShortly(endOfListMessage)
            }
        case .updates:
            if self.artistUpdatePagableManager.moreToLoad && indexPath.row == self.artistUpdatePagableManager.objects.count {
                self.artistUpdatePagableManager.fetch()
                
            } else if !self.artistUpdatePagableManager.moreToLoad && indexPath.row == self.artistUpdatePagableManager.objects.count - 1 {
                Toast.displayMessageShortly(endOfListMessage)
            }
        }
    }
}
