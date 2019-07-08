//
//  SimpleSearchResultViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 05/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Toaster
import FirebaseAnalytics
import CoreData

final class SimpleSearchResultViewController: BaseViewController {
    @IBOutlet private weak var simpleNavigationBarView: SimpleNavigationBarView!
    @IBOutlet private weak var tableView: UITableView!
    
    var simpleSearchType: SimpleSearchType!
    var searchTerm: String!
    var isFeelingLucky: Bool = false
    private var wasLucky: Bool = false
    
    //Band name
    private var bandNameResultManager: PagableManager<SimpleSearchResultBandName>!
    
    //Music genre
    private var musicGenreResultManager: PagableManager<SimpleSearchResultMusicGenre>!
    
    //Lyrical themes
    private var lyricalThemesResultManager: PagableManager<SimpleSearchResultLyricalThemes>!
    
    //Album title
    private var albumTitleResultManager: PagableManager<SimpleSearchResultAlbumTitle>!
    
    //Song title
    private var songTitleResultManager: PagableManager<SimpleSearchResultSongTitle>!
    
    //Label name
    private var labelNameResultManager: PagableManager<SimpleSearchResultLabelName>!
    
    //Artist
    private var artistResultManager: PagableManager<SimpleSearchResultArtist>!
    
    // Core Data
    private let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    deinit {
        print("SimpleSearchResultViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initManager()
        handleSimpleNavigationBarViewActions()
        fetchData()
    }
    
    private func handleSimpleNavigationBarViewActions() {
        simpleNavigationBarView.setAlphaForBackgroundAndTitleLabel(1)
        simpleNavigationBarView.setRightButtonIcon(nil)
        
        simpleNavigationBarView.didTapLeftButton = { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func initAppearance() {
        super.initAppearance()
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.contentInset = UIEdgeInsets(top: baseNavigationBarViewHeightWithoutTopInset, left: 0, bottom: 0, right: 0)
        tableView.backgroundColor = Settings.currentTheme.backgroundColor
        tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        
        LoadingTableViewCell.register(with: tableView)
        SimpleBandNameOrMusicGenreTableViewCell.register(with: tableView)
        SimpleLyricalThemesTableViewCell.register(with: tableView)
        SimpleAlbumTitleTableViewCell.register(with: tableView)
        SimpleSongTitleTableViewCell.register(with: tableView)
        SimpleLabelTableViewCell.register(with: tableView)
        SimpleArtistTableViewCell.register(with: tableView)
    }
    
    private func initManager() {

        switch simpleSearchType! {
        case .bandName:
            bandNameResultManager = PagableManager<SimpleSearchResultBandName>(options: ["<QUERY>": searchTerm])
            bandNameResultManager.delegate = self
        case .musicGenre:
            musicGenreResultManager = PagableManager<SimpleSearchResultMusicGenre>(options: ["<QUERY>": searchTerm])
            musicGenreResultManager.delegate = self
        case .lyricalThemes:
            lyricalThemesResultManager = PagableManager<SimpleSearchResultLyricalThemes>(options: ["<QUERY>": searchTerm])
            lyricalThemesResultManager.delegate = self
        case .albumTitle:
            albumTitleResultManager = PagableManager<SimpleSearchResultAlbumTitle>(options: ["<QUERY>": searchTerm])
            albumTitleResultManager.delegate = self
        case .songTitle:
            songTitleResultManager = PagableManager<SimpleSearchResultSongTitle>(options: ["<QUERY>": searchTerm])
            songTitleResultManager.delegate = self
        case .label:
            labelNameResultManager = PagableManager<SimpleSearchResultLabelName>(options: ["<QUERY>": searchTerm])
            labelNameResultManager.delegate = self
        case .artist:
            artistResultManager = PagableManager<SimpleSearchResultArtist>(options: ["<QUERY>": searchTerm])
            artistResultManager.delegate = self
        }
    }
    
    private func fetchData() {
        switch simpleSearchType! {
        case .bandName: bandNameResultManager.fetch()
        case .musicGenre: musicGenreResultManager.fetch()
        case .lyricalThemes: lyricalThemesResultManager.fetch()
        case .albumTitle: albumTitleResultManager.fetch()
        case .songTitle: songTitleResultManager.fetch()
        case .label: labelNameResultManager.fetch()
        case .artist: artistResultManager.fetch()
        }
    }
    
    private func updateStatusMessage() {
        var loaded: Int?
        var total: Int?
        
        switch simpleSearchType! {
        case .bandName:
            loaded = bandNameResultManager.objects.count
            total = bandNameResultManager.totalRecords
        case .musicGenre:
            loaded = musicGenreResultManager.objects.count
            total = musicGenreResultManager.totalRecords
        case .lyricalThemes:
            loaded = lyricalThemesResultManager.objects.count
            total = lyricalThemesResultManager.totalRecords
        case .albumTitle:
            loaded = albumTitleResultManager.objects.count
            total = albumTitleResultManager.totalRecords
        case .songTitle:
            loaded = songTitleResultManager.objects.count
            total = songTitleResultManager.totalRecords
        case .label:
            loaded = labelNameResultManager.objects.count
            total = labelNameResultManager.totalRecords
        case .artist:
            loaded = artistResultManager.objects.count
            total = artistResultManager.totalRecords
        }
        
        if let loaded = loaded, let total = total, let searchTerm = searchTerm {
            simpleNavigationBarView.setTitle("\"\(searchTerm)\" (\(loaded) of \(total))")
        }
    }
    
    private func checkLuck() {
        switch simpleSearchType! {
        case .bandName:
            if bandNameResultManager.objects.count == 1 ||
                (isFeelingLucky && !wasLucky && bandNameResultManager.objects.count > 1) {
                let result = bandNameResultManager.objects[0]
                pushBandDetailViewController(urlString: result.band.urlString, animated: true)
            }
            
        case .musicGenre:
            if musicGenreResultManager.objects.count == 1 ||
                (isFeelingLucky && !wasLucky && musicGenreResultManager.objects.count > 1) {
                let result = musicGenreResultManager.objects[0]
                pushBandDetailViewController(urlString: result.band.urlString, animated: true)
            }
            
        case .lyricalThemes:
            if lyricalThemesResultManager.objects.count == 1 ||
                (isFeelingLucky && !wasLucky && lyricalThemesResultManager.objects.count > 1) {
                let result = lyricalThemesResultManager.objects[0]
                pushBandDetailViewController(urlString: result.band.urlString, animated: true)
            }
            
        case .albumTitle:
            if albumTitleResultManager.objects.count == 1 ||
                (isFeelingLucky && !wasLucky && albumTitleResultManager.objects.count > 1) {
                let result = albumTitleResultManager.objects[0]
                pushReleaseDetailViewController(urlString: result.release.urlString, animated: true)
            }
            
        case .songTitle:
            if songTitleResultManager.objects.count == 1 ||
                (isFeelingLucky && !wasLucky && songTitleResultManager.objects.count > 1) {
                let result = songTitleResultManager.objects[0]
                pushReleaseDetailViewController(urlString: result.release.urlString, animated: true)
            }
            
        case .label:
            if labelNameResultManager.objects.count == 1 ||
                (isFeelingLucky && !wasLucky && labelNameResultManager.objects.count > 1) {
                let result = labelNameResultManager.objects[0]
                pushLabelDetailViewController(urlString: result.label.urlString, animated: true)
            }
            
        case .artist:
            if artistResultManager.objects.count == 1 ||
                (isFeelingLucky && !wasLucky && artistResultManager.objects.count > 1) {
                let result = artistResultManager.objects[0]
                pushArtistDetailViewController(urlString: result.artist.urlString, animated: true)
            }
        }
        
        wasLucky = true
    }
}

//MARK: - PagableManagerProtocol
extension SimpleSearchResultViewController: PagableManagerDelegate {
    func pagableManagerDidFinishFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        guard let _ = pagableManager.totalRecords else {
            Toast.displayMessageShortly(noResultMessage)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.navigationController?.popViewController(animated: true)
            }
            return
        }
        
        updateStatusMessage()
        checkLuck()
        tableView.reloadData()
        
        Analytics.logEvent(AnalyticsEvent.FetchMore, parameters: nil)
    }
    
    func pagableManagerDidFailFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        Toast.displayMessageShortly(errorLoadingMessage)
    }
    
