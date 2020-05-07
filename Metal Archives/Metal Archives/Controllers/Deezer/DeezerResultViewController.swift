//
//  DeezerViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 20/07/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Toaster
import FirebaseAnalytics

final class DeezerResultViewController: BaseViewController {
    @IBOutlet private weak var simpleNavigationBarView: SimpleNavigationBarView!
    @IBOutlet private weak var tableView: UITableView!
    
    var deezerableType: DeezerableType!
    var deezerableSearchTerm: String!
    
    private var deezerArtistData: DeezerData<DeezerArtist>?
    private var deezerAlbumData: DeezerData<DeezerAlbum>?
    
    private var requestUrlString: String {
        let baseURL = "https://api.deezer.com/search/<TYPE>?q=<TERM>"
        return baseURL.replacingOccurrences(of: "<TYPE>", with: deezerableType.requestParameterName).replacingOccurrences(of: "<TERM>", with: deezerableSearchTerm)
    }
    
    deinit {
        print("DeezerResultViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSimpleNavigationBarView()
        configureTableView()
        fetch()
    }
    
    private func initSimpleNavigationBarView() {
        simpleNavigationBarView.setAlphaForBackgroundAndTitleLabel(1)
        simpleNavigationBarView.setRightButtonIcon(#imageLiteral(resourceName: "info"))
        
        switch deezerableType! {
        case .album: simpleNavigationBarView.setTitle("Results for album \"\(deezerableSearchTerm!)\"")
        case .artist: simpleNavigationBarView.setTitle("Results for band \"\(deezerableSearchTerm!)\"")
        }
        
        
        simpleNavigationBarView.didTapLeftButton = { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
        
        simpleNavigationBarView.didTapRightButton = { [unowned self] in
            let searchExplanationViewController = UIStoryboard(name: "Explanation", bundle: nil).instantiateViewController(withIdentifier: "ExplanationViewController") as! ExplanationViewController
            searchExplanationViewController.type = .deezer
            searchExplanationViewController.presentFromBottom(in: self)
        }
    }
    
    private func configureTableView() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.contentInset = .init(top: 0, left: 0, bottom: UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0, right: 0)
        
        DeezerArtistTableViewCell.register(with: tableView)
        DeezerAlbumTableViewCell.register(with: tableView)
        SimpleTableViewCell.register(with: tableView)
    }
    
    private func fetch() {
        guard let formattedRequestUrlString = requestUrlString.addingPercentEncoding(withAllowedCharacters: customURLQueryAllowedCharacterSet) else { return }
        showHUD()
        
        switch deezerableType! {
        case .artist:
            RequestService.Deezer.fetchDeezerArtist(urlString: formattedRequestUrlString) { [weak self] result in
                self?.hideHUD()
                switch result {
                case .success(let deezerData):
                    self?.deezerArtistData = deezerData
                    self?.tableView.reloadData()
                    
                case .failure(let error):
                    Toast.displayMessageShortly(error.localizedDescription)
                    self?.navigationController?.popViewController(animated: true)
                }
            }
            
        case .album:
            RequestService.Deezer.fetchDeezerAlbum(urlString: formattedRequestUrlString) { [weak self] result in
                self?.hideHUD()
                switch result {
                case .success(let deezerData):
                    self?.deezerAlbumData = deezerData
                    self?.tableView.reloadData()
                    
                case .failure(let error):
                    Toast.displayMessageShortly(error.localizedDescription)
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
        
        Analytics.logEvent("view_deezer_result", parameters: ["type": deezerableType.requestParameterName, "term": deezerableSearchTerm ?? ""])
    }
}

// MARK: - UITableViewDelegate
extension DeezerResultViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch deezerableType! {
        case .artist:
            guard let deezerArtistData = deezerArtistData, deezerArtistData.data.count > 0 else { return }
            let deezerArtist = deezerArtistData.data[indexPath.row]
            Analytics.logEvent("select_deezer_result", parameters: ["type": "artist", "artist": deezerArtist.name])
            fetchAndPushArtistTopTracks(deezerArtist)
            
        case .album:
            guard let deezerAlbumData = deezerAlbumData, deezerAlbumData.data.count > 0 else { return }
            let deezerAlbum = deezerAlbumData.data[indexPath.row]
            Analytics.logEvent("select_deezer_result", parameters: ["type": "album", "album": deezerAlbum.title])
            fetchAndPushAlbumTracklist(deezerAlbum)
        }
    }
    
    private func fetchAndPushArtistTopTracks(_ artist: DeezerArtist) {
        guard let formattedRequestUrlString = artist.tracklist.addingPercentEncoding(withAllowedCharacters: customURLQueryAllowedCharacterSet) else { return }
        showHUD()
        
        RequestService.Deezer.fetchDeezerTrack(urlString: formattedRequestUrlString) { [weak self] result in
            self?.hideHUD()
            switch result {
            case .success(let deezerData):
                if deezerData.data.count > 0 {
                    self?.pushDeezerTracklist(with: artist, deezerTrackData: deezerData)
                } else {
                    self?.fetchAndPushArtistAlbums(artist)
                }
                
            case .failure(let error):
                Toast.displayMessageShortly(error.localizedDescription)
            }
        }
    }
    
    private func fetchAndPushArtistAlbums(_ artist: DeezerArtist) {
        let requestUrlString = "https://api.deezer.com/artist/\(artist.id)/albums"
        
        guard let formattedRequestUrlString = requestUrlString.addingPercentEncoding(withAllowedCharacters: customURLQueryAllowedCharacterSet) else { return }
        showHUD()
        
        RequestService.Deezer.fetchDeezerAlbum(urlString: formattedRequestUrlString) { [weak self] result in
            self?.hideHUD()
            switch result {
            case .success(let deezerData):
                self?.pushDeezerAlbums(with: artist, deezerAlbumData: deezerData)
                
            case .failure(let error):
                Toast.displayMessageShortly(error.localizedDescription)
            }
        }
    }
    
    private func pushDeezerTracklist(with artist: DeezerArtist, deezerTrackData: DeezerData<DeezerTrack>) {
        let deezerTracklistViewController = UIStoryboard(name: "Deezer", bundle: nil).instantiateViewController(withIdentifier: "DeezerTracklistViewController") as! DeezerTracklistViewController
        deezerTracklistViewController.albumTitleOrArtistName = artist.name
        deezerTracklistViewController.photoUrlString = artist.picture_xl
        deezerTracklistViewController.topTrack = true
        deezerTracklistViewController.deezerTrackData = deezerTrackData
        
        navigationController?.pushViewController(deezerTracklistViewController, animated: true)
    }
    
    private func pushDeezerAlbums(with artist: DeezerArtist, deezerAlbumData: DeezerData<DeezerAlbum>) {
        let deezerAlbumViewController = UIStoryboard(name: "Deezer", bundle: nil).instantiateViewController(withIdentifier: "DeezerAlbumViewController") as! DeezerAlbumViewController
        deezerAlbumViewController.artist = artist
        deezerAlbumViewController.deezerAlbumData = deezerAlbumData
        
        navigationController?.pushViewController(deezerAlbumViewController, animated: true)
    }
    
    private func fetchAndPushAlbumTracklist(_ album: DeezerAlbum) {
        guard let formattedRequestUrlString = album.tracklist.addingPercentEncoding(withAllowedCharacters: customURLQueryAllowedCharacterSet) else { return }
        showHUD()
        RequestService.Deezer.fetchDeezerTrack(urlString: formattedRequestUrlString) { [weak self] result in
            self?.hideHUD()
            switch result {
            case .success(let deezerData):
                self?.pushDeezerTracklist(with: album, deezerTrackData: deezerData)
                
            case .failure(let error):
                Toast.displayMessageShortly(error.localizedDescription)
            }
        }
    }
    
    private func pushDeezerTracklist(with album: DeezerAlbum, deezerTrackData: DeezerData<DeezerTrack>) {
        let deezerTracklistViewController = UIStoryboard(name: "Deezer", bundle: nil).instantiateViewController(withIdentifier: "DeezerTracklistViewController") as! DeezerTracklistViewController
        deezerTracklistViewController.albumTitleOrArtistName = album.title
        deezerTracklistViewController.photoUrlString = album.cover_xl
        deezerTracklistViewController.topTrack = false
        deezerTracklistViewController.deezerTrackData = deezerTrackData
        
        navigationController?.pushViewController(deezerTracklistViewController, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension DeezerResultViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch deezerableType! {
        case .artist:
            guard let deezerArtistData = deezerArtistData else {
                return 0
            }
            return max(deezerArtistData.data.count, 1)
            
        case .album:
            guard let deezerAlbumData = deezerAlbumData else {
                return 0
            }
            return max(deezerAlbumData.data.count, 1)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch deezerableType! {
        case .artist: return artistCell(forRowAt: indexPath)
        case .album: return albumCell(forRowAt: indexPath)
        }
    }
    
    private func artistCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let deezerArtistData = deezerArtistData else {
            return UITableViewCell()
        }
        
        if deezerArtistData.data.count == 0 {
            let simpleCell = SimpleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            simpleCell.displayAsItalicBodyText()
            simpleCell.fill(with: "No result found.")
            return simpleCell
        }
        
        let cell = DeezerArtistTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let deezerArtist = deezerArtistData.data[indexPath.row]
        cell.fill(with: deezerArtist)
        cell.tappedThumbnailImageView = { [unowned self] in
            self.presentPhotoViewer(photoUrlString: deezerArtist.picture_xl, description: deezerArtist.name, fromImageView: cell.thumbnailImageView)
            Analytics.logEvent("view_deezer_result_thumbnail", parameters: ["type": "artist", "artist": deezerArtist.name])
        }
        
        return cell
    }
    
    private func albumCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let deezerAlbumData = deezerAlbumData else {
            return UITableViewCell()
        }
        
        if deezerAlbumData.data.count == 0 {
            let simpleCell = SimpleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            simpleCell.displayAsItalicBodyText()
            simpleCell.fill(with: "No result found.")
            return simpleCell
        }
        
        let cell = DeezerAlbumTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let deezerAlbum = deezerAlbumData.data[indexPath.row]
        cell.fill(with: deezerAlbum)
        cell.tappedThumbnailImageView = { [unowned self] in
            self.presentPhotoViewer(photoUrlString: deezerAlbum.cover_xl, description: deezerAlbum.title, fromImageView: cell.thumbnailImageView)
            Analytics.logEvent("view_deezer_result_thumbnail", parameters: ["type": "album", "album": deezerAlbum.title])
        }
        return cell
    }
}
