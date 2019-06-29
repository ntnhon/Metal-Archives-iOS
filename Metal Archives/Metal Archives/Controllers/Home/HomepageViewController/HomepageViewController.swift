//
//  HomepageViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 12/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Toaster
import FirebaseAnalytics
import NotificationBannerSwift

final class HomepageViewController: RefreshableViewController {
    @IBOutlet private weak var simpleNavigationBarView: SimpleNavigationBarView!
    private var statisticAttrString: NSAttributedString?
    private var newsPagableManager = PagableManager<News>()
    //Latest additions
    private var bandAdditionPagableManager = PagableManager<BandAddition>()
    private var labelAdditionPagableManager = PagableManager<LabelAddition>()
    private var artistAdditionPagableManager = PagableManager<ArtistAddition>()
    var latestAdditionsDelegate: HomepageViewControllerLatestAdditionOrUpdateDelegate?
    var latestAdditionType: AdditionOrUpdateType = .bands {
        didSet {
            respondToAdditionTypeChange()
        }
    }
    //Latest updates
    private var bandUpdatePagableManager = PagableManager<BandUpdate>()
    private var labelUpdatePagableManager = PagableManager<LabelUpdate>()
    private var artistUpdatePagableManager = PagableManager<ArtistUpdate>()
    var latestUpdatesDelegate: HomepageViewControllerLatestAdditionOrUpdateDelegate?
    var latestUpdateType: AdditionOrUpdateType = .bands {
        didSet {
            respondToUpdateTypeChange()
        }
    }
    