    func pagableManagerIsBeingBlocked<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        Toast.displayBlockedMessageWithDelay()
    }
}

// MARK: - HistoryRecordable
extension SimpleSearchResultViewController: HistoryRecordable {
    func loaded(withNameOrTitle nameOrTitle: String, thumbnailUrlString: String?) {
        let entity = NSEntityDescription.entity(forEntityName: "SearchHistory", in: managedContext)!
        let searchHistory = SearchHistory(entity: entity, insertInto: managedContext)
        searchHistory.nameOrTitle = nameOrTitle
        searchHistory.thumbnailUrlString = thumbnailUrlString
        do {
            try managedContext.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}

//MARK: - UITableViewDelegate
extension SimpleSearchResultViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch simpleSearchType! {
        case .bandName: didSelectBandNameResult(at: indexPath)
        case .musicGenre: didSelectMusicGenreResult(at: indexPath)
        case .lyricalThemes: didSelectLyricalThemesResult(at: indexPath)
        case .albumTitle: didSelectAlbumTitleResult(at: indexPath)
        case .songTitle: didSelectSongTitleResult(at: indexPath)
        case .label: didSelectLabelResult(at: indexPath)
        case .artist: didSelectArtistResult(at: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch simpleSearchType! {
        case .bandName: willDisplayBandNameResultCell(at: indexPath)
        case .musicGenre: willDisplayMusicGenreResultCell(at: indexPath)
        case .lyricalThemes: willDisplayLyricalThemesResultCell(at: indexPath)
        case .albumTitle: willDisplayAlbumTitleResultCell(at: indexPath)
        case .songTitle: willDisplaySongTitleResultCell(at: indexPath)
        case .label: willDisplayLabelResultCell(at: indexPath)
        case .artist: willDisplayArtistResultCell(at: indexPath)
        }
    }
}

//MARK: - UITableViewDataSource
extension SimpleSearchResultViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch simpleSearchType! {
        case .bandName: return numberOfRowsForBandNameResults()
        case .musicGenre: return numberOfRowsForMusicGenreResults()
        case .lyricalThemes: return numberOfRowsForLyricalThemesResults()
        case .albumTitle: return numberOfRowsForAlbumTitleResults()
        case .songTitle: return numberOfRowsForSongTitleResults()
        case .label: return numberOfRowsForLabelResults()
        case .artist: return numberOfRowsForArtistResults()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch simpleSearchType! {
        case .bandName: return cellForBandNameResult(at: indexPath)
        case .musicGenre: return cellForMusicGenreResult(at: indexPath)
        case .lyricalThemes: return cellForLyricalThemesResult(at: indexPath)
        case .albumTitle: return cellForAlbumTitleResult(at: indexPath)
        case .songTitle: return cellForSongTitleResult(at: indexPath)
        case .label: return cellForLabelResult(at: indexPath)
        case .artist: return cellForArtistResult(at: indexPath)
        }
    }
}

// MARK: - SimpleSearchResultViewController
extension SimpleSearchResultViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        simpleNavigationBarView.transformWith(scrollView)
    }
}

