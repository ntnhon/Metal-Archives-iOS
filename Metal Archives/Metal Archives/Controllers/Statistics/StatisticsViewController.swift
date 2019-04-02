//
//  StatisticsViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Toaster

final class StatisticsViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    private var numberOfTries = 0
    private var statistic: Statistic!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Loading..."
        self.fetchStatistic()
    }
    
    override func initAppearance() {
        super.initAppearance()
        
        self.tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        self.tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.tableFooterView = UIView(frame: .zero)
        
        BandStatisticTableViewCell.register(with: self.tableView)
        ReviewStatisticTableViewCell.register(with: self.tableView)
        LabelStatisticTableViewCell.register(with: self.tableView)
        ArtistStatisticTableViewCell.register(with: self.tableView)
        MemberStatisticTableViewCell.register(with: self.tableView)
        ReleaseStatisticTableViewCell.register(with: self.tableView)
        SimpleTableViewCell.register(with: self.tableView)
    }
    
    private func fetchStatistic() {
        if self.numberOfTries == Settings.numberOfRetries {
            Toast.displayMessageShortly("Error loading content. Please check your internet connection and retry.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.navigationController?.popViewController(animated: true)
            }
            return
        }
        
        self.numberOfTries += 1
        MetalArchivesAPI.fetchStatisticDetails { [weak self] (statistic, error) in
            if let _ = error {
                self?.fetchStatistic()
            } else if let `statistic` = statistic {
                self?.statistic = statistic
                self?.title = statistic.dateAndTimeString
                self?.tableView.reloadData()
            }
        }
    }

}

//MARK: - UITableViewDelegate
extension StatisticsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0: self.didSelectTop100Bands()
        case 1: self.didSelectTop100Albums()
        default: return
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 2: return "Bands"
        case 3: return "Reviews & Albums"
        case 4: return "Labels"
        case 5: return "Artists"
        case 6: return "Members"
        case 7: return "Albums & Songs"
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = Settings.currentTheme.titleColor
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let footerView = view as? UITableViewHeaderFooterView {
            footerView.textLabel?.textColor = Settings.currentTheme.titleColor
        }
    }
}

//MARK: - UITableViewDataSource
extension StatisticsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let _ = self.statistic else {
            return 0
        }
        return 8
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0: return self.cellForTop100BandsSection(at: indexPath)
        case 1: return self.cellForTop100AlbumSection(at: indexPath)
        case 2: return self.cellForBandStatisticSection(at: indexPath)
        case 3: return self.cellForReviewStatisticSection(at: indexPath)
        case 4: return self.cellForLabelStatisticSection(at: indexPath)
        case 5: return self.cellForArtistStatisticSection(at: indexPath)
        case 6: return self.cellForMemberStatisticSection(at: indexPath)
        case 7: return self.cellForReleaseStatisticSection(at: indexPath)
        default: return UITableViewCell()
        }
    }
}

//MARK: - Cells
extension StatisticsViewController {
    func cellForTop100BandsSection(at indexPath: IndexPath) -> UITableViewCell {
        let cell = SimpleTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        cell.fill(with: "View top 100 bands")
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func cellForTop100AlbumSection(at indexPath: IndexPath) -> UITableViewCell {
        let cell = SimpleTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        cell.fill(with: "View top 100 albums")
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func cellForBandStatisticSection(at indexPath: IndexPath) -> UITableViewCell {
        let cell = BandStatisticTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        cell.drawChart(forBandStatistic: self.statistic.band)
        return cell
    }
    
    func cellForReviewStatisticSection(at indexPath: IndexPath) -> UITableViewCell {
        let cell = ReviewStatisticTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        cell.drawChart(forReviewStatistic: self.statistic.review)
        return cell
    }
    
    func cellForLabelStatisticSection(at indexPath: IndexPath) -> UITableViewCell {
        let cell = LabelStatisticTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        cell.drawChart(forLabelStatistic: self.statistic.label)
        return cell
    }
    
    func cellForArtistStatisticSection(at indexPath: IndexPath) -> UITableViewCell {
        let cell = ArtistStatisticTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        cell.drawChart(forArtistStatistic: self.statistic.artist)
        return cell
    }
    
    func cellForMemberStatisticSection(at indexPath: IndexPath) -> UITableViewCell {
        let cell = MemberStatisticTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        cell.drawChart(forMemberStatistic: self.statistic.member)
        return cell
    }
    
    func cellForReleaseStatisticSection(at indexPath: IndexPath) -> UITableViewCell {
        let cell = ReleaseStatisticTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        cell.drawChart(forReleaseStatistic: self.statistic.release)
        return cell
    }
}

//MARK: - Section row
extension StatisticsViewController {
    func didSelectTop100Bands() {
        self.performSegue(withIdentifier: "ShowTop100Bands", sender: nil)
    }
    
    func didSelectTop100Albums() {
        self.performSegue(withIdentifier: "ShowTop100Albums", sender: nil)
    }
}
