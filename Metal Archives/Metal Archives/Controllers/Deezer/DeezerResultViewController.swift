//
//  DeezerViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 20/07/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Toaster

final class DeezerResultViewController: BaseViewController {
    @IBOutlet private weak var simpleNavigationBarView: SimpleNavigationBarView!
    @IBOutlet private weak var tableView: UITableView!
    
    var deezerableType: DeezerableType!
    var deezerableSearchTerm: String!
    
    private var deezerArtistData: DeezerData<DeezerArtist>?
    
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
        simpleNavigationBarView.setRightButtonIcon(#imageLiteral(resourceName: "about"))
        simpleNavigationBarView.setTitle("Deezer for \"\(deezerableSearchTerm!)\"")
        
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
        tableView.backgroundColor = .clear
        tableView.tableFooterView = UIView(frame: .zero)
        
        DeezerArtistTableViewCell.register(with: tableView)
        SimpleTableViewCell.register(with: tableView)
    }
    
    private func fetch() {
        guard let formattedRequestUrlString = requestUrlString.addingPercentEncoding(withAllowedCharacters: customURLQueryAllowedCharacterSet) else { return }
        
        switch deezerableType! {
        case .artist:
            Service.shared.fetchDeezerArtist(urlString: formattedRequestUrlString) { [weak self] (deezerData, error) in
                
                if let _ = error {
                    Toast.displayMessageShortly(errorLoadingMessage)
                    self?.navigationController?.popViewController(animated: true)
                } else if let deezerData = deezerData {
                    self?.deezerArtistData = deezerData
                    
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                }
            }
            
        case .album:
            break
        }
    }
}

// MARK: - UITableViewDelegate
extension DeezerResultViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch deezerableType! {
        case .artist:
            guard let deezerArtistData = deezerArtistData else { return }
            let deezerArtist = deezerArtistData.data[indexPath.row]
            fetchAndPushArtistTopTracks(deezerArtist)
            
        case .album: break
        }
    }
    
    private func fetchAndPushArtistTopTracks(_ artist: DeezerArtist) {
        guard let formattedRequestUrlString = artist.tracklist.addingPercentEncoding(withAllowedCharacters: customURLQueryAllowedCharacterSet) else { return }
        
        Service.shared.fetchDeezerTrack(urlString: formattedRequestUrlString) { [weak self] (deezerData, error) in
            
            if let _ = error {
                Toast.displayMessageShortly(errorLoadingMessage)
            } else if let deezerData = deezerData {
                if deezerData.data.count > 0 {
                    DispatchQueue.main.async {
                        self?.pushDeezerTracklist(with: artist, deezerTrackData: deezerData)
                    }
                } else {
                    self?.fetchAndPushArtistAlbums(artist)
                }
            }
        }
    }
    
    private func fetchAndPushArtistAlbums(_ artist: DeezerArtist) {
        let requestUrlString = "https://api.deezer.com/artist/\(artist.id)/albums"
        
        guard let formattedRequestUrlString = requestUrlString.addingPercentEncoding(withAllowedCharacters: customURLQueryAllowedCharacterSet) else { return }
        
        Service.shared.fetchDeezerAlbum(urlString: formattedRequestUrlString) {[weak self] (deezerData, error) in
            
            if let _ = error {
                Toast.displayMessageShortly(errorLoadingMessage)
            } else if let deezerData = deezerData {
                DispatchQueue.main.async {
                    self?.pushDeezerAlbums(with: artist, deezerAlbumData: deezerData)
                }
            }
        }
    }
    
    private func pushDeezerTracklist(with artist: DeezerArtist, deezerTrackData: DeezerData<DeezerTrack>) {
        let deezerTracklistViewController = UIStoryboard(name: "Deezer", bundle: nil).instantiateViewController(withIdentifier: "DeezerTracklistViewController") as! DeezerTracklistViewController
        deezerTracklistViewController.albumTitleOrArtistName = artist.name
        deezerTracklistViewController.topTrack = true
        deezerTracklistViewController.deezerTrackData = deezerTrackData
        
        navigationController?.pushViewController(deezerTracklistViewController, animated: true)
    }
    
    private func pushDeezerAlbums(with artist: DeezerArtist, deezerAlbumData: DeezerData<DeezerAlbum>) {
        let deezerAlbumViewController = UIStoryboard(name: "Deezer", bundle: nil).instantiateViewController(withIdentifier: "DeezerAlbumViewController") as! DeezerAlbumViewController
        deezerAlbumViewController.artistName = artist.name
        deezerAlbumViewController.deezerAlbumData = deezerAlbumData
        
        navigationController?.pushViewController(deezerAlbumViewController, animated: true)
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
            
        case .album: return 0
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
        }
        
        return cell
    }
    
    private func albumCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
