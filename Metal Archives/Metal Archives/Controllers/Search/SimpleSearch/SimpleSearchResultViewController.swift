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

final class SimpleSearchResultViewController: BaseViewController {
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
    
    private var rightBarButtonItem: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let `searchTerm` = self.searchTerm {
            self.title = "Results for \"\(searchTerm)\""
        }
    
        self.initManager()
        self.initRightBarButtonItem()
        self.fetchData()
    }
    
    override func initAppearance() {
        super.initAppearance()
        self.tableView.backgroundColor = Settings.currentTheme.backgroundColor
        self.tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.tableFooterView = UIView(frame: .zero)
        
        LoadingTableViewCell.register(with: self.tableView)
        SimpleBandNameOrMusicGenreTableViewCell.register(with: self.tableView)
        SimpleLyricalThemesTableViewCell.register(with: self.tableView)
        SimpleAlbumTitleTableViewCell.register(with: self.tableView)
        SimpleSongTitleTableViewCell.register(with: self.tableView)
        SimpleLabelTableViewCell.register(with: self.tableView)
        SimpleArtistTableViewCell.register(with: self.tableView)
    }
    
    private func initManager() {

        switch self.simpleSearchType! {
        case .bandName:
            self.bandNameResultManager = PagableManager<SimpleSearchResultBandName>(options: ["<QUERY>": self.searchTerm])
            self.bandNameResultManager.delegate = self
        case .musicGenre:
            self.musicGenreResultManager = PagableManager<SimpleSearchResultMusicGenre>(options: ["<QUERY>": self.searchTerm])
            self.musicGenreResultManager.delegate = self
        case .lyricalThemes:
            self.lyricalThemesResultManager = PagableManager<SimpleSearchResultLyricalThemes>(options: ["<QUERY>": self.searchTerm])
            self.lyricalThemesResultManager.delegate = self
        case .albumTitle:
            self.albumTitleResultManager = PagableManager<SimpleSearchResultAlbumTitle>(options: ["<QUERY>": self.searchTerm])
            self.albumTitleResultManager.delegate = self
        case .songTitle:
            self.songTitleResultManager = PagableManager<SimpleSearchResultSongTitle>(options: ["<QUERY>": self.searchTerm])
            self.songTitleResultManager.delegate = self
        case .label:
            self.labelNameResultManager = PagableManager<SimpleSearchResultLabelName>(options: ["<QUERY>": self.searchTerm])
            self.labelNameResultManager.delegate = self
        case .artist:
            self.artistResultManager = PagableManager<SimpleSearchResultArtist>(options: ["<QUERY>": self.searchTerm])
            self.artistResultManager.delegate = self
        }
    }
    
    private func initRightBarButtonItem() {
        self.rightBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = self.rightBarButtonItem
    }
    
    private func fetchData() {
        switch self.simpleSearchType! {
        case .bandName: self.bandNameResultManager.fetch()
        case .musicGenre: self.musicGenreResultManager.fetch()
        case .lyricalThemes: self.lyricalThemesResultManager.fetch()
        case .albumTitle: self.albumTitleResultManager.fetch()
        case .songTitle: self.songTitleResultManager.fetch()
        case .label: self.labelNameResultManager.fetch()
        case .artist: self.artistResultManager.fetch()
        }
    }
    
    private func updateStatusMessage() {
        var loaded: Int?
        var total: Int?
        
        switch self.simpleSearchType! {
        case .bandName:
            loaded = self.bandNameResultManager.objects.count
            total = self.bandNameResultManager.totalRecords
        case .musicGenre:
            loaded = self.musicGenreResultManager.objects.count
            total = self.musicGenreResultManager.totalRecords
        case .lyricalThemes:
            loaded = self.lyricalThemesResultManager.objects.count
            total = self.lyricalThemesResultManager.totalRecords
        case .albumTitle:
            loaded = self.albumTitleResultManager.objects.count
            total = self.albumTitleResultManager.totalRecords
        case .songTitle:
            loaded = self.songTitleResultManager.objects.count
            total = self.songTitleResultManager.totalRecords
        case .label:
            loaded = self.labelNameResultManager.objects.count
            total = self.labelNameResultManager.totalRecords
        case .artist:
            loaded = self.artistResultManager.objects.count
            total = self.artistResultManager.totalRecords
        }
        
        if let `loaded` = loaded, let `total` = total {
            self.rightBarButtonItem.title = "Loaded \(loaded) of \(total)"
        }
    }
    
    private func checkLuck() {
        switch self.simpleSearchType! {
        case .bandName:
            if self.bandNameResultManager.objects.count == 1 ||
                (self.isFeelingLucky && !self.wasLucky && self.bandNameResultManager.objects.count > 1) {
                let result = self.bandNameResultManager.objects[0]
                self.pushBandDetailViewController(urlString: result.band.urlString, animated: true)
            }
            
        case .musicGenre:
            if self.musicGenreResultManager.objects.count == 1 ||
                (self.isFeelingLucky && !self.wasLucky && self.musicGenreResultManager.objects.count > 1) {
                let result = self.musicGenreResultManager.objects[0]
                self.pushBandDetailViewController(urlString: result.band.urlString, animated: true)
            }
            
        case .lyricalThemes:
            if self.lyricalThemesResultManager.objects.count == 1 ||
                (self.isFeelingLucky && !self.wasLucky && self.lyricalThemesResultManager.objects.count > 1) {
                let result = self.lyricalThemesResultManager.objects[0]
                self.pushBandDetailViewController(urlString: result.band.urlString, animated: true)
            }
            
        case .albumTitle:
            if self.albumTitleResultManager.objects.count == 1 ||
                (self.isFeelingLucky && !self.wasLucky && self.albumTitleResultManager.objects.count > 1) {
                let result = self.albumTitleResultManager.objects[0]
                self.pushReleaseDetailViewController(urlString: result.release.urlString, animated: true)
            }
            
        case .songTitle:
            if self.songTitleResultManager.objects.count == 1 ||
                (self.isFeelingLucky && !self.wasLucky && self.songTitleResultManager.objects.count > 1) {
                let result = self.songTitleResultManager.objects[0]
                self.pushReleaseDetailViewController(urlString: result.release.urlString, animated: true)
            }
            
        case .label:
            if self.labelNameResultManager.objects.count == 1 ||
                (self.isFeelingLucky && !self.wasLucky && self.labelNameResultManager.objects.count > 1) {
                let result = self.labelNameResultManager.objects[0]
                self.pushLabelDetailViewController(urlString: result.label.urlString, animated: true)
            }
            
        case .artist:
            if self.artistResultManager.objects.count == 1 ||
                (self.isFeelingLucky && !self.wasLucky && self.artistResultManager.objects.count > 1) {
                let result = self.artistResultManager.objects[0]
                self.pushArtistDetailViewController(urlString: result.artist.urlString, animated: true)
            }
        }
        
        self.wasLucky = true
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
        
        self.updateStatusMessage()
        self.checkLuck()
        self.tableView.reloadData()
        
        Analytics.logEvent(AnalyticsEvent.FetchMore, parameters: nil)
    }
    
    func pagableManagerDidFailFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        Toast.displayMessageShortly(errorLoadingMessage)
    }
    
    func pagableManagerIsBeingBlocked<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        Toast.displayBlockedMessageWithDelay()
    }
}