//MARK: - Band name
extension SimpleSearchResultViewController {
    private func numberOfRowsForBandNameResults() -> Int {
        guard let manager = bandNameResultManager else {
            return 0
        }
        
        if manager.moreToLoad {
            return manager.objects.count + 1
        }
        
        return manager.objects.count
    }
    
    private func cellForBandNameResult(at indexPath: IndexPath) -> UITableViewCell {
        if bandNameResultManager.moreToLoad && indexPath.row == bandNameResultManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let result = bandNameResultManager.objects[indexPath.row]
        let cell = SimpleBandNameOrMusicGenreTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.fill(with: result)
        cell.tappedThumbnailImageView = { [unowned self]  in
            self.presentPhotoViewerWithCacheChecking(photoUrlString: result.imageURLString, description: result.band.name, fromImageView: cell.thumbnailImageView)
        }
        return cell
    }
    
    private func didSelectBandNameResult(at indexPath: IndexPath) {
        if bandNameResultManager.objects.indices.contains(indexPath.row) {
            let result = bandNameResultManager.objects[indexPath.row]
            pushBandDetailViewController(urlString: result.band.urlString, animated: true)
            
            Analytics.logEvent(AnalyticsEvent.SelectASimpleSearchResult, parameters: [AnalyticsParameter.SearchType: "Band name", AnalyticsParameter.BandName: result.band.name, AnalyticsParameter.BandID: result.band.id])
        }
    }
    
