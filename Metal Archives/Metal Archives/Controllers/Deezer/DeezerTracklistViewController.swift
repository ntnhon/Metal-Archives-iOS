//
//  DeezerTracklistViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 21/07/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseAnalytics

final class DeezerTracklistViewController: BaseViewController {
    @IBOutlet private weak var simpleNavigationBarView: SimpleNavigationBarView!
    @IBOutlet private weak var tableView: UITableView!
    
    var topTrack = false
    var albumTitleOrArtistName: String!
    var deezerTrackData: DeezerData<DeezerTrack>!
    var albumCoverUrlString: String?
    
    private var player: AVPlayer?
    private var isPlayingIndex: Int = -1
    deinit {
        print("DeezerTracklistViewController is deallocated")
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSimpleNavigationBarView()
        configureTableView()
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        Analytics.logEvent("view_deezer_tracklist", parameters: ["albumTitleOrArtistName": albumTitleOrArtistName ?? ""])
    }
    
    private func initSimpleNavigationBarView() {
        simpleNavigationBarView.setAlphaForBackgroundAndTitleLabel(1)
        simpleNavigationBarView.setRightButtonIcon(nil)
        
        if topTrack {
            simpleNavigationBarView.setTitle("Top track for artist \"\(albumTitleOrArtistName!)\"")
        } else {
            simpleNavigationBarView.setTitle("Tracklist for album \"\(albumTitleOrArtistName!)\"")
        }
        
        simpleNavigationBarView.didTapLeftButton = { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func configureTableView() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .clear
        tableView.tableFooterView = UIView(frame: .zero)
        
        DeezerTrackTableViewCell.register(with: tableView)
        SimpleTableViewCell.register(with: tableView)
    }

    @objc private func playerDidFinishPlaying() {
        if let playingCell = tableView.cellForRow(at: IndexPath(row: isPlayingIndex, section: 0)) as? DeezerTrackTableViewCell {
            playingCell.setPlaying(false)
        }
        
        isPlayingIndex = -1
    }
}

// MARK: - UITableViewDelegate
extension DeezerTracklistViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard deezerTrackData.data.count > 0 else { return }
        
        let track = deezerTrackData.data[indexPath.row]
        
        if indexPath.row == isPlayingIndex {
            if let playingCell = tableView.cellForRow(at: indexPath) as? DeezerTrackTableViewCell {
                playingCell.setPlaying(false)
            }
            isPlayingIndex = -1
            player?.pause()
            
            Analytics.logEvent("pause_deezer_track", parameters: ["track": track.title])
            
            return
        }
        
        guard let trackURL = URL(string: track.preview) else { return }
        
        let playerItem = AVPlayerItem(url: trackURL)
        
        player = AVPlayer(playerItem: playerItem)
        player?.volume = 1
        player?.play()
        
        if let lastPlayingCell = tableView.cellForRow(at: IndexPath(row: isPlayingIndex, section: 0)) as? DeezerTrackTableViewCell {
            lastPlayingCell.setPlaying(false)
        }
        
        if let selectedCell = tableView.cellForRow(at: indexPath) as? DeezerTrackTableViewCell {
            selectedCell.setPlaying(true)
        }
        
        isPlayingIndex = indexPath.row
        
        Analytics.logEvent("play_deezer_track", parameters: ["track": track.title])
    }
}

// MARK: - UITableViewDataSource
extension DeezerTracklistViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let deezerTrackData = deezerTrackData else {
            return 0
        }
        
        return max(deezerTrackData.data.count, 1)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard deezerTrackData.data.count > 0 else {
            let simpleCell = SimpleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            simpleCell.displayAsItalicBodyText()
            simpleCell.fill(with: "No result found.")
            return simpleCell
        }
        
        let cell = DeezerTrackTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let track = deezerTrackData.data[indexPath.row]
        cell.fill(with: track)
        if let albumCoverUrlString = albumCoverUrlString {
            cell.thumbnailImageView.sd_setImage(with: URL(string: albumCoverUrlString))
        }
        cell.setPlaying(indexPath.row == isPlayingIndex)
        
        cell.tappedThumbnailImageView = { [unowned self] in
            if let album = track.album {
                self.presentPhotoViewer(photoUrlString: album.cover_xl, description: album.title, fromImageView: cell.thumbnailImageView)
            } else if let albumCoverUrlString = self.albumCoverUrlString {
                self.presentPhotoViewer(photoUrlString: albumCoverUrlString, description: self.albumTitleOrArtistName, fromImageView: cell.thumbnailImageView)
            }
        }
        
        return cell
    }
}