//MARK: - UITableViewDelegate
extension SimpleSearchResultViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch self.simpleSearchType! {
        case .bandName: self.didSelectBandNameResult(at: indexPath)
        case .musicGenre: self.didSelectMusicGenreResult(at: indexPath)
        case .lyricalThemes: self.didSelectLyricalThemesResult(at: indexPath)
        case .albumTitle: self.didSelectAlbumTitleResult(at: indexPath)
        case .songTitle: self.didSelectSongTitleResult(at: indexPath)
        case .label: self.didSelectLabelResult(at: indexPath)
        case .artist: self.didSelectArtistResult(at: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch self.simpleSearchType! {
        case .bandName: self.willDisplayBandNameResultCell(at: indexPath)
        case .musicGenre: self.willDisplayMusicGenreResultCell(at: indexPath)
        case .lyricalThemes: self.willDisplayLyricalThemesResultCell(at: indexPath)
        case .albumTitle: self.willDisplayAlbumTitleResultCell(at: indexPath)
        case .songTitle: self.willDisplaySongTitleResultCell(at: indexPath)
        case .label: self.willDisplayLabelResultCell(at: indexPath)
        case .artist: self.willDisplayArtistResultCell(at: indexPath)
        }
    }
}

//MARK: - UITableViewDataSource
extension SimpleSearchResultViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.simpleSearchType! {
        case .bandName: return self.numberOfRowsForBandNameResults()
        case .musicGenre: return self.numberOfRowsForMusicGenreResults()
        case .lyricalThemes: return self.numberOfRowsForLyricalThemesResults()
        case .albumTitle: return self.numberOfRowsForAlbumTitleResults()
        case .songTitle: return self.numberOfRowsForSongTitleResults()
        case .label: return self.numberOfRowsForLabelResults()
        case .artist: return self.numberOfRowsForArtistResults()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.simpleSearchType! {
        case .bandName: return self.cellForBandNameResult(at: indexPath)
        case .musicGenre: return self.cellForMusicGenreResult(at: indexPath)
        case .lyricalThemes: return self.cellForLyricalThemesResult(at: indexPath)
        case .albumTitle: return self.cellForAlbumTitleResult(at: indexPath)
        case .songTitle: return self.cellForSongTitleResult(at: indexPath)
        case .label: return self.cellForLabelResult(at: indexPath)
        case .artist: return self.cellForArtistResult(at: indexPath)
        }
    }
}

