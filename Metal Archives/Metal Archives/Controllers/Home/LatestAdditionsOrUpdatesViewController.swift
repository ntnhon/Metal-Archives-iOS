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

final class LatestAdditionsOrUpdatesViewController: RefreshableViewController {
    enum Mode {
        case additions, updates
    }
    
    @IBOutlet private weak var latestAdditionsOrUpdatesNavigationBarView: LatestAdditionsOrUpdatesNavigationBarView!
    var currentAdditionOrUpdateType: AdditionOrUpdateType!
    private var parameterOptions: [String: String]! = ["<YEAR_MONTH>": monthList[0].requestParameterString]
    private var selectedMonth: MonthInYear = monthList[0] {
        didSet {
            latestAdditionsOrUpdatesNavigationBarView.setMonthButtonTitle(selectedMonth.shortDisplayString)
            parameterOptions = ["<YEAR_MONTH>": selectedMonth.requestParameterString]
        }
    }
    
    var mode: LatestAdditionsOrUpdatesViewController.Mode!
    
    private var bandAdditionPagableManager: PagableManager<BandAddition>!
    private var bandUpdatePagableManager: PagableManager<BandUpdate>!
    
    private var labelAdditionPagableManager: PagableManager<LabelAddition>!
    private var labelUpdatePagableManager: PagableManager<LabelUpdate>!
    
    private var artistAdditionPagableManager: PagableManager<ArtistAddition>!
    private var artistUpdatePagableManager: PagableManager<ArtistUpdate>!
    
