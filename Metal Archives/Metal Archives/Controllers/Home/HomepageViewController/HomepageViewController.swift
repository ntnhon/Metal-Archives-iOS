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
    @IBOutlet private weak var searchButton: UIButton!
    
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
    
   
    
    /// English and Latin title, don't mind weird characters, they are needed for flipped effect (last character)
    private let navBarTitle = (english: "Metal archiveÎ", latin: "Encyclopaedia metalluÈ")
    private var isDisplayingEnglishTitle = true {
        didSet {
            self.title = self.isDisplayingEnglishTitle ? self.navBarTitle.english : self.navBarTitle.latin
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addToggleMenuButton()
        self.initSearchButton()
        self.loadHomepage()
        self.initObservers()
        self.alertNewVersion()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Homepage", style: .plain, target: nil, action: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.title = nil
        self.stylizedNavBar(false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.stylizedNavBar(true)
        self.isDisplayingEnglishTitle = true
    }
    
    private func stylizedNavBar(_ stylized: Bool) {
        let attrs = stylized ?
            [
            NSAttributedString.Key.foregroundColor: Settings.currentTheme.tableViewBackgroundColor,
            NSAttributedString.Key.font: UIFont(name: "PastorofMuppets", size: 34)!
            ] : nil
        self.navigationController?.navigationBar.titleTextAttributes = attrs
    }
    
    override func initAppearance() {
        super.initAppearance()

        //Hide 1st header
        self.tableView.contentInset = UIEdgeInsets(top: -CGFloat.leastNormalMagnitude, left: 0, bottom: 0, right: 0)
        
        LoadingTableViewCell.register(with: self.tableView)
        NewsTableViewCell.register(with: self.tableView)
        StatisticTableViewCell.register(with: self.tableView)
        AdditionOrUpdateTableViewCell.register(with: self.tableView)
        LatestReviewsTableViewCell.register(with: self.tableView)
        UpcomingAlbumTableViewCell.register(with: self.tableView)
        ViewMoreTableViewCell.register(with: self.tableView)
    }

    private func initSearchButton() {
        self.searchButton.backgroundColor = Settings.currentTheme.backgroundColor
        self.searchButton.layer.shadowColor = Settings.currentTheme.bodyTextColor.cgColor
        self.searchButton.layer.shadowRadius = 10
        self.searchButton.layer.shadowOpacity = 0.5
        self.searchButton.layer.shadowOffset = CGSize(width: 2, height: 5)
        self.searchButton.layer.cornerRadius = self.searchButton.frame.height/2
        self.searchButton.layer.borderWidth = 0.2
        self.searchButton.layer.borderColor = Settings.currentTheme.bodyTextColor.withAlphaComponent(0.5).cgColor
    }
    
    private func initObservers() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.OpenSearchModule, object: nil, queue: nil) { (notification) in
            self.didTapSearchButton()
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
            
            self.presentReviewController(urlString: reviewURLString, animated: true, completion: nil)
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
    
    override var prefersStatusBarHidden: Bool {
        return self.navigationController?.isNavigationBarHidden ?? false
    }
    
    override func refresh() {
        self.statisticAttrString = nil
        self.newsPagableManager.reset()
        self.bandAdditionPagableManager.reset()
        self.bandUpdatePagableManager.reset()
        self.latestReviewPagableManager.reset()
        self.upcomingAlbumPagableManager.reset()
        
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
        
        self.newsPagableManager.fetch { [weak self] (error) in
            self?.tableView.reloadData()
        }
        
        //Latest additions
        self.bandAdditionPagableManager = PagableManager<BandAddition>(options: ["<YEAR_MONTH>": monthList[0].requestParameterString])
        self.bandAdditionPagableManager.fetch { [weak self] (error) in
            self?.respondToAdditionTypeChange()
        }
        
        self.labelAdditionPagableManager = PagableManager<LabelAddition>(options: ["<YEAR_MONTH>": monthList[0].requestParameterString]) //Initilized but not start fetching
        self.artistAdditionPagableManager = PagableManager<ArtistAddition>(options: ["<YEAR_MONTH>": monthList[0].requestParameterString]) //Initilized but not start fetching
        
        //Latest updates
        self.bandUpdatePagableManager = PagableManager<BandUpdate>(options: ["<YEAR_MONTH>": monthList[0].requestParameterString])
        self.bandUpdatePagableManager.fetch { [weak self] (error) in
            self?.respondToUpdateTypeChange()
        }
        self.labelUpdatePagableManager = PagableManager<LabelUpdate>(options: ["<YEAR_MONTH>": monthList[0].requestParameterString]) //Initilized but not start fetching
        self.artistUpdatePagableManager = PagableManager<ArtistUpdate>(options: ["<YEAR_MONTH>": monthList[0].requestParameterString]) //Initilized but not start fetching
        
        
        self.latestReviewPagableManager =  PagableManager<LatestReview>(options: ["<YEAR_MONTH>": monthList[0].requestParameterString])
        self.latestReviewPagableManager.fetch { [weak self] (error) in
            self?.tableView.reloadData()
        }
        
        self.upcomingAlbumPagableManager.fetch { [weak self] (error) in
            self?.tableView.reloadData()
        }
    }
    
    @IBAction private func didTapSearchButton() {
        guard let searchViewController = UIStoryboard(name: "Search", bundle: nil).instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController else {
            return
        }
        
        self.navigationController?.pushViewController(searchViewController, animated: true)
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
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func respondToAdditionTypeChange() {
        switch latestAdditionType {
        case .bands:
            if let _ = bandAdditionPagableManager.totalRecords {
                self.latestAdditionsDelegate?.didFinishFetchingBandAdditionOrUpdate(bandAdditionPagableManager.objects)
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
                self.latestAdditionsDelegate?.didFinishFetchingLabelAdditionOrUpdate(labelAdditionPagableManager.objects)
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
                self.latestAdditionsDelegate?.didFinishFetchingArtistAdditionOrUpdate(artistAdditionPagableManager.objects)
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
                self.latestUpdatesDelegate?.didFinishFetchingBandAdditionOrUpdate(bandUpdatePagableManager.objects)
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
                self.latestUpdatesDelegate?.didFinishFetchingLabelAdditionOrUpdate(labelUpdatePagableManager.objects)
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
                self.latestUpdatesDelegate?.didFinishFetchingArtistAdditionOrUpdate(artistUpdatePagableManager.objects)
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

//MARK: - Segues
extension HomepageViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowLatestAdditions"{
            guard let latestAdditionsViewController = segue.destination as? LatestAdditionsOrUpdatesViewController else { return }
            latestAdditionsViewController.mode = .additions
        } else if segue.identifier == "ShowLatestUpdates" {
            guard let latestAdditionsViewController = segue.destination as? LatestAdditionsOrUpdatesViewController else { return }
            latestAdditionsViewController.mode = .updates
        }
    }
}

//MARK: - UIScrollViewDelegate
extension HomepageViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.isDisplayingEnglishTitle = scrollView.contentOffset.y <= 0
    }
}

//MARK: - UITableViewDelegate
extension HomepageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        //Section: Stats
        case 0: self.didSelectRowInStatisticsSection(at: indexPath)
        //Section: Upcoming albums
        case 5: self.didSelectRowInUpcomingAlbumsSection(at: indexPath)
        default: return
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //Hide 1st section header
        if section == 0 {
            return CGFloat.leastNormalMagnitude
        }
        return UITableView.automaticDimension
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

//MARK: UITableViewDatasource
extension HomepageViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        //6 sections: Stats, News, Latest additions, Latest updates, Latest reviews, Upcoming albums
        return 6
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 5: return self.numberOfRowsInUpcomingAlbumsSection()
        default: return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        //Section: Stats
        case 0: return self.cellForStatsSection(at: indexPath)
        //Section: News
        case 1: return self.cellForNewsSection(at: indexPath)
        //Section: Latets additions
        case 2: return self.cellForLatestAdditionsSection(at: indexPath)
        //Section: Latest updates
        case 3: return self.cellForLatestUpdatesSection(at: indexPath)
        //Section: Latest review
        case 4: return self.cellForLatestReviewsSection(at: indexPath)
        //Section: Upcoming albums
        case 5: return self.cellForUpcomingAlbumsSection(at: indexPath)
        default: return UITableViewCell()
        }
    }
}