//MARK: - Band name
extension SimpleSearchResultViewController {
    private func numberOfRowsForBandNameResults() -> Int {
        guard let manager = self.bandNameResultManager else {
            return 0
        }
        
        if manager.moreToLoad {
            return manager.objects.count + 1
        }
        
        return manager.objects.count
    }
    
    private func cellForBandNameResult(at indexPath: IndexPath) -> UITableViewCell {
        if self.bandNameResultManager.moreToLoad && indexPath.row == self.bandNameResultManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let result = self.bandNameResultManager.objects[indexPath.row]
        let cell = SimpleBandNameOrMusicGenreTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        cell.fill(with: result)
        
        return cell
    }
    
    private func didSelectBandNameResult(at indexPath: IndexPath) {
        if self.bandNameResultManager.objects.indices.contains(indexPath.row) {
            let result = self.bandNameResultManager.objects[indexPath.row]
            self.pushBandDetailViewController(urlString: result.band.urlString, animated: true)
            
            Analytics.logEvent(AnalyticsEvent.SelectASimpleSearchResult, parameters: [AnalyticsParameter.SearchType: "Band name", AnalyticsParameter.BandName: result.band.name, AnalyticsParameter.BandID: result.band.id])
        }
    }
    
    private func willDisplayBandNameResultCell(at indexPath: IndexPath) {
        guard let _ = self.bandNameResultManager.totalRecords else {
            return
        }
        
        if self.bandNameResultManager.moreToLoad && indexPath.row == self.bandNameResultManager.objects.count {
            self.bandNameResultManager.fetch()
        } else if !self.bandNameResultManager.moreToLoad && indexPath.row == self.bandNameResultManager.objects.count - 1 {
            Toast.displayMessageShortly(endOfListMessage)
        }
    }
}

//MARK: - Music genre
extension SimpleSearchResultViewController {
    private func numberOfRowsForMusicGenreResults() -> Int {
        guard let manager = self.musicGenreResultManager else {
            return 0
        }
        
        if manager.moreToLoad {
            return manager.objects.count + 1
        }
        
        return manager.objects.count
    }
    
    private func cellForMusicGenreResult(at indexPath: IndexPath) -> UITableViewCell {
        if self.musicGenreResultManager.moreToLoad && indexPath.row == self.musicGenreResultManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let result = self.musicGenreResultManager.objects[indexPath.row]
        let cell = SimpleBandNameOrMusicGenreTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        cell.fill(with: result)
        
        return cell
    }
    
    private func didSelectMusicGenreResult(at indexPath: IndexPath) {
        if self.musicGenreResultManager.objects.indices.contains(indexPath.row) {
            let result = self.musicGenreResultManager.objects[indexPath.row]
            self.pushBandDetailViewController(urlString: result.band.urlString, animated: true)
            
            Analytics.logEvent(AnalyticsEvent.SelectASimpleSearchResult, parameters: [AnalyticsParameter.SearchType: "Music genre", AnalyticsParameter.BandName: result.band.name, AnalyticsParameter.BandID: result.band.id])
        }
    }
    
    private func willDisplayMusicGenreResultCell(at indexPath: IndexPath) {
        guard let _ = self.musicGenreResultManager.totalRecords else {
            return
        }
        
        if self.musicGenreResultManager.moreToLoad && indexPath.row == self.musicGenreResultManager.objects.count {
            self.musicGenreResultManager.fetch()
        } else if !self.musicGenreResultManager.moreToLoad && indexPath.row == self.musicGenreResultManager.objects.count - 1 {
            Toast.displayMessageShortly(endOfListMessage)
        }
    }
}