    deinit {
        print("LatestAdditionsOrUpdatesViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initPagableManagers()
        handleLatestAdditionsOrUpdatesNavigationBarViewActions()
        fetchData()
    }
    
    override func initAppearance() {
        super.initAppearance()
        tableView.contentInset = UIEdgeInsets(top: segmentedNavigationBarViewHeightWithoutTopInset, left: 0, bottom: 0, right: 0)
        
        LoadingTableViewCell.register(with: tableView)
        BandAdditionOrUpdateTableViewCell.register(with: tableView)
        LabelAdditionOrUpdateTableViewCell.register(with: tableView)
        ArtistAdditionOrUpdateTableViewCell.register(with: tableView)
    }
    
    override func refresh() {
        switch currentAdditionOrUpdateType! {
        case .bands:
            if mode! == .additions {
                initBandAdditionPagableManager()
                tableView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    self.bandAdditionPagableManager.fetch()
                }
            } else {
                initBandUpdatePagableManager()
                tableView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    self.bandUpdatePagableManager.fetch()
                }
            }
        case .labels:
            if mode! == .additions {
                initLabelAdditionPagableManager()
                tableView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    self.labelAdditionPagableManager.fetch()
                }
            } else {
                initLabelUpdatePagableManager()
                tableView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    self.labelUpdatePagableManager.fetch()
                }
            }
        case .artists:
            if mode! == .additions {
                initArtistAdditionPagableManager()
                tableView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    self.artistAdditionPagableManager.fetch()
                }
            } else {
                initArtistUpdatePagableManager()
                tableView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    self.artistUpdatePagableManager.fetch()
                }
            }
        }
        
        switch mode! {
        case .additions:
            Analytics.logEvent("refresh_latest_additions", parameters: ["section": currentAdditionOrUpdateType.description])
        case .updates:
            Analytics.logEvent("refresh_latest_updates", parameters: ["section": currentAdditionOrUpdateType.description])
        }
        
    }
    
    private func updateMessageLabel() {
        var count: Int?
        var total: Int?
        switch currentAdditionOrUpdateType! {
        case .bands:
            if mode! == .additions {
                count = bandAdditionPagableManager.objects.count
                total = bandAdditionPagableManager.totalRecords
            } else {
                count = bandUpdatePagableManager.objects.count
                total = bandUpdatePagableManager.totalRecords
            }
        case .labels:
            if mode! == .additions {
                count = labelAdditionPagableManager.objects.count
                total = labelAdditionPagableManager.totalRecords
            } else {
                count = labelUpdatePagableManager.objects.count
                total = labelUpdatePagableManager.totalRecords
            }
        case .artists:
            if mode! == .additions {
                count = artistAdditionPagableManager.objects.count
                total = artistAdditionPagableManager.totalRecords
            } else {
                count = artistUpdatePagableManager.objects.count
                total = artistUpdatePagableManager.totalRecords
            }
        }
        
        if let `count` = count, let `total` = total {
            latestAdditionsOrUpdatesNavigationBarView.setMessage("Loaded \(count) of \(total)")
        } else {
            latestAdditionsOrUpdatesNavigationBarView.setMessage("No result found")
        }
    }
    
    private func handleLatestAdditionsOrUpdatesNavigationBarViewActions() {
        let thisMonthString = monthList[0].shortDisplayString
        latestAdditionsOrUpdatesNavigationBarView.setMonthButtonTitle(thisMonthString)
        
        latestAdditionsOrUpdatesNavigationBarView.setAdditionOrUpdateType(currentAdditionOrUpdateType)
        
        latestAdditionsOrUpdatesNavigationBarView.didTapBackButton = { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
        
        latestAdditionsOrUpdatesNavigationBarView.didTapMonthButton = { [unowned self] in
            let monthListViewController = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "MonthListViewController") as! MonthListViewController
            
            monthListViewController.modalPresentationStyle = .popover
            monthListViewController.popoverPresentationController?.permittedArrowDirections = .any
            monthListViewController.preferredContentSize = CGSize(width: 220, height: screenHeight*2/3)
            
            monthListViewController.popoverPresentationController?.delegate = self
            monthListViewController.popoverPresentationController?.sourceView = self.latestAdditionsOrUpdatesNavigationBarView.monthButton
            
            monthListViewController.delegate = self
            monthListViewController.selectedMonth = self.selectedMonth
            self.present(monthListViewController, animated: true, completion: nil)
        }
        
        latestAdditionsOrUpdatesNavigationBarView.didChangeAdditionOrUpdateType = { [unowned self] in
            self.currentAdditionOrUpdateType = self.latestAdditionsOrUpdatesNavigationBarView.selectedAdditionOrUpdateType
            self.updateMessageLabel()
            self.tableView.scrollRectToVisible(CGRect.zero, animated: false)
            self.tableView.reloadData()
            
            switch self.mode! {
            case .additions:
                Analytics.logEvent("change_section_in_latest_additions", parameters: ["section": self.currentAdditionOrUpdateType.description])
            case .updates:
                Analytics.logEvent("change_section_in_latest_updates", parameters: ["section": self.currentAdditionOrUpdateType.description])
            }
        }
    }
    
    private func fetchData() {
        switch currentAdditionOrUpdateType! {
        case .bands:
            if mode! == .additions {
                bandAdditionPagableManager.fetch()
            } else {
                bandUpdatePagableManager.fetch()
            }
        case .labels:
            if mode! == .additions {
                labelAdditionPagableManager.fetch()
            } else {
                labelUpdatePagableManager.fetch()
            }
        case .artists:
            if mode! == .additions {
                artistAdditionPagableManager.fetch()
            } else {
                artistUpdatePagableManager.fetch()
            }
        }
    }
    
    private func initPagableManagers() {
        switch mode! {
        case .additions:
            initBandAdditionPagableManager()
            initLabelAdditionPagableManager()
            initArtistAdditionPagableManager()
        case .updates:
            initBandUpdatePagableManager()
            initLabelUpdatePagableManager()
            initArtistUpdatePagableManager()
        }
    }
    
    private func initBandAdditionPagableManager() {
        bandAdditionPagableManager = PagableManager<BandAddition>(options: parameterOptions)
        bandAdditionPagableManager.delegate = self
    }
    
    private func initBandUpdatePagableManager() {
        bandUpdatePagableManager = PagableManager<BandUpdate>(options: parameterOptions)
        bandUpdatePagableManager.delegate = self
    }
    
    private func initLabelAdditionPagableManager() {
        labelAdditionPagableManager = PagableManager<LabelAddition>(options: parameterOptions)
        labelAdditionPagableManager.delegate = self
    }
    
    private func initLabelUpdatePagableManager() {
        labelUpdatePagableManager = PagableManager<LabelUpdate>(options: parameterOptions)
        labelUpdatePagableManager.delegate = self
    }
    
    private func initArtistAdditionPagableManager() {
        artistAdditionPagableManager = PagableManager<ArtistAddition>(options: parameterOptions)
        artistAdditionPagableManager.delegate = self
    }
    
    private func initArtistUpdatePagableManager() {
        artistUpdatePagableManager = PagableManager<ArtistUpdate>(options: parameterOptions)
        artistUpdatePagableManager.delegate = self
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
        latestAdditionsOrUpdatesNavigationBarView.setMessage("Loading...")
    }
    
    func pagableManagerDidFinishFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        updateMessageLabel()
        refreshSuccessfully()
        tableView.reloadData()
    }
    
    func pagableManagerDidFailFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        endRefreshing()
        updateMessageLabel()
        Toast.displayMessageShortly(errorLoadingMessage)
    }
    
    func pagableManagerIsBeingBlocked<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        Toast.displayBlockedMessageWithDelay()
    }
}