    private func willDisplayBandNameResultCell(at indexPath: IndexPath) {
        guard let _ = bandNameResultManager.totalRecords else {
            return
        }
        
        if bandNameResultManager.moreToLoad && indexPath.row == bandNameResultManager.objects.count {
            bandNameResultManager.fetch()
        } else if !bandNameResultManager.moreToLoad && indexPath.row == bandNameResultManager.objects.count - 1 {
            Toast.displayMessageShortly(endOfListMessage)
        }
    }
}

//MARK: - Music genre
extension SimpleSearchResultViewController {
    private func numberOfRowsForMusicGenreResults() -> Int {
        guard let manager = musicGenreResultManager else {
            return 0
        }
        
        if manager.moreToLoad {
            return manager.objects.count + 1
        }
        
        return manager.objects.count
    }
    
    private func cellForMusicGenreResult(at indexPath: IndexPath) -> UITableViewCell {
        if musicGenreResultManager.moreToLoad && indexPath.row == musicGenreResultManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let result = musicGenreResultManager.objects[indexPath.row]
        let cell = SimpleBandNameOrMusicGenreTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.fill(with: result)
        cell.tappedThumbnailImageView = { [unowned self] in
            self.presentPhotoViewerWithCacheChecking(photoUrlString: result.imageURLString, description: result.band.name, fromImageView: cell.thumbnailImageView)
        }
        return cell
    }
    
    private func didSelectMusicGenreResult(at indexPath: IndexPath) {
        if musicGenreResultManager.objects.indices.contains(indexPath.row) {
            let result = musicGenreResultManager.objects[indexPath.row]
            pushBandDetailViewController(urlString: result.band.urlString, animated: true)
            
            Analytics.logEvent(AnalyticsEvent.SelectASimpleSearchResult, parameters: [AnalyticsParameter.SearchType: "Music genre", AnalyticsParameter.BandName: result.band.name, AnalyticsParameter.BandID: result.band.id])
        }
    }
    
    private func willDisplayMusicGenreResultCell(at indexPath: IndexPath) {
        guard let _ = musicGenreResultManager.totalRecords else {
            return
        }
        
        if musicGenreResultManager.moreToLoad && indexPath.row == musicGenreResultManager.objects.count {
            musicGenreResultManager.fetch()
        } else if !musicGenreResultManager.moreToLoad && indexPath.row == musicGenreResultManager.objects.count - 1 {
            Toast.displayMessageShortly(endOfListMessage)
        }
    }
}

//MARK: - Lyrical themes
extension SimpleSearchResultViewController {
    private func numberOfRowsForLyricalThemesResults() -> Int {
        guard let manager = lyricalThemesResultManager else {
            return 0
        }
        
        if manager.moreToLoad {
            return manager.objects.count + 1
        }
        
        return manager.objects.count
    }
    
    private func cellForLyricalThemesResult(at indexPath: IndexPath) -> UITableViewCell {
        if lyricalThemesResultManager.moreToLoad && indexPath.row == lyricalThemesResultManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let result = lyricalThemesResultManager.objects[indexPath.row]
        let cell = SimpleLyricalThemesTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.fill(with: result)
        cell.tappedThumbnailImageView = { [unowned self] in
            self.presentPhotoViewerWithCacheChecking(photoUrlString: result.band.imageURLString, description: result.band.name, fromImageView: cell.thumbnailImageView)
        }
        return cell
    }
    
    private func didSelectLyricalThemesResult(at indexPath: IndexPath) {
        if lyricalThemesResultManager.objects.indices.contains(indexPath.row) {
            let result = lyricalThemesResultManager.objects[indexPath.row]
            pushBandDetailViewController(urlString: result.band.urlString, animated: true)
            Analytics.logEvent(AnalyticsEvent.SelectASimpleSearchResult, parameters: [AnalyticsParameter.SearchType: "Lyrical theme", AnalyticsParameter.BandName: result.band.name, AnalyticsParameter.BandID: result.band.id])
        }
    }
    