//MARK: - Lyrical themes
extension SimpleSearchResultViewController {
    private func numberOfRowsForLyricalThemesResults() -> Int {
        guard let manager = self.lyricalThemesResultManager else {
            return 0
        }
        
        if manager.moreToLoad {
            return manager.objects.count + 1
        }
        
        return manager.objects.count
    }
    
    private func cellForLyricalThemesResult(at indexPath: IndexPath) -> UITableViewCell {
        if self.lyricalThemesResultManager.moreToLoad && indexPath.row == self.lyricalThemesResultManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let result = self.lyricalThemesResultManager.objects[indexPath.row]
        let cell = SimpleLyricalThemesTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.fill(with: result)
        
        return cell
    }
    
    private func didSelectLyricalThemesResult(at indexPath: IndexPath) {
        if self.lyricalThemesResultManager.objects.indices.contains(indexPath.row) {
            let result = self.lyricalThemesResultManager.objects[indexPath.row]
            self.pushBandDetailViewController(urlString: result.band.urlString, animated: true)
            
            Analytics.logEvent(AnalyticsEvent.SelectASimpleSearchResult, parameters: [AnalyticsParameter.SearchType: "Lyrical theme", AnalyticsParameter.BandName: result.band.name, AnalyticsParameter.BandID: result.band.id])
        }
    }
    
    private func willDisplayLyricalThemesResultCell(at indexPath: IndexPath) {
        guard let _ = self.lyricalThemesResultManager.totalRecords else {
            return
        }
        
        if self.lyricalThemesResultManager.moreToLoad && indexPath.row == self.lyricalThemesResultManager.objects.count {
            self.lyricalThemesResultManager.fetch()
        } else if !self.lyricalThemesResultManager.moreToLoad && indexPath.row == self.lyricalThemesResultManager.objects.count - 1 {
            Toast.displayMessageShortly(endOfListMessage)
        }
    }
}

//MARK: - Album title
extension SimpleSearchResultViewController {
    private func numberOfRowsForAlbumTitleResults() -> Int {
        guard let manager = self.albumTitleResultManager else {
            return 0
        }
        
        if manager.moreToLoad {
            return manager.objects.count + 1
        }
        
        return manager.objects.count
    }
    
    private func cellForAlbumTitleResult(at indexPath: IndexPath) -> UITableViewCell {
        if self.albumTitleResultManager.moreToLoad && indexPath.row == self.albumTitleResultManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let result = self.albumTitleResultManager.objects[indexPath.row]
        let cell = SimpleAlbumTitleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.fill(with: result)
        
        return cell
    }
    
    private func didSelectAlbumTitleResult(at indexPath: IndexPath) {
        if self.albumTitleResultManager.objects.indices.contains(indexPath.row) {
            let result = self.albumTitleResultManager.objects[indexPath.row]
            self.takeActionFor(actionableObject: result)
            
            Analytics.logEvent(AnalyticsEvent.SelectASimpleSearchResult, parameters: [AnalyticsParameter.SearchType: "Album title", AnalyticsParameter.BandName: result.release.name, AnalyticsParameter.BandID: result.release.id])
        }
    }
    
    private func willDisplayAlbumTitleResultCell(at indexPath: IndexPath) {
        guard let _ = self.albumTitleResultManager.totalRecords else {
            return
        }
        
        if self.albumTitleResultManager.moreToLoad && indexPath.row == self.albumTitleResultManager.objects.count {
            self.albumTitleResultManager.fetch()
        } else if !self.albumTitleResultManager.moreToLoad && indexPath.row == self.albumTitleResultManager.objects.count - 1 {
            Toast.displayMessageShortly(endOfListMessage)
        }
    }
}

//MARK: - Song title
extension SimpleSearchResultViewController {
    private func numberOfRowsForSongTitleResults() -> Int {
        guard let manager = self.songTitleResultManager else {
            return 0
        }
        
        if manager.moreToLoad {
            return manager.objects.count + 1
        }
        
        return manager.objects.count
    }
    
    private func cellForSongTitleResult(at indexPath: IndexPath) -> UITableViewCell {
        if self.songTitleResultManager.moreToLoad && indexPath.row == self.songTitleResultManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let result = self.songTitleResultManager.objects[indexPath.row]
        let cell = SimpleSongTitleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.fill(with: result)
        
        return cell
    }
    