// MARK: - UIScrollViewDelegate
extension LatestAdditionsOrUpdatesViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        latestAdditionsOrUpdatesNavigationBarView.transformWith(scrollView)
    }
}

//MARK: - UITableViewDelegate
extension LatestAdditionsOrUpdatesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch currentAdditionOrUpdateType! {
        case .bands: didSelectRowInBandCase(at: indexPath)
        case .labels: didSelectRowInLabelCase(at: indexPath)
        case .artists: didSelectRowInArtistCase(at: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch currentAdditionOrUpdateType! {
        case .bands: willDisplayCellInBandCase(at: indexPath)
        case .labels: willDisplayCellInLabelCase(at: indexPath)
        case .artists: willDisplayCellInArtistCase(at: indexPath)
        }
    }
}

//MARK: - UITableViewDataSource
extension LatestAdditionsOrUpdatesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if refreshControl.isRefreshing {
            return 0
        }
        
        switch currentAdditionOrUpdateType! {
        case .bands: return numberOfRowsInBandCase()
        case .labels: return numberOfRowsInLabelCase()
        case .artists: return numberOfRowsInArtistCase()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch currentAdditionOrUpdateType! {
        case .bands: return cellForRowsInBandCase(at: indexPath)
        case .labels: return cellForRowsInLabelCase(at: indexPath)
        case .artists: return cellForRowsInArtistCase(at: indexPath)
        }
    }
}

//MARK: - MonthListViewControllerDelegate
extension LatestAdditionsOrUpdatesViewController: MonthListViewControllerDelegate {
    func didSelectAMonth(_ month: MonthInYear) {
        selectedMonth = month
        initPagableManagers()
        refresh()
        
        switch mode! {
        case .additions:
            Analytics.logEvent("change_month_in_latest_additions", parameters: ["month": selectedMonth.shortDisplayString])
        case .updates:
            Analytics.logEvent("change_month_in_latest_updates", parameters: ["month": selectedMonth.shortDisplayString])
        }
    }
}

//MARK: - BandAdditionOrUpdate
extension LatestAdditionsOrUpdatesViewController {
    private func numberOfRowsInBandCase() -> Int {
        switch mode! {
        case .additions:
            guard let _ = bandAdditionPagableManager else {
                return 0
            }
            
            if bandAdditionPagableManager.moreToLoad {
                return bandAdditionPagableManager.objects.count + 1
            }
            return bandAdditionPagableManager.objects.count
        case .updates:
            guard let _ = bandUpdatePagableManager else {
                return 0
            }
            
            if bandUpdatePagableManager.moreToLoad {
                return bandUpdatePagableManager.objects.count + 1
            }
            return bandUpdatePagableManager.objects.count
        }
    }
    
    private func cellForRowsInBandCase(at indexPath: IndexPath) -> UITableViewCell {
        switch mode! {
        case .additions: return cellForRowsInBandAdditionCase(at: indexPath)
        case .updates: return cellForRowsInBandUpdateCase(at: indexPath)
        }
    }
    
    private func cellForRowsInBandAdditionCase(at indexPath: IndexPath) -> UITableViewCell {
        if bandAdditionPagableManager.moreToLoad && indexPath.row == bandAdditionPagableManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let cell = BandAdditionOrUpdateTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let band = bandAdditionPagableManager.objects[indexPath.row]
        cell.fill(with: band)
        
        cell.tappedThumbnailImageView = { [unowned self] in
            self.presentPhotoViewerWithCacheChecking(photoUrlString: band.imageURLString, description: band.name, fromImageView: cell.thumbnailImageView)
        }
        
        return cell
    }
    
    private func cellForRowsInBandUpdateCase(at indexPath: IndexPath) -> UITableViewCell {
        if bandUpdatePagableManager.moreToLoad && indexPath.row == bandUpdatePagableManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let cell = BandAdditionOrUpdateTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let band = bandUpdatePagableManager.objects[indexPath.row]
        cell.fill(with: band)
        
        cell.tappedThumbnailImageView = { [unowned self] in
            self.presentPhotoViewerWithCacheChecking(photoUrlString: band.imageURLString, description: band.name, fromImageView: cell.thumbnailImageView)
        }
        
        return cell
    }
    