    private func willDisplayLyricalThemesResultCell(at indexPath: IndexPath) {
        guard let _ = lyricalThemesResultManager.totalRecords else {
            return
        }
        
        if lyricalThemesResultManager.moreToLoad && indexPath.row == lyricalThemesResultManager.objects.count {
            lyricalThemesResultManager.fetch()
        } else if !lyricalThemesResultManager.moreToLoad && indexPath.row == lyricalThemesResultManager.objects.count - 1 {
            Toast.displayMessageShortly(endOfListMessage)
        }
    }
}

//MARK: - Album title
extension SimpleSearchResultViewController {
    private func numberOfRowsForAlbumTitleResults() -> Int {
        guard let manager = albumTitleResultManager else {
            return 0
        }
        
        if manager.moreToLoad {
            return manager.objects.count + 1
        }
        
        return manager.objects.count
    }
    
    private func cellForAlbumTitleResult(at indexPath: IndexPath) -> UITableViewCell {
        if albumTitleResultManager.moreToLoad && indexPath.row == albumTitleResultManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let result = albumTitleResultManager.objects[indexPath.row]
        let cell = SimpleAlbumTitleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.fill(with: result)
        cell.tappedThumbnailImageView = { [unowned self] in
            self.presentPhotoViewerWithCacheChecking(photoUrlString: result.release.imageURLString, description: result.release.title, fromImageView: cell.thumbnailImageView)
        }
        return cell
    }
    
    private func didSelectAlbumTitleResult(at indexPath: IndexPath) {
        if albumTitleResultManager.objects.indices.contains(indexPath.row) {
            let result = albumTitleResultManager.objects[indexPath.row]
            takeActionFor(actionableObject: result)
            
            Analytics.logEvent(AnalyticsEvent.SelectASimpleSearchResult, parameters: [AnalyticsParameter.SearchType: "Album title", AnalyticsParameter.BandName: result.release.title, AnalyticsParameter.BandID: result.release.id])
        }
    }
    
    private func willDisplayAlbumTitleResultCell(at indexPath: IndexPath) {
        guard let _ = albumTitleResultManager.totalRecords else {
            return
        }
        
        if albumTitleResultManager.moreToLoad && indexPath.row == albumTitleResultManager.objects.count {
            albumTitleResultManager.fetch()
        } else if !albumTitleResultManager.moreToLoad && indexPath.row == albumTitleResultManager.objects.count - 1 {
            Toast.displayMessageShortly(endOfListMessage)
        }
    }
}

//MARK: - Song title
extension SimpleSearchResultViewController {
    private func numberOfRowsForSongTitleResults() -> Int {
        guard let manager = songTitleResultManager else {
            return 0
        }
        
        if manager.moreToLoad {
            return manager.objects.count + 1
        }
        
        return manager.objects.count
    }
    
    private func cellForSongTitleResult(at indexPath: IndexPath) -> UITableViewCell {
        if songTitleResultManager.moreToLoad && indexPath.row == songTitleResultManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let result = songTitleResultManager.objects[indexPath.row]
        let cell = SimpleSongTitleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.fill(with: result)
        cell.tappedThumbnailImageView = { [unowned self] in
            self.presentPhotoViewerWithCacheChecking(photoUrlString: result.release.imageURLString, description: result.release.title, fromImageView: cell.thumbnailImageView)
        }
        return cell
    }
    
    private func didSelectSongTitleResult(at indexPath: IndexPath) {
        if songTitleResultManager.objects.indices.contains(indexPath.row) {
            let result = songTitleResultManager.objects[indexPath.row]
            takeActionFor(actionableObject: result)
            
            Analytics.logEvent(AnalyticsEvent.SelectASimpleSearchResult, parameters: [AnalyticsParameter.SearchType: "Song title", AnalyticsParameter.BandName: result.band.name])
        }
    }
    
