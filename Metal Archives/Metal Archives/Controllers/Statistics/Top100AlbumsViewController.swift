//
//  Top100AlbumsViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Toaster
import FirebaseAnalytics

final class Top100AlbumsViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!

    private var currentAlbumTopType: AlbumTopType! = .review
    private var segmentedControl: UISegmentedControl!
    private var top100Albums: Top100Albums!
    
    private var numberOfTries = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initSegmentedControl()
        self.initNavBarAttributes()
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
        self.tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        self.tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.tableFooterView = UIView(frame: .zero)
        
        AlbumTopTableViewCell.register(with: self.tableView)
    }
    
    private func initNavBarAttributes() {
        self.title = "Top 100 - Albums"
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
    }
    
    private func initSegmentedControl() {
        let segmentTitles = AlbumTopType.allCases.map { (eachBandTopType) -> String in
            return eachBandTopType.description
        }
        self.segmentedControl = UISegmentedControl(items: segmentTitles)
        self.segmentedControl.selectedSegmentIndex = self.currentAlbumTopType.rawValue
        self.segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        
        self.navigationItem.titleView = self.segmentedControl
    }
    
    @objc private func segmentedControlValueChanged() {
        self.currentAlbumTopType = AlbumTopType(rawValue: self.segmentedControl.selectedSegmentIndex)
        self.tableView.reloadData()
        
        Analytics.logEvent(AnalyticsEvent.ChangeSectionInTop100Albums, parameters: [AnalyticsParameter.SectionName: self.currentAlbumTopType.description])
    }
    
    private func fetchData() {
        if self.numberOfTries == Settings.numberOfRetries {
            Toast.displayMessageShortly("Error loading content. Please check your internet connection and retry.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.navigationController?.popViewController(animated: true)
            }
            return
        }
        
        self.numberOfTries += 1
        MetalArchivesAPI.fetchTop100Albums { [weak self] (top100Albums, error) in
            if let _ = error {
                self?.fetchData()
            } else if let `top100Albums` = top100Albums {
                DispatchQueue.main.async {
                    self?.top100Albums = top100Albums
                    self?.tableView.reloadData()
                }
            }
        }
    }
}

//MARK: - UITableViewDelegate
extension Top100AlbumsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var album: AlbumTop?
        
        switch self.currentAlbumTopType! {
        case .review: album = self.top100Albums.byReviews[indexPath.row]
        case .mostOwned: album = self.top100Albums.mostOwned[indexPath.row]
        case .mostWanted: album = self.top100Albums.mostWanted[indexPath.row]
        }
        if let `album` = album {
            self.takeActionFor(actionableObject: album)
            
            Analytics.logEvent(AnalyticsEvent.SelectAnItemInTop100Albums, parameters: [AnalyticsParameter.SectionName: self.currentAlbumTopType.description, AnalyticsParameter.ReleaseTitle: album.release.name, AnalyticsParameter.ReleaseID: album.release.id])
        }
    }
}

//MARK: - UITableViewDataSource
extension Top100AlbumsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let _ = self.top100Albums else {
            return 0
        }
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = AlbumTopTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        var album: AlbumTop?
        
        switch self.currentAlbumTopType! {
        case .review: album = self.top100Albums.byReviews[indexPath.row]
        case .mostOwned: album = self.top100Albums.mostOwned[indexPath.row]
        case .mostWanted: album = self.top100Albums.mostWanted[indexPath.row]
        }
        if let `album` = album {
            cell.fill(with: album, order: indexPath.row + 1)
            return cell
        } else {
            assertionFailure("Error retreiving album from top100Albums")
            return UITableViewCell()
        }
    }
}