    private func didSelectRowInBandCase(at indexPath: IndexPath) {
        var bandURLString: String?
        switch mode! {
        case .additions:
            let band = bandAdditionPagableManager.objects[indexPath.row]
            bandURLString = band.urlString
            
            Analytics.logEvent("select_an_item_in_latest_additions", parameters: ["band": "Band", "band_name": band.name, "band_id": band.id])
            
        case .updates:
            let band = bandUpdatePagableManager.objects[indexPath.row]
            bandURLString = band.urlString
            
            Analytics.logEvent("select_an_item_in_latest_updates", parameters: ["item_type": "Band", "band_name": band.name, "band_id": band.id])
        }
        
        if let `bandURLString` = bandURLString {
            pushBandDetailViewController(urlString: bandURLString, animated: true)
        }
    }
    
    private func willDisplayCellInBandCase(at indexPath: IndexPath) {
        switch mode! {
        case .additions:
            if bandAdditionPagableManager.moreToLoad && indexPath.row == bandAdditionPagableManager.objects.count {
                bandAdditionPagableManager.fetch()
            } else if !bandAdditionPagableManager.moreToLoad && indexPath.row == bandAdditionPagableManager.objects.count - 1 {
                Toast.displayMessageShortly(endOfListMessage)
            }
        case .updates:
            if bandUpdatePagableManager.moreToLoad && indexPath.row == bandUpdatePagableManager.objects.count {
                bandUpdatePagableManager.fetch()
            } else if !bandUpdatePagableManager.moreToLoad && indexPath.row == bandUpdatePagableManager.objects.count - 1 {
                Toast.displayMessageShortly(endOfListMessage)
            }
        }
    }
}

//MARK: - LabelAdditionOrUpdate
extension LatestAdditionsOrUpdatesViewController {
    private func numberOfRowsInLabelCase() -> Int {
        switch mode! {
        case .additions:
            guard let _ = labelAdditionPagableManager else {
                return 0
            }
            
            if labelAdditionPagableManager.moreToLoad {
                return labelAdditionPagableManager.objects.count + 1
            }
            return labelAdditionPagableManager.objects.count
            
        case .updates:
            guard let _ = labelUpdatePagableManager else {
                return 0
            }
            
            if labelUpdatePagableManager.moreToLoad {
                return labelUpdatePagableManager.objects.count + 1
            }
            return labelUpdatePagableManager.objects.count
        }
    }
    
    private func cellForRowsInLabelCase(at indexPath: IndexPath) -> UITableViewCell {
        switch mode! {
        case .additions: return cellForRowsInLabelAdditionCase(at: indexPath)
        case .updates: return cellForRowsInLabelUpdateCase(at: indexPath)
        }
    }
    
    private func cellForRowsInLabelAdditionCase(at indexPath: IndexPath) -> UITableViewCell {
        if labelAdditionPagableManager.moreToLoad && indexPath.row == labelAdditionPagableManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let cell = LabelAdditionOrUpdateTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let label = labelAdditionPagableManager.objects[indexPath.row]
        cell.fill(with: label)
        
        cell.tappedThumbnailImageView = { [unowned self] in
            self.presentPhotoViewerWithCacheChecking(photoUrlString: label.imageURLString, description: label.name, fromImageView: cell.thumbnailImageView)
        }
        
        return cell
    }
    
    private func cellForRowsInLabelUpdateCase(at indexPath: IndexPath) -> UITableViewCell {
        if labelUpdatePagableManager.moreToLoad && indexPath.row == labelUpdatePagableManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let cell = LabelAdditionOrUpdateTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let label = labelUpdatePagableManager.objects[indexPath.row]
        cell.fill(with: label)
        
        cell.tappedThumbnailImageView = { [unowned self] in
            self.presentPhotoViewerWithCacheChecking(photoUrlString: label.imageURLString, description: label.name, fromImageView: cell.thumbnailImageView)
        }
        
        return cell
    }
    
    private func didSelectRowInLabelCase(at indexPath: IndexPath) {
        var labelURLString: String?
        switch mode! {
        case .additions:
            let label = labelAdditionPagableManager.objects[indexPath.row]
            labelURLString = label.urlString
            
            Analytics.logEvent("select_an_item_in_latest_additions", parameters: ["item_type": "Label", "label_name": label.name, "label_id": label.id])
            
        case .updates:
            let label = labelUpdatePagableManager.objects[indexPath.row]
            labelURLString = label.urlString
            
            Analytics.logEvent("select_an_item_in_latest_updates", parameters: ["item_type": "Label", "label_name": label.name, "label_id": label.id])
        }
        
        if let labelURLString = labelURLString {
            pushLabelDetailViewController(urlString: labelURLString, animated: true)
        }
    }
    
