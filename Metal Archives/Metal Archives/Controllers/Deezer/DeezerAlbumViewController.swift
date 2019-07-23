//
//  DeezerAlbumViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 21/07/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Toaster
import FirebaseAnalytics

final class DeezerAlbumViewController: BaseViewController {
    @IBOutlet private weak var simpleNavigationBarView: SimpleNavigationBarView!
    @IBOutlet private weak var tableView: UITableView!
    
    var artistName: String!
    var deezerAlbumData: DeezerData<DeezerAlbum>!

    deinit {
        print("DeezerAlbumViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSimpleNavigationBarView()
        configureTableView()
        
        Analytics.logEvent("view_deezer_albums", parameters: ["artist": artistName ?? ""])
    }
    
    private func initSimpleNavigationBarView() {
        simpleNavigationBarView.setAlphaForBackgroundAndTitleLabel(1)
        simpleNavigationBarView.setRightButtonIcon(nil)
        simpleNavigationBarView.setTitle("Albums of band \"\(artistName!)\"")
        
        simpleNavigationBarView.didTapLeftButton = { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func configureTableView() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = Settings.currentTheme.backgroundColor
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.contentInset = .init(top: 0, left: 0, bottom: UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0, right: 0)
        
        DeezerAlbumTableViewCell.register(with: tableView)
        SimpleTableViewCell.register(with: tableView)
    }
}

// MARK: - UITableViewDelegate
extension DeezerAlbumViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard deezerAlbumData.data.count > 0 else { return }
        let album = deezerAlbumData.data[indexPath.row]
        
        Analytics.logEvent("select_deezer_album", parameters: ["artist": artistName ?? "", "album": album.title])
        
        fetchAndPushDeezerTracklist(with: album)
    }
    
    private func fetchAndPushDeezerTracklist(with album: DeezerAlbum) {
        guard let formattedRequestUrlString = album.tracklist.addingPercentEncoding(withAllowedCharacters: customURLQueryAllowedCharacterSet) else { return }
        showHUD()
        
        Service.shared.fetchDeezerTrack(urlString: formattedRequestUrlString) { [weak self] (deezerData, error) in
            DispatchQueue.main.async {
                self?.hideHUD()
                if let _ = error {
                    Toast.displayMessageShortly(errorLoadingMessage)
                } else if let deezerData = deezerData {
                    self?.pushDeezerTracklist(with: album, deezerTrackData: deezerData)
                }
            }
        }
    }
    
    private func pushDeezerTracklist(with album: DeezerAlbum, deezerTrackData: DeezerData<DeezerTrack>) {
        let deezerTracklistViewController = UIStoryboard(name: "Deezer", bundle: nil).instantiateViewController(withIdentifier: "DeezerTracklistViewController") as! DeezerTracklistViewController
        deezerTracklistViewController.albumTitleOrArtistName = album.title
        deezerTracklistViewController.albumCoverUrlString = album.cover_xl
        deezerTracklistViewController.topTrack = false
        deezerTracklistViewController.deezerTrackData = deezerTrackData
        
        navigationController?.pushViewController(deezerTracklistViewController, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension DeezerAlbumViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let deezerAlbumData = deezerAlbumData else {
            return 0
        }
        
        return max(deezerAlbumData.data.count, 1)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard deezerAlbumData.data.count > 0 else {
            let simpleCell = SimpleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            simpleCell.displayAsItalicBodyText()
            simpleCell.fill(with: "No result found.")
            return simpleCell
        }
        
        let cell = DeezerAlbumTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let album = deezerAlbumData.data[indexPath.row]
        cell.fill(with: album)
        
        cell.tappedThumbnailImageView = { [unowned self] in
            self.presentPhotoViewer(photoUrlString: album.cover_xl, description: album.title, fromImageView: cell.thumbnailImageView)
        }
        
        return cell
    }
}