    private var latestReviewPagableManager = PagableManager<LatestReview>()
    private var upcomingAlbumPagableManager = PagableManager<UpcomingAlbum>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSimpleNavigationBarView()
        loadHomepage()
        initObservers()
        alertNewVersion()
    }
    
    override func initAppearance() {
        super.initAppearance()
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.contentInset = UIEdgeInsets(top: baseNavigationBarViewHeightWithoutTopInset, left: 0, bottom: 0, right: 0)
        
        LoadingTableViewCell.register(with: tableView)
        NewsTableViewCell.register(with: tableView)
        StatisticTableViewCell.register(with: tableView)
        AdditionOrUpdateTableViewCell.register(with: tableView)
        LatestReviewsTableViewCell.register(with: tableView)
        UpcomingAlbumsTableViewCell.register(with: tableView)
        ViewMoreTableViewCell.register(with: tableView)
    }
    
    private func initObservers() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.OpenSearchModule, object: nil, queue: nil) { (notification) in
            self.pushSearchViewController()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.ShowBandDetail, object: nil, queue: nil) { (notification) in
            guard let bandURLString = notification.object as? String else {
                return
            }
            
            self.pushBandDetailViewController(urlString: bandURLString, animated: true)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.ShowReviewDetail, object: nil, queue: nil) { (notification) in
            guard let reviewURLString = notification.object as? String else {
                return
            }
            
            self.presentReviewController(urlString: reviewURLString, animated: true)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.ShowReleaseDetail, object: nil, queue: nil) { (notification) in
            guard let releaseURLString = notification.object as? String else {
                return
            }
            
            self.pushReleaseDetailViewController(urlString: releaseURLString, animated: true)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AskForReview, object: nil, queue: nil) { (notification) in
            self.gentlyAskForReview()
        }
    }
    
    override func refresh() {
        statisticAttrString = nil
        newsPagableManager.reset()
        bandAdditionPagableManager.reset()
        bandUpdatePagableManager.reset()
        latestReviewPagableManager.reset()
        upcomingAlbumPagableManager.reset()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.endRefreshing()
            self.loadHomepage()
        }
        
        Analytics.logEvent(AnalyticsEvent.RefreshHomepage, parameters: nil)
    }
    
    private func loadHomepage() {
        
        RequestHelper.HomePage.Statistic.fetchStats { [weak self] (completion: () throws -> HomepageStatistic) in
            
            defer {
                self?.tableView.reloadData()
            }
            
            do {
                let homepageStatistic = try completion()
                self?.statisticAttrString = homepageStatistic.summaryAttributedText
            } catch let error {
                Toast.displayMessageShortly(error.localizedDescription)
                self?.statisticAttrString = NSAttributedString(string: "Error parsing statistic informations.")
            }
        }
        
        newsPagableManager.fetch { [weak self] (error) in
            self?.tableView.reloadData()
        }
        
        //Latest additions
        bandAdditionPagableManager = PagableManager<BandAddition>(options: ["<YEAR_MONTH>": monthList[0].requestParameterString])
        bandAdditionPagableManager.fetch { [weak self] (error) in
            self?.respondToAdditionTypeChange()
        }
        
        labelAdditionPagableManager = PagableManager<LabelAddition>(options: ["<YEAR_MONTH>": monthList[0].requestParameterString]) //Initilized but not start fetching
        artistAdditionPagableManager = PagableManager<ArtistAddition>(options: ["<YEAR_MONTH>": monthList[0].requestParameterString]) //Initilized but not start fetching
        
        //Latest updates
        bandUpdatePagableManager = PagableManager<BandUpdate>(options: ["<YEAR_MONTH>": monthList[0].requestParameterString])
        bandUpdatePagableManager.fetch { [weak self] (error) in
            self?.respondToUpdateTypeChange()
        }
        labelUpdatePagableManager = PagableManager<LabelUpdate>(options: ["<YEAR_MONTH>": monthList[0].requestParameterString]) //Initilized but not start fetching
        artistUpdatePagableManager = PagableManager<ArtistUpdate>(options: ["<YEAR_MONTH>": monthList[0].requestParameterString]) //Initilized but not start fetching
        
        
        latestReviewPagableManager =  PagableManager<LatestReview>(options: ["<YEAR_MONTH>": monthList[0].requestParameterString])
        latestReviewPagableManager.fetch { [weak self] (error) in
            self?.tableView.reloadData()
        }
        
        upcomingAlbumPagableManager.fetch { [weak self] (error) in
            self?.tableView.reloadData()
        }
    }
    
    private func initSimpleNavigationBarView() {
        simpleNavigationBarView.setAlphaForBackgroundAndTitleLabel(1)
        simpleNavigationBarView.setTitle("Metal Archives")
        simpleNavigationBarView.setLeftButtonIcon(#imageLiteral(resourceName: "Menu"))
        simpleNavigationBarView.setRightButtonIcon(#imageLiteral(resourceName: "horns_search"))
        
        simpleNavigationBarView.didTapLeftButton = { [unowned self] in
            self.toggleLeft()
        }
        
        simpleNavigationBarView.didTapRightButton = { [unowned self] in
            self.pushSearchViewController()
        }
    }
    
    private func pushSearchViewController() {guard let searchViewController = UIStoryboard(name: "Search", bundle: nil).instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController else {
        return
        }
        
        navigationController?.pushViewController(searchViewController, animated: true)
    }

    private func gentlyAskForReview() {
        let alert = UIAlertController(title: "Hey", message: "It seems that you are enjoying the application, it's great! Please take 1 minute to leave a review on App Store.", preferredStyle: .alert)
        
        let okayAction = UIAlertAction(title: "Okay! Take me to App Store!", style: .default) { (action) in
            openReviewOnAppStore()
            UserDefaults.setDidMakeAReview()
        }
        alert.addAction(okayAction)
        
        let cancelAction = UIAlertAction(title: "Remind me later", style: .cancel) { (action) in
            Analytics.logEvent(AnalyticsEvent.ReviewLatter, parameters: nil)
        }
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func respondToAdditionTypeChange() {
        switch latestAdditionType {
        case .bands:
            if let _ = bandAdditionPagableManager.totalRecords {
                latestAdditionsDelegate?.didFinishFetchingBandAdditionOrUpdate(bandAdditionPagableManager.objects)
                return
            }
            
            bandAdditionPagableManager.fetch { [weak self] (error) in
                if let _ = error {
                    self?.latestAdditionsDelegate?.didFailFetching()
                    return
                }
                
                self?.latestAdditionsDelegate?.didFinishFetchingBandAdditionOrUpdate(self?.bandAdditionPagableManager.objects ?? [])
            }
        case .labels:
            if let _ = labelAdditionPagableManager.totalRecords {
                latestAdditionsDelegate?.didFinishFetchingLabelAdditionOrUpdate(labelAdditionPagableManager.objects)
                return
            }
            
            labelAdditionPagableManager.fetch { [weak self] (error) in
                if let _ = error {
                    self?.latestAdditionsDelegate?.didFailFetching()
                    return
                }
                
                self?.latestAdditionsDelegate?.didFinishFetchingLabelAdditionOrUpdate(self?.labelAdditionPagableManager.objects ?? [])
            }
        case .artists:
            if let _ = artistAdditionPagableManager.totalRecords {
                latestAdditionsDelegate?.didFinishFetchingArtistAdditionOrUpdate(artistAdditionPagableManager.objects)
                return
            }
            
            artistAdditionPagableManager.fetch { [weak self] (error) in
                if let _ = error {
                    self?.latestAdditionsDelegate?.didFailFetching()
                    return
                }
                
                self?.latestAdditionsDelegate?.didFinishFetchingArtistAdditionOrUpdate(self?.artistAdditionPagableManager.objects ?? [])
            }
        }
    }
    
    private func respondToUpdateTypeChange() {
        switch latestUpdateType {
        case .bands:
            if let _ = bandUpdatePagableManager.totalRecords {
                latestUpdatesDelegate?.didFinishFetchingBandAdditionOrUpdate(bandUpdatePagableManager.objects)
                return
            }
            
            bandUpdatePagableManager.fetch { [weak self] (error) in
                if let _ = error {
                    self?.latestUpdatesDelegate?.didFailFetching()
                    return
                }
                
                self?.latestUpdatesDelegate?.didFinishFetchingBandAdditionOrUpdate(self?.bandUpdatePagableManager.objects ?? [])
            }
        case .labels:
            if let _ = labelUpdatePagableManager.totalRecords {
                latestUpdatesDelegate?.didFinishFetchingLabelAdditionOrUpdate(labelUpdatePagableManager.objects)
                return
            }
            
            labelUpdatePagableManager.fetch { [weak self] (error) in
                if let _ = error {
                    self?.latestUpdatesDelegate?.didFailFetching()
                    return
                }
                
                self?.latestUpdatesDelegate?.didFinishFetchingLabelAdditionOrUpdate(self?.labelUpdatePagableManager.objects ?? [])
            }
        case .artists:
            if let _ = artistUpdatePagableManager.totalRecords {
                latestUpdatesDelegate?.didFinishFetchingArtistAdditionOrUpdate(artistUpdatePagableManager.objects)
                return
            }
            
            artistUpdatePagableManager.fetch { [weak self] (error) in
                if let _ = error {
                    self?.latestUpdatesDelegate?.didFailFetching()
                    return
                }
                
                self?.latestUpdatesDelegate?.didFinishFetchingArtistAdditionOrUpdate(self?.artistUpdatePagableManager.objects ?? [])
            }
        }
    }
}

// MARK: - Segues
extension HomepageViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowLatestAdditions"{
            guard let latestAdditionsViewController = segue.destination as? LatestAdditionsOrUpdatesViewController else { return }
            latestAdditionsViewController.mode = .additions
            latestAdditionsViewController.currentAdditionOrUpdateType = latestAdditionType
        } else if segue.identifier == "ShowLatestUpdates" {
            guard let latestAdditionsViewController = segue.destination as? LatestAdditionsOrUpdatesViewController else { return }
            latestAdditionsViewController.mode = .updates
            latestAdditionsViewController.currentAdditionOrUpdateType = latestUpdateType
        }
    }
}

