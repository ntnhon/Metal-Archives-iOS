//
//  Top100BandsViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Toaster
import FirebaseAnalytics

final class Top100BandsViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    private var currentBandTopType: BandTopType! = .release
    private var segmentedControl: UISegmentedControl!
    private var top100Bands: Top100Bands!
    
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
        
        BandTopTableViewCell.register(with: self.tableView)
    }
    
    private func initNavBarAttributes() {
        self.title = "Top 100 - Bands"
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
    }
    
    private func initSegmentedControl() {
        let segmentTitles = BandTopType.allCases.map { (eachBandTopType) -> String in
            return eachBandTopType.description
        }
        self.segmentedControl = UISegmentedControl(items: segmentTitles)
        self.segmentedControl.selectedSegmentIndex = self.currentBandTopType.rawValue
        self.segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        
        self.navigationItem.titleView = self.segmentedControl
    }
    
    @objc private func segmentedControlValueChanged() {
        self.currentBandTopType = BandTopType(rawValue: self.segmentedControl.selectedSegmentIndex)
        self.tableView.reloadData()
        
        Analytics.logEvent(AnalyticsEvent.ChangeSectionInTop100Bands, parameters: [AnalyticsParameter.SectionName: self.currentBandTopType.description])
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
        MetalArchivesAPI.fetchTop100Bands { [weak self] (top100Bands, error) in
            if let _ = error {
                self?.fetchData()
            } else if let `top100Bands` = top100Bands {
                DispatchQueue.main.async {
                    self?.top100Bands = top100Bands
                    self?.tableView.reloadData()
                }
            }
        }
    }
}

//MARK: - UITableViewDelegate
extension Top100BandsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var bandTop: BandTop?
        
        switch self.currentBandTopType! {
        case .release: bandTop = self.top100Bands.byReleases[indexPath.row]
        case .fullLength: bandTop = self.top100Bands.byFullLengths[indexPath.row]
        case .review: bandTop = self.top100Bands.byReviews[indexPath.row]
        }
        if let `bandTop` = bandTop {
            self.pushBandDetailViewController(urlString: bandTop.urlString, animated: true)
            
            Analytics.logEvent(AnalyticsEvent.SelectAnItemInTop100Bands, parameters: [AnalyticsParameter.SectionName: self.currentBandTopType.description, AnalyticsParameter.BandName: bandTop.name, AnalyticsParameter.BandID: bandTop.id])
        }
    }
}

//MARK: - UITableViewDataSource
extension Top100BandsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let _ = self.top100Bands else {
            return 0
        }
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = BandTopTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        var bandTop: BandTop?
        
        switch self.currentBandTopType! {
        case .release: bandTop = self.top100Bands.byReleases[indexPath.row]
        case .fullLength: bandTop = self.top100Bands.byFullLengths[indexPath.row]
        case .review: bandTop = self.top100Bands.byReviews[indexPath.row]
        }
        if let `bandTop` = bandTop {
            cell.fill(with: bandTop, order: indexPath.row + 1)
            return cell
        } else {
            assertionFailure("Error retreiving bandTop from top100Bands")
            return UITableViewCell()
        }
    }
}