    private func didSelectSongTitleResult(at indexPath: IndexPath) {
        if self.songTitleResultManager.objects.indices.contains(indexPath.row) {
            let result = self.songTitleResultManager.objects[indexPath.row]
            self.takeActionFor(actionableObject: result)
            
            Analytics.logEvent(AnalyticsEvent.SelectASimpleSearchResult, parameters: [AnalyticsParameter.SearchType: "Song title", AnalyticsParameter.BandName: result.band.name])
        }
    }
    
    private func willDisplaySongTitleResultCell(at indexPath: IndexPath) {
        guard let _ = self.songTitleResultManager.totalRecords else {
            return
        }
        
        if self.songTitleResultManager.moreToLoad && indexPath.row == self.songTitleResultManager.objects.count {
            self.songTitleResultManager.fetch()
        } else if !self.songTitleResultManager.moreToLoad && indexPath.row == self.songTitleResultManager.objects.count - 1 {
            Toast.displayMessageShortly(endOfListMessage)
        }
    }
}

//MARK: - Label
extension SimpleSearchResultViewController {
    private func numberOfRowsForLabelResults() -> Int {
        guard let manager = self.labelNameResultManager else {
            return 0
        }
        
        if manager.moreToLoad {
            return manager.objects.count + 1
        }
        
        return manager.objects.count
    }
    
    private func cellForLabelResult(at indexPath: IndexPath) -> UITableViewCell {
        if self.labelNameResultManager.moreToLoad && indexPath.row == self.labelNameResultManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let result = self.labelNameResultManager.objects[indexPath.row]
        let cell = SimpleLabelTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.fill(with: result)
        
        return cell
    }
    
    private func didSelectLabelResult(at indexPath: IndexPath) {
        if self.labelNameResultManager.objects.indices.contains(indexPath.row) {
            let result = self.labelNameResultManager.objects[indexPath.row]
            self.pushLabelDetailViewController(urlString: result.label.urlString, animated: true)
            
            Analytics.logEvent(AnalyticsEvent.SelectASimpleSearchResult, parameters: [AnalyticsParameter.SearchType: "Label", AnalyticsParameter.LabelName: result.label.name, AnalyticsParameter.LabelID: result.label.id])
        }
    }
    
    private func willDisplayLabelResultCell(at indexPath: IndexPath) {
        guard let _ = self.labelNameResultManager.totalRecords else {
            return
        }
        
        if self.labelNameResultManager.moreToLoad && indexPath.row == self.labelNameResultManager.objects.count {
            self.labelNameResultManager.fetch()
        } else if !self.labelNameResultManager.moreToLoad && indexPath.row == self.labelNameResultManager.objects.count - 1 {
            Toast.displayMessageShortly(endOfListMessage)
        }
    }
}

//MARK: - Artist
extension SimpleSearchResultViewController {
    private func numberOfRowsForArtistResults() -> Int {
        guard let manager = self.artistResultManager else {
            return 0
        }
        
        if manager.moreToLoad {
            return manager.objects.count + 1
        }
        
        return manager.objects.count
    }
    
    private func cellForArtistResult(at indexPath: IndexPath) -> UITableViewCell {
        if self.artistResultManager.moreToLoad && indexPath.row == self.artistResultManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let result = self.artistResultManager.objects[indexPath.row]
        let cell = SimpleArtistTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.fill(with: result)
        
        return cell
    }
    
    private func didSelectArtistResult(at indexPath: IndexPath) {
        if self.artistResultManager.objects.indices.contains(indexPath.row) {
            let result = self.artistResultManager.objects[indexPath.row]
            self.takeActionFor(actionableObject: result)
            
            Analytics.logEvent(AnalyticsEvent.SelectASimpleSearchResult, parameters: [AnalyticsParameter.SearchType: "Artist", AnalyticsParameter.ArtistName: result.artist.name, AnalyticsParameter.ArtistID: result.artist.id])
        }
    }
    
    private func willDisplayArtistResultCell(at indexPath: IndexPath) {
        guard let _ = self.artistResultManager.totalRecords else {
            return
        }
        
        if self.artistResultManager.moreToLoad && indexPath.row == self.artistResultManager.objects.count {
            self.artistResultManager.fetch()
        } else if !self.artistResultManager.moreToLoad && indexPath.row == self.artistResultManager.objects.count - 1 {
            Toast.displayMessageShortly(endOfListMessage)
        }
    }
}