// MARK: - UIPopoverPresentationControllerDelegate
extension HomepageViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

// MARK: - UITableViewDelegate
extension HomepageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        //Section: Stats
        case 0: didSelectRowInStatisticsSection(at: indexPath)
        default: return
        }
    }
}

// MARK: - UITableViewDatasource
extension HomepageViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        //6 sections: Stats, News, Latest additions, Latest updates, Latest reviews, Upcoming albums
        return 6
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        //Section: Stats
        case 0: return cellForStatsSection(at: indexPath)
        //Section: News
        case 1: return cellForNewsSection(at: indexPath)
        //Section: Latets additions
        case 2: return cellForLatestAdditionsSection(at: indexPath)
        //Section: Latest updates
        case 3: return cellForLatestUpdatesSection(at: indexPath)
        //Section: Latest review
        case 4: return cellForLatestReviewsSection(at: indexPath)
        //Section: Upcoming albums
        case 5: return cellForUpcomingAlbumsSection(at: indexPath)
        default: return UITableViewCell()
        }
    }
}

// MARK: - UIScrollViewDelegate
extension HomepageViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        simpleNavigationBarView.transformWith(scrollView)
    }
}

// MARK: - Loading cell
extension HomepageViewController {
    private func loadingCell(atIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.displayIsLoading()
        return cell
    }
}

// MARK: - Section STATISTICS
extension HomepageViewController {
    private func cellForStatsSection(at indexPath: IndexPath) -> UITableViewCell {
        guard let `statisticAttrString` = statisticAttrString else {
            return loadingCell(atIndexPath: indexPath)
        }
        
        let cell = StatisticTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.fill(with: statisticAttrString)
        return cell
    }
    