    private func willDisplayCellInLabelCase(at indexPath: IndexPath) {
        switch mode! {
        case .additions:
            if labelAdditionPagableManager.moreToLoad && indexPath.row == labelAdditionPagableManager.objects.count {
                labelAdditionPagableManager.fetch()
                
            } else if !labelAdditionPagableManager.moreToLoad && indexPath.row == labelAdditionPagableManager.objects.count - 1 {
                Toast.displayMessageShortly(endOfListMessage)
            }
        case .updates:
            if labelUpdatePagableManager.moreToLoad && indexPath.row == labelUpdatePagableManager.objects.count {
                labelUpdatePagableManager.fetch()
                
            } else if !labelUpdatePagableManager.moreToLoad && indexPath.row == labelUpdatePagableManager.objects.count - 1 {
                Toast.displayMessageShortly(endOfListMessage)
            }
        }
    }
}

//MARK: - ArtistAdditionOrUpdate
extension LatestAdditionsOrUpdatesViewController {
    private func numberOfRowsInArtistCase() -> Int {
        switch mode! {
        case .additions:
            guard let _ = artistAdditionPagableManager else {
                return 0
            }
            
            if artistAdditionPagableManager.moreToLoad {
                return artistAdditionPagableManager.objects.count + 1
            }
            return artistAdditionPagableManager.objects.count
        case .updates:
            guard let _ = artistUpdatePagableManager else {
                return 0
            }
            
            if artistUpdatePagableManager.moreToLoad {
                return artistUpdatePagableManager.objects.count + 1
            }
            return artistUpdatePagableManager.objects.count
        }
    }
    
    private func cellForRowsInArtistCase(at indexPath: IndexPath) -> UITableViewCell {
        switch mode! {
        case .additions: return cellForRowsInArtistAdditionCase(at: indexPath)
        case .updates: return cellForRowsInArtistUpdateCase(at: indexPath)
        }
    }
    
    private func cellForRowsInArtistAdditionCase(at indexPath: IndexPath) -> UITableViewCell {
        if artistAdditionPagableManager.moreToLoad && indexPath.row == artistAdditionPagableManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let cell = ArtistAdditionOrUpdateTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let artist = artistAdditionPagableManager.objects[indexPath.row]
        cell.fill(with: artist)
        
        cell.tappedThumbnailImageView = { [unowned self] in
            self.presentPhotoViewerWithCacheChecking(photoUrlString: artist.imageURLString, description: artist.nameInBand, fromImageView: cell.thumbnailImageView)
        }
        
        return cell
    }
    
    private func cellForRowsInArtistUpdateCase(at indexPath: IndexPath) -> UITableViewCell {
        if artistUpdatePagableManager.moreToLoad && indexPath.row == artistUpdatePagableManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let cell = ArtistAdditionOrUpdateTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let artist = artistUpdatePagableManager.objects[indexPath.row]
        cell.fill(with: artist)
        
        cell.tappedThumbnailImageView = { [unowned self] in
            self.presentPhotoViewerWithCacheChecking(photoUrlString: artist.imageURLString, description: artist.nameInBand, fromImageView: cell.thumbnailImageView)
        }
        
        return cell
    }
    
    private func didSelectRowInArtistCase(at indexPath: IndexPath) {
        var artist: ArtistAdditionOrUpdate?
        switch mode! {
        case .additions:
            artist = artistAdditionPagableManager.objects[indexPath.row]
            
            Analytics.logEvent("select_an_item_in_latest_additions", parameters: ["item_type": "Artist", "artist_name": artist!.nameInBand, "artist_id": artist!.id])
            
        case .updates:
            artist = artistUpdatePagableManager.objects[indexPath.row]
            
            Analytics.logEvent("select_an_item_in_latest_updates", parameters: ["item_type": "Artist", "artist_name": artist!.nameInBand, "artist_id": artist!.id])
        }
        
        if let `artist` = artist {
            takeActionFor(actionableObject: artist)
        }
    }
    
    private func willDisplayCellInArtistCase(at indexPath: IndexPath) {
        switch mode! {
        case .additions:
            if artistAdditionPagableManager.moreToLoad && indexPath.row == artistAdditionPagableManager.objects.count {
                artistAdditionPagableManager.fetch()
                
            } else if !artistAdditionPagableManager.moreToLoad && indexPath.row == artistAdditionPagableManager.objects.count - 1 {
                Toast.displayMessageShortly(endOfListMessage)
            }
        case .updates:
            if artistUpdatePagableManager.moreToLoad && indexPath.row == artistUpdatePagableManager.objects.count {
                artistUpdatePagableManager.fetch()
                
            } else if !artistUpdatePagableManager.moreToLoad && indexPath.row == artistUpdatePagableManager.objects.count - 1 {
                Toast.displayMessageShortly(endOfListMessage)
            }
        }
    }
}
