//
//  StatisticsViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Toaster
import FirebaseAnalytics

final class StatisticsViewController: BaseViewController {
    @IBOutlet private weak var simpleNavigationBarView: SimpleNavigationBarView!
    @IBOutlet private weak var tableView: UITableView!
    
    private var numberOfTries = 0
    private var statistic: Statistic!
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchStatistic()
        handleSimpleNavigationBarViewActions()
        
        Analytics.logEvent("view_statistics", parameters: nil)
    }
    
    override func initAppearance() {
        super.initAppearance()
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.contentInset = UIEdgeInsets(top: baseNavigationBarViewHeightWithoutTopInset, left: 0, bottom: UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0, right: 0)
        
        tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        
        BandStatisticTableViewCell.register(with: tableView)
        ReviewStatisticTableViewCell.register(with: tableView)
        LabelStatisticTableViewCell.register(with: tableView)
        ArtistStatisticTableViewCell.register(with: tableView)
        MemberStatisticTableViewCell.register(with: tableView)
        ReleaseStatisticTableViewCell.register(with: tableView)
        SimpleTableViewCell.register(with: tableView)
    }

    private func handleSimpleNavigationBarViewActions() {
        simpleNavigationBarView.setTitle("Loading...")
        simpleNavigationBarView.setAlphaForBackgroundAndTitleLabel(1)
        simpleNavigationBarView.setRightButtonIcon(nil)
        
        simpleNavigationBarView.didTapLeftButton = { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func fetchStatistic() {
        showHUD()
        if numberOfTries == Settings.numberOfRetries {
            Toast.displayMessageShortly("Error loading content. Please check your internet connection and retry.")
            hideHUD()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.navigationController?.popViewController(animated: true)
            }
            return
        }
        
        numberOfTries += 1
        MetalArchivesAPI.fetchStatisticDetails { [weak self] (statistic, error) in
            if let _ = error {
                self?.fetchStatistic()
            } else if let `statistic` = statistic {
                self?.hideHUD()
                self?.statistic = statistic
                self?.simpleNavigationBarView.setTitle(statistic.dateAndTimeString)
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
        case 0: didSelectTop100Bands()
        case 1: didSelectTop100Albums()
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
        guard let _ = statistic else {
            return 0
        }
        return 8
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0: return cellForTop100BandsSection(at: indexPath)
        case 1: return cellForTop100AlbumSection(at: indexPath)
        case 2: return cellForBandStatisticSection(at: indexPath)
        case 3: return cellForReviewStatisticSection(at: indexPath)
        case 4: return cellForLabelStatisticSection(at: indexPath)
        case 5: return cellForArtistStatisticSection(at: indexPath)
        case 6: return cellForMemberStatisticSection(at: indexPath)
        case 7: return cellForReleaseStatisticSection(at: indexPath)
        default: return UITableViewCell()
        }
    }
}

// MARK: - UIScrollViewDelegate
extension StatisticsViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        simpleNavigationBarView.transformWith(scrollView)
    }
}

//MARK: - Cells
extension StatisticsViewController {
    func cellForTop100BandsSection(at indexPath: IndexPath) -> UITableViewCell {
        let cell = SimpleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.fill(with: "View top 100 bands")
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func cellForTop100AlbumSection(at indexPath: IndexPath) -> UITableViewCell {
        let cell = SimpleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.fill(with: "View top 100 albums")
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func cellForBandStatisticSection(at indexPath: IndexPath) -> UITableViewCell {
        let cell = BandStatisticTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.drawChart(forBandStatistic: statistic.band)
        return cell
    }
    
    func cellForReviewStatisticSection(at indexPath: IndexPath) -> UITableViewCell {
        let cell = ReviewStatisticTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.drawChart(forReviewStatistic: statistic.review)
        return cell
    }
    
    func cellForLabelStatisticSection(at indexPath: IndexPath) -> UITableViewCell {
        let cell = LabelStatisticTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.drawChart(forLabelStatistic: statistic.label)
        return cell
    }
    
    func cellForArtistStatisticSection(at indexPath: IndexPath) -> UITableViewCell {
        let cell = ArtistStatisticTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.drawChart(forArtistStatistic: statistic.artist)
        return cell
    }
    
    func cellForMemberStatisticSection(at indexPath: IndexPath) -> UITableViewCell {
        let cell = MemberStatisticTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.drawChart(forMemberStatistic: statistic.member)
        return cell
    }
    
    func cellForReleaseStatisticSection(at indexPath: IndexPath) -> UITableViewCell {
        let cell = ReleaseStatisticTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.drawChart(forReleaseStatistic: statistic.release)
        return cell
    }
}

//MARK: - Section row
extension StatisticsViewController {
    func didSelectTop100Bands() {
        performSegue(withIdentifier: "ShowTop100Bands", sender: nil)
    }
    
    func didSelectTop100Albums() {
        performSegue(withIdentifier: "ShowTop100Albums", sender: nil)
    }
}