    private func didSelectRowInStatisticsSection(at indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowStatistics", sender: nil)
    }
}

// MARK: - Section NEWS
extension HomepageViewController {
    private func cellForNewsSection(at indexPath: IndexPath) -> UITableViewCell {
        //Don't check totalRecords is nil or not because News doesn't have such parameter
        guard newsPagableManager.objects.count > 0 else {
            return loadingCell(atIndexPath: indexPath)
        }
        
        let cell = NewsTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.newsArray = newsPagableManager.objects
        cell.seeAll = {[unowned self] in
            let newsArchiveViewController = UIStoryboard(name: "NewsArchive", bundle: nil).instantiateViewController(withIdentifier: "NewsArchiveViewController" ) as! NewsArchiveViewController
            self.navigationController?.pushViewController(newsArchiveViewController, animated: true)
        }
        cell.didSelectNews = { [unowned self] selectedNews in
            self.presentNewsDetailViewController(selectedNews)
        }
        return cell
    }
    
    private func presentNewsDetailViewController(_ news: News) {
        let newsDetailViewController = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "NewsDetailViewController") as! NewsDetailViewController
        newsDetailViewController.news = news
        
        let navNewsDetailViewController = UINavigationController(rootViewController: newsDetailViewController)
        navNewsDetailViewController.modalPresentationStyle = .popover
        navNewsDetailViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        navNewsDetailViewController.preferredContentSize = CGSize(width: screenWidth - 50, height: screenHeight * 2 / 3)
        
        navNewsDetailViewController.popoverPresentationController?.delegate = self
        navNewsDetailViewController.popoverPresentationController?.sourceView = tableView
        navNewsDetailViewController.popoverPresentationController?.sourceRect = tableView.frame
        
        present(navNewsDetailViewController, animated: true, completion: nil)
    }
}

// MARK: - Section LATEST ADDITIONS
extension HomepageViewController {
    private func cellForLatestAdditionsSection(at indexPath: IndexPath) -> UITableViewCell {
        let cell = AdditionOrUpdateTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        
        cell.selectedType = latestAdditionType
        cell.mode = .additions
        latestAdditionsDelegate = cell
        
        cell.seeAll = {[unowned self] in
            self.performSegue(withIdentifier: "ShowLatestAdditions", sender: nil)
            
            Analytics.logEvent(AnalyticsEvent.SelectAnItemInHomepage, parameters: [AnalyticsParameter.ItemType: "Show more latest additions"])
        }
        
        cell.didSelectBand = { [unowned self] band in
            self.pushBandDetailViewController(urlString: band.urlString, animated: true)
            
            Analytics.logEvent(AnalyticsEvent.SelectAnItemInHomepage, parameters: [AnalyticsParameter.ItemType: "BandAddition"])
        }
        
        cell.didSelectLabel = { [unowned self] label in
            self.pushLabelDetailViewController(urlString: label.urlString, animated: true)
            Analytics.logEvent(AnalyticsEvent.SelectAnItemInHomepage, parameters: [AnalyticsParameter.ItemType: "LabelAddition"])
        }
        
        cell.didSelectArtist = { [unowned self] artist in
            self.takeActionFor(actionableObject: artist)
            Analytics.logEvent(AnalyticsEvent.SelectAnItemInHomepage, parameters: [AnalyticsParameter.ItemType: "ArtistAddition"])
        }
        
        cell.changeType = { [unowned self] selectedType in
            self.latestAdditionType = selectedType
        }
        
        cell.didSelectImageView = { [unowned self] imageView, urlString, description in
            self.presentPhotoViewerWithCacheChecking(photoUrlString: urlString, description: description, fromImageView: imageView)
        }
        
        return cell
    }
}