    private func willDisplaySongTitleResultCell(at indexPath: IndexPath) {
        guard let _ = songTitleResultManager.totalRecords else {
            return
        }
        
        if songTitleResultManager.moreToLoad && indexPath.row == songTitleResultManager.objects.count {
            songTitleResultManager.fetch()
        } else if !songTitleResultManager.moreToLoad && indexPath.row == songTitleResultManager.objects.count - 1 {
            Toast.displayMessageShortly(endOfListMessage)
        }
    }
}

//MARK: - Label
extension SimpleSearchResultViewController {
    private func numberOfRowsForLabelResults() -> Int {
        guard let manager = labelNameResultManager else {
            return 0
        }
        
        if manager.moreToLoad {
            return manager.objects.count + 1
        }
        
        return manager.objects.count
    }
    
    private func cellForLabelResult(at indexPath: IndexPath) -> UITableViewCell {
        if labelNameResultManager.moreToLoad && indexPath.row == labelNameResultManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let result = labelNameResultManager.objects[indexPath.row]
        let cell = SimpleLabelTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.fill(with: result)
        cell.tappedThumbnailImageView = { [unowned self] in
            self.presentPhotoViewerWithCacheChecking(photoUrlString: result.label.imageURLString, description: result.label.name, fromImageView: cell.thumbnailImageView)
        }
        return cell
    }
    
    private func didSelectLabelResult(at indexPath: IndexPath) {
        if labelNameResultManager.objects.indices.contains(indexPath.row) {
            let result = labelNameResultManager.objects[indexPath.row]
            pushLabelDetailViewController(urlString: result.label.urlString, animated: true)
            
            Analytics.logEvent(AnalyticsEvent.SelectASimpleSearchResult, parameters: [AnalyticsParameter.SearchType: "Label", AnalyticsParameter.LabelName: result.label.name, AnalyticsParameter.LabelID: result.label.id])
        }
    }
    
    private func willDisplayLabelResultCell(at indexPath: IndexPath) {
        guard let _ = labelNameResultManager.totalRecords else {
            return
        }
        
        if labelNameResultManager.moreToLoad && indexPath.row == labelNameResultManager.objects.count {
            labelNameResultManager.fetch()
        } else if !labelNameResultManager.moreToLoad && indexPath.row == labelNameResultManager.objects.count - 1 {
            Toast.displayMessageShortly(endOfListMessage)
        }
    }
}

//MARK: - Artist
extension SimpleSearchResultViewController {
    private func numberOfRowsForArtistResults() -> Int {
        guard let manager = artistResultManager else {
            return 0
        }
        
        if manager.moreToLoad {
            return manager.objects.count + 1
        }
        
        return manager.objects.count
    }
    
    private func cellForArtistResult(at indexPath: IndexPath) -> UITableViewCell {
        if artistResultManager.moreToLoad && indexPath.row == artistResultManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let result = artistResultManager.objects[indexPath.row]
        let cell = SimpleArtistTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.fill(with: result)
        cell.tappedThumbnailImageView = { [unowned self] in
            self.presentPhotoViewerWithCacheChecking(photoUrlString: result.artist.imageURLString, description: result.artist.name, fromImageView: cell.thumbnailImageView)
        }
        return cell
    }
    
    private func didSelectArtistResult(at indexPath: IndexPath) {
        if artistResultManager.objects.indices.contains(indexPath.row) {
            let result = artistResultManager.objects[indexPath.row]
            takeActionFor(actionableObject: result)
            
            Analytics.logEvent(AnalyticsEvent.SelectASimpleSearchResult, parameters: [AnalyticsParameter.SearchType: "Artist", AnalyticsParameter.ArtistName: result.artist.name, AnalyticsParameter.ArtistID: result.artist.id])
        }
    }
    
    private func willDisplayArtistResultCell(at indexPath: IndexPath) {
        guard let _ = artistResultManager.totalRecords else {
            return
        }
        
        if artistResultManager.moreToLoad && indexPath.row == artistResultManager.objects.count {
            artistResultManager.fetch()
        } else if !artistResultManager.moreToLoad && indexPath.row == artistResultManager.objects.count - 1 {
            Toast.displayMessageShortly(endOfListMessage)
        }
    }
}