//MARK: - View more cell
extension HomepageViewController {
    private func viewMoreCell(message: String, atIndex indexPath: IndexPath) -> ViewMoreTableViewCell {
        let cell = ViewMoreTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        cell.fill(message: message)
        return cell
    }
    
    private func loadingCell(atIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = LoadingTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        cell.displayIsLoading()
        return cell
    }
}

//MARK: - Section STATISTICS
extension HomepageViewController {
    private func cellForStatsSection(at indexPath: IndexPath) -> UITableViewCell {
        guard let `statisticAttrString` = self.statisticAttrString else {
            return self.loadingCell(atIndexPath: indexPath)
        }
        
        let cell = StatisticTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        cell.fill(with: statisticAttrString)
        return cell
    }
    
    private func didSelectRowInStatisticsSection(at indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ShowStatistics", sender: nil)
    }
}

//MARK: - Section NEWS
extension HomepageViewController {
    private func cellForNewsSection(at indexPath: IndexPath) -> UITableViewCell {
        //Don't check totalRecords is nil or not because News doesn't have such parameter
        guard self.newsPagableManager.objects.count > 0 else {
            return self.loadingCell(atIndexPath: indexPath)
        }
        
        let cell = NewsTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        cell.newsArray = self.newsPagableManager.objects
        cell.seeAll = {[unowned self] in
            let newsArchiveViewController = UIStoryboard(name: "NewsArchive", bundle: nil).instantiateViewController(withIdentifier: "NewsArchiveViewController" ) as! NewsArchiveViewController
            self.navigationController?.pushViewController(newsArchiveViewController, animated: true)
        }
        return cell
    }
}