// MARK: - Section LATEST UPDATES
extension HomepageViewController {
    private func cellForLatestUpdatesSection(at indexPath: IndexPath) -> UITableViewCell {
        let cell = AdditionOrUpdateTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        
        cell.selectedType = latestAdditionType
        cell.mode = .updates
        latestUpdatesDelegate = cell
        
        cell.seeAll = {[unowned self] in
            self.performSegue(withIdentifier: "ShowLatestUpdates", sender: nil)
            
            Analytics.logEvent(AnalyticsEvent.SelectAnItemInHomepage, parameters: [AnalyticsParameter.ItemType: "Show more latest updates"])
        }
        
        cell.didSelectBand = { [unowned self] band in
            self.pushBandDetailViewController(urlString: band.urlString, animated: true)
            
            Analytics.logEvent(AnalyticsEvent.SelectAnItemInHomepage, parameters: [AnalyticsParameter.ItemType: "BandUpdate"])
        }
        
        cell.didSelectLabel = { [unowned self] label in
            self.pushLabelDetailViewController(urlString: label.urlString, animated: true)
            Analytics.logEvent(AnalyticsEvent.SelectAnItemInHomepage, parameters: [AnalyticsParameter.ItemType: "LabelUpdate"])
        }
        
        cell.didSelectArtist = { [unowned self] artist in
            self.takeActionFor(actionableObject: artist)
            Analytics.logEvent(AnalyticsEvent.SelectAnItemInHomepage, parameters: [AnalyticsParameter.ItemType: "ArtistUpdate"])
        }
        
        cell.changeType = { [unowned self] selectedType in
            self.latestUpdateType = selectedType
        }
        
        cell.didSelectImageView = { [unowned self] imageView, urlString, description in
            self.presentPhotoViewerWithCacheChecking(photoUrlString: urlString, description: description, fromImageView: imageView)
        }
        
        return cell
    }
}

// MARK: - Section LATEST REVIEWS
extension HomepageViewController {
    private func cellForLatestReviewsSection(at indexPath: IndexPath) -> UITableViewCell {
        let cell = LatestReviewsTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        
        cell.latestReviews = latestReviewPagableManager.objects
        
        cell.seeAll = { [unowned self] in
            self.performSegue(withIdentifier: "ShowLatestReviews", sender: nil)
            Analytics.logEvent(AnalyticsEvent.SelectAnItemInHomepage, parameters: [AnalyticsParameter.ItemType: "Show more latest reviews"])
        }
        
        cell.didSelectLatestReview = { [unowned self] latestReview in
            self.takeActionFor(actionableObject: latestReview)
            Analytics.logEvent(AnalyticsEvent.SelectAnItemInHomepage, parameters: [AnalyticsParameter.ItemType: "LatestReview"])
        }
        
        cell.didSelectImageView = { [unowned self] imageView, urlString, description in
            self.presentPhotoViewerWithCacheChecking(photoUrlString: urlString, description: description, fromImageView: imageView)
        }
        
        return cell
    }
}

// MARK: - Section UPCOMING ALBUMS
extension HomepageViewController {
    private func cellForUpcomingAlbumsSection(at indexPath: IndexPath) -> UITableViewCell {
        let cell = UpcomingAlbumsTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        
        cell.upcomingAlbums = upcomingAlbumPagableManager.objects
        
        cell.seeAll = { [unowned self] in
            self.performSegue(withIdentifier: "ShowUpcomingAlbums", sender: nil)
            Analytics.logEvent(AnalyticsEvent.SelectAnItemInHomepage, parameters: [AnalyticsParameter.ItemType: "Show more upcoming albums"])
        }
        
        cell.didSelectUpcomingAlbum = { [unowned self] upcomingAlbum in
            self.takeActionFor(actionableObject: upcomingAlbum)
            Analytics.logEvent(AnalyticsEvent.SelectAnItemInHomepage, parameters: [AnalyticsParameter.ItemType: "UpcomingAlbum"])
        }
        
        cell.didSelectImageView = { [unowned self] imageView, urlString, description in
            self.presentPhotoViewerWithCacheChecking(photoUrlString: urlString, description: description, fromImageView: imageView)
        }
        
        return cell
    }
}

// MARK: - Alert new version
extension HomepageViewController {
    private func alertNewVersion() {
        guard UserDefaults.shouldAlertNewVersion() else {
            return
        }
        
        guard let url = Bundle.main.url(forResource: "VersionHistory", withExtension: "plist") else  {
            assertionFailure("Error loading list of version history. File not found.")
            return
        }
        
        guard let array = NSArray(contentsOf: url) as? [[String: String]] else {
            assertionFailure("Error loading list of version history. Unknown format.")
            return
        }
        
        guard let number = array[0]["number"], let features = array[0]["features"] else {
            return
        }
    
        let banner =
            GrowingNotificationBanner(title: "Congratulation!\nYou are on a new version of Metal Archives iOS!", subtitle: "What's new in this v\(number):\n\(features)\n\nA version history is also available in About section.", leftView: nil, rightView: nil, style: .info, colors: nil, iconPosition: .top)
        banner.autoDismiss = false
        banner.dismissOnTap = true
        banner.show()
        UserDefaults.markDidAlertNewVersion()
    }
}