//MARK: - Section LATEST ADDITIONS
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
        
        return cell
    }
}

//MARK: - Section LATEST UPDATES
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
        
        return cell
    }
}

//MARK: - Section LATEST REVIEWS
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
        
        return cell
    }
}

//MARK: - Section UPCOMING ALBUMS
extension HomepageViewController {
    private func numberOfRowsInUpcomingAlbumsSection() -> Int {
        guard let _ = self.upcomingAlbumPagableManager.totalRecords else {
            return 1
        }
        
        if self.upcomingAlbumPagableManager.objects.count > Settings.shortListDisplayCount {
            return Settings.shortListDisplayCount + 1
        }
        
        return self.upcomingAlbumPagableManager.objects.count + 1
    }
    
    private func cellForUpcomingAlbumsSection(at indexPath: IndexPath) -> UITableViewCell {
        guard let _ = self.upcomingAlbumPagableManager.totalRecords else {
            return self.loadingCell(atIndexPath: indexPath)
        }
        
        if indexPath.row == Settings.shortListDisplayCount || indexPath.row == self.upcomingAlbumPagableManager.objects.count {
            return self.viewMoreCell(message: "More upcoming albums", atIndex: indexPath)
        }
        
        let cell = UpcomingAlbumTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        
        let upcomingAlbum = self.upcomingAlbumPagableManager.objects[indexPath.row]
        cell.fill(with: upcomingAlbum)
        
        return cell
    }
    
    private func didSelectRowInUpcomingAlbumsSection(at indexPath: IndexPath) {
        guard let _ = self.upcomingAlbumPagableManager.totalRecords else {
            return
        }
        
        if indexPath.row == Settings.shortListDisplayCount || indexPath.row == self.upcomingAlbumPagableManager.objects.count {
            self.didSelectUpcomingAlbumsViewMore()
            return
        }
        
        let upcomingAlbum = self.upcomingAlbumPagableManager.objects[indexPath.row]
        self.takeActionFor(actionableObject: upcomingAlbum)
        
        Analytics.logEvent(AnalyticsEvent.SelectAnItemInHomepage, parameters: [AnalyticsParameter.ItemType: "UpcomingAlbum"])
    }
    
    private func didSelectUpcomingAlbumsViewMore() {
        self.performSegue(withIdentifier: "ShowUpcomingAlbums", sender: nil)
        
        Analytics.logEvent(AnalyticsEvent.SelectAnItemInHomepage, parameters: [AnalyticsParameter.ItemType: "Show more upcoming albums"])
    }
}

//MARK: - Alert new version
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
