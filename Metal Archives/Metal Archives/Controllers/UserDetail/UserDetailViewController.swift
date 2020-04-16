//
//  UserDetailViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 14/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Floaty
import FirebaseAnalytics
import MBProgressHUD
import Toaster

final class UserDetailViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var simpleNavigationBarView: SimpleNavigationBarView!
    @IBOutlet private weak var floaty: Floaty!
    
    var urlString: String!
    
    private var userProfile: UserProfile?
    
    private var currentMenuOption: UserMenuOption = .reviews
    private var userInfoTableViewCell = UserInfoTableViewCell()
    private var tableViewContentOffsetObserver: NSKeyValueObservation?
    
    // Floating menu
    private var horizontalMenuView: HorizontalMenuView!
    private var horizontalMenuViewTopConstraint: NSLayoutConstraint!
    private var horizontalMenuAnchorTableViewCell: HorizontalMenuAnchorTableViewCell! {
        didSet {
            properlyAnchorHorizontalMenuWhenTableViewIsScrolled()
        }
    }
    private var yOffsetNeededToPinHorizontalViewToUtileBarView: CGFloat {
        let yOffset = userInfoTableViewCell.bounds.height
        return yOffset
    }
    private var anchoredHorizontalMenuToMenuAnchorTableViewCell = true
    
    var historyRecordableDelegate: HistoryRecordable?
    
    private var adjustedTableViewContentOffset = false
    
    // Pagable managers
    private var reviewPagableManager: PagableManager<UserReview>!
    private var albumCollectionPagableManager: PagableManager<UserAlbumCollection>!
    private var wantedReleasePagableManager: PagableManager<UserWantedRelease>!
    private var releaseForTradePagableManager: PagableManager<UserReleaseForTrade>!
    private var submittedBandPagableManager: PagableManager<SubmittedBand>!
    private var modificationHistoryPagableManager: PagableManager<ModificationRecord>!
    
    private var currentUserReviewOrder: UserReviewOrder = .dateDescending
    private var currentSubmittedBandOrder: SubmittedBandOrder = .dateDescending
    
    deinit {
        print("UserDetailViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        initFloaty()
        initSimpleNavigationBarView()
        initHorizontalMenuView()
        fetchUserProfile()
        // bring floaty to front because it is overlapped by horizontalMenuView
        view.bringSubviewToFront(floaty)
        Analytics.logEvent("view_user_detail", parameters: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UIDevice.current.userInterfaceIdiom == .pad && !adjustedTableViewContentOffset {
            tableView.setContentOffset(.init(x: 0, y: screenHeight / 3), animated: false)
            adjustedTableViewContentOffset = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingToParent {
            tableViewContentOffsetObserver?.invalidate()
            tableViewContentOffsetObserver = nil
        }
    }
    
    private func configureTableView() {
        LoadingTableViewCell.register(with: tableView)
        SimpleTableViewCell.register(with: tableView)
        HorizontalMenuAnchorTableViewCell.register(with: tableView)
        UserInfoTableViewCell.register(with: tableView)
        UserReviewTableViewCell.register(with: tableView)
        UserCollectionTableViewCell.register(with: tableView)
        UserReviewOrderTableViewCell.register(with: tableView)
        SubmittedBandOrderTableViewCell.register(with: tableView)
        SubmittedBandTableViewCell.register(with: tableView)
        ModificationRecordTableViewCell.register(with: tableView)
        
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        
        // observe when tableView is scrolled to animate alphas because scrollViewDidScroll doesn't capture enough event.
        tableViewContentOffsetObserver = tableView.observe(\UITableView.contentOffset, options: [.new]) { [weak self] (tableView, _) in
            self?.properlyAnchorHorizontalMenuWhenTableViewIsScrolled()
        }
    }
    
    private func initFloaty() {
        floaty.customizeAppearance()
        
        floaty.addBackToHomepageItem(navigationController) {
            Analytics.logEvent("back_to_home_from_user_detail", parameters: nil)
        }
        
        floaty.addStartNewSearchItem(navigationController) {
            Analytics.logEvent("start_new_search_from_user_detail", parameters: nil)
        }
        
        floaty.addItem("Share this user", icon: UIImage(named: Ressources.Images.share)) { [unowned self] _ in
            self.shareUser()
        }
    }
    
    private func initSimpleNavigationBarView() {
        simpleNavigationBarView.setAlphaForBackgroundAndTitleLabel(1)
        simpleNavigationBarView.didTapLeftButton = { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
        
        simpleNavigationBarView.setRightButtonIcon(UIImage(named: Ressources.Images.share))
        simpleNavigationBarView.didTapRightButton = { [unowned self] in
            self.shareUser()
        }
    }
    
    private func initHorizontalMenuView() {
        let releaseMenuOptionStrings = UserMenuOption.allCases.map({return $0.description})
        horizontalMenuView = HorizontalMenuView(options: releaseMenuOptionStrings, font: Settings.currentFontSize.secondaryTitleFont, normalColor: Settings.currentTheme.bodyTextColor, highlightColor: Settings.currentTheme.secondaryTitleColor)
        horizontalMenuView.backgroundColor = Settings.currentTheme.backgroundColor
        horizontalMenuView.isHidden = true
        horizontalMenuView.delegate = self
        view.addSubview(horizontalMenuView)
        
        horizontalMenuView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            horizontalMenuView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            horizontalMenuView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            horizontalMenuView.heightAnchor.constraint(equalToConstant: horizontalMenuView.intrinsicHeight)
            ])
        horizontalMenuViewTopConstraint = horizontalMenuView.topAnchor.constraint(equalTo: view.topAnchor)
        horizontalMenuViewTopConstraint.isActive = true
    }
    
    private func properlyAnchorHorizontalMenuWhenTableViewIsScrolled() {
           guard let horizontalMenuAnchorTableViewCell = horizontalMenuAnchorTableViewCell, anchoredHorizontalMenuToMenuAnchorTableViewCell else { return }
           let horizontalMenuAnchorTableViewCellFrameInView = horizontalMenuAnchorTableViewCell.positionIn(view: view)
       
           horizontalMenuView.isHidden = false
           horizontalMenuViewTopConstraint.constant = max(
               horizontalMenuAnchorTableViewCellFrameInView.origin.y, simpleNavigationBarView.frame.origin.y + simpleNavigationBarView.frame.height)
       }
    
    private func shareUser() {
        guard let userProfile = self.userProfile, let url = URL(string: urlString) else { return }
        
        self.presentAlertOpenURLInBrowsers(url, alertTitle: "View \(userProfile.username ?? "") in browser", alertMessage: urlString, shareMessage: "Share this user URL")
        
        Analytics.logEvent("share_user", parameters: nil)
    }
    
    private func fetchUserProfile() {
        floaty.isHidden = true
        showHUD(hideNavigationBar: true)
        
        RequestHelper.UserDetail.fetchUserProfile(urlString: urlString) { [weak self] (userProfile, error) in
            guard let self = self else { return }
        
            self.hideHUD()
            
            if let error = error {
                Toast.displayMessageShortly(error.localizedDescription)
                self.dismiss(animated: true, completion: nil)
            } else if let userProfile = userProfile {
                self.floaty.isHidden = false
                self.userProfile = userProfile
                self.simpleNavigationBarView.setTitle(userProfile.username)
                self.initPagableManagers()
                self.reviewPagableManager.fetch()
                self.tableView.reloadData()
                self.historyRecordableDelegate?.loaded(urlString: self.urlString, nameOrTitle: userProfile.username, thumbnailUrlString: nil, objectType: .user)
            }
        }
    }
    
    private func initPagableManagers() {
        initReviewPagableManager()
        
        let options = ["<USER_ID>": userProfile!.id!]
        
        albumCollectionPagableManager = PagableManager<UserAlbumCollection>(options: options)
        albumCollectionPagableManager.delegate = self
        
        wantedReleasePagableManager = PagableManager<UserWantedRelease>(options: options)
        wantedReleasePagableManager.delegate = self
        
        releaseForTradePagableManager = PagableManager<UserReleaseForTrade>(options: options)
        releaseForTradePagableManager.delegate = self
        
        initSubmittedBandPagableManager()
        
        modificationHistoryPagableManager = PagableManager<ModificationRecord>(options: options)
        modificationHistoryPagableManager.delegate = self
    }
    
    private func initReviewPagableManager() {
        var completeOptions = currentUserReviewOrder.options
        completeOptions["<USER_ID>"] = userProfile!.id!
        reviewPagableManager = PagableManager<UserReview>(options: completeOptions)
        reviewPagableManager.delegate = self
    }
    
    private func initSubmittedBandPagableManager() {
        var completeOptions = currentSubmittedBandOrder.options
        completeOptions["<USER_ID>"] = userProfile!.id!
        submittedBandPagableManager = PagableManager<SubmittedBand>(options: completeOptions)
        submittedBandPagableManager.delegate = self
    }
    
    private func displayUserReviewOrderViewController(sourceRect: CGRect) {
        let userReviewOrderViewController = UIStoryboard(name: "UserDetail", bundle: nil).instantiateViewController(withIdentifier: "UserReviewOrderViewController") as! UserReviewOrderViewController
        userReviewOrderViewController.currentOrder = currentUserReviewOrder
        userReviewOrderViewController.modalPresentationStyle = .popover
        userReviewOrderViewController.popoverPresentationController?.permittedArrowDirections = .any
        
        userReviewOrderViewController.popoverPresentationController?.delegate = self
        userReviewOrderViewController.popoverPresentationController?.sourceView = view
    
        userReviewOrderViewController.popoverPresentationController?.sourceRect = sourceRect
        
        userReviewOrderViewController.selectedOrder = { [unowned self] (order) in
            self.currentUserReviewOrder = order
            self.initReviewPagableManager()
            self.reviewPagableManager.reset()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                self.reviewPagableManager.fetch()
            }
        }
        
        present(userReviewOrderViewController, animated: true, completion: nil)
    }
    
    private func displaySubmittedBandOrderViewController(sourceRect: CGRect) {
        let submittedBandOrderViewController = UIStoryboard(name: "UserDetail", bundle: nil).instantiateViewController(withIdentifier: "SubmittedBandOrderViewController") as! SubmittedBandOrderViewController
        submittedBandOrderViewController.currentOrder = currentSubmittedBandOrder
        submittedBandOrderViewController.modalPresentationStyle = .popover
        submittedBandOrderViewController.popoverPresentationController?.permittedArrowDirections = .any
        
        submittedBandOrderViewController.popoverPresentationController?.delegate = self
        submittedBandOrderViewController.popoverPresentationController?.sourceView = view
    
        submittedBandOrderViewController.popoverPresentationController?.sourceRect = sourceRect
        
        submittedBandOrderViewController.selectedOrder = { [unowned self] (order) in
            self.currentSubmittedBandOrder = order
            self.initSubmittedBandPagableManager()
            self.submittedBandPagableManager.reset()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                self.submittedBandPagableManager.fetch()
            }
        }
        
        present(submittedBandOrderViewController, animated: true, completion: nil)
    }
}

// MARK: - UIPopoverPresentationControllerDelegate
extension UserDetailViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

// MARK: - PagableManagerDelegate
extension UserDetailViewController: PagableManagerDelegate {
    func pagableManagerDidBeginFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        showHUD()
    }
    
    func pagableManagerDidFailFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        hideHUD()
        Toast.displayMessageShortly(errorLoadingMessage)
    }
    
    func pagableManagerDidFinishFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        hideHUD()
        tableView.reloadData()
    }
}

// MARK: - HorizontalMenuViewDelegate
extension UserDetailViewController: HorizontalMenuViewDelegate {
    func horizontalMenu(_ horizontalMenu: HorizontalMenuView, didSelectItemAt index: Int) {
        currentMenuOption = UserMenuOption(rawValue: index) ?? .reviews
        pinHorizontalMenuViewThenRefreshAndScrollTableView()
        
        switch currentMenuOption {
        case .reviews: Analytics.logEvent("view_user_reviews", parameters: nil)
        case .albumCollection:
            if albumCollectionPagableManager.moreToLoad {
                albumCollectionPagableManager.fetch()
            }
            
            Analytics.logEvent("view_user_album_collection", parameters: nil)
            
        case .wantedList:
            if wantedReleasePagableManager.moreToLoad {
                wantedReleasePagableManager.fetch()
            }
            
            Analytics.logEvent("view_user_wanted_list", parameters: nil)
            
        case .tradeList:
            if releaseForTradePagableManager.moreToLoad {
                releaseForTradePagableManager.fetch()
            }
            
            Analytics.logEvent("view_user_trade_list", parameters: nil)
            
        case .submittedBands:
            if submittedBandPagableManager.moreToLoad {
                submittedBandPagableManager.fetch()
            }
            Analytics.logEvent("view_user_submitted_bands", parameters: nil)
            
        case .modificationHistory:
            if modificationHistoryPagableManager.moreToLoad {
                modificationHistoryPagableManager.fetch()
            }
            
            Analytics.logEvent("view_user_modification_history", parameters: nil)
        }
    }
    
    private func pinHorizontalMenuViewThenRefreshAndScrollTableView() {
        anchoredHorizontalMenuToMenuAnchorTableViewCell = false
        horizontalMenuViewTopConstraint.constant = simpleNavigationBarView.frame.origin.y + simpleNavigationBarView.frame.height
        tableView.reloadSections([1], with: .none)
        tableView.scrollToRow(at: IndexPath(row: 1, section: 0), at: .top, animated: false)
        tableView.setContentOffset(.init(x: 0, y: yOffsetNeededToPinHorizontalViewToUtileBarView), animated: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + CATransaction.animationDuration()) { [weak self] in
            guard let self = self else { return }
            self.setTableViewBottomInsetToFillBottomSpace()
            self.anchoredHorizontalMenuToMenuAnchorTableViewCell = true
        }
    }
    
    private func setTableViewBottomInsetToFillBottomSpace() {
        let minimumBottomInset = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        tableView.contentInset.bottom = max(minimumBottomInset, screenHeight - tableView.contentSize.height + yOffsetNeededToPinHorizontalViewToUtileBarView - minimumBottomInset )
    }
}

// MARK: - UITableViewDelegate
extension UserDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard indexPath.section > 0 else { return }
        
        switch currentMenuOption {
        case .reviews:
            guard reviewPagableManager.objects.count > 0 && indexPath.row > 0 else { return }
            takeActionFor(actionableObject: reviewPagableManager.objects[indexPath.row - 1])
            Analytics.logEvent("select_user_review", parameters: nil)
            
        case .albumCollection:
            guard albumCollectionPagableManager.objects.count > 0 else { return }
            takeActionFor(actionableObject: albumCollectionPagableManager.objects[indexPath.row])
            Analytics.logEvent("select_user_collection_release", parameters: nil)
            
        case .wantedList:
            guard wantedReleasePagableManager.objects.count > 0 else { return }
            takeActionFor(actionableObject: wantedReleasePagableManager.objects[indexPath.row])
            Analytics.logEvent("select_user_wanted_release", parameters: nil)
            
        case .tradeList:
            guard releaseForTradePagableManager.objects.count > 0 else { return }
            takeActionFor(actionableObject: releaseForTradePagableManager.objects[indexPath.row])
            Analytics.logEvent("select_user_trade_release", parameters: nil)
            
        case .submittedBands:
            guard submittedBandPagableManager.objects.count > 0 && indexPath.row > 0 else { return }
            let submittedBand = submittedBandPagableManager.objects[indexPath.row - 1]
            pushBandDetailViewController(urlString: submittedBand.band.urlString, animated: true)
            Analytics.logEvent("select_user_submitted_band", parameters: nil)
            
        case .modificationHistory:
            guard modificationHistoryPagableManager.objects.count > 0 else { return }
            takeActionFor(actionableObject: modificationHistoryPagableManager.objects[indexPath.row])
            Analytics.logEvent("select_user_modification_record", parameters: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNormalMagnitude
        }
        
        return Settings.spaceBetweenInfoAndDetailSection
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }
        
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: screenWidth, height: Settings.spaceBetweenInfoAndDetailSection)))
        view.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        return view
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch currentMenuOption {
        case .reviews:
            if reviewPagableManager.moreToLoad && indexPath.row == reviewPagableManager.objects.count - 1 {
                reviewPagableManager.fetch()
                Analytics.logEvent("fetch_more_user_reviews", parameters: nil)
            }
            
        case .albumCollection:
            if albumCollectionPagableManager.moreToLoad && indexPath.row == albumCollectionPagableManager.objects.count - 1 {
                albumCollectionPagableManager.fetch()
                Analytics.logEvent("fetch_more_user_album_collection", parameters: nil)
            }
            
        case .wantedList:
            if wantedReleasePagableManager.moreToLoad && indexPath.row == wantedReleasePagableManager.objects.count - 1 {
                wantedReleasePagableManager.fetch()
                Analytics.logEvent("fetch_more_user_wanted_list", parameters: nil)
            }
            
        case .tradeList:
            if releaseForTradePagableManager.moreToLoad && indexPath.row == releaseForTradePagableManager.objects.count - 1 {
                releaseForTradePagableManager.fetch()
                Analytics.logEvent("fetch_more_user_trade_list", parameters: nil)
            }
            
        case .submittedBands:
            if submittedBandPagableManager.moreToLoad && indexPath.row == submittedBandPagableManager.objects.count - 1 {
                submittedBandPagableManager.fetch()
                Analytics.logEvent("fetch_more_user_submitted_bands", parameters: nil)
            }
            
        case .modificationHistory:
            if modificationHistoryPagableManager.moreToLoad && indexPath.row == modificationHistoryPagableManager.objects.count - 1 {
                modificationHistoryPagableManager.fetch()
                Analytics.logEvent("fetch_more_user_modification_history", parameters: nil)
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension UserDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let _ = userProfile else { return 0 }
        
        if section == 0 {
            return 2
        }
        
        switch currentMenuOption {
        case .reviews:
            if reviewPagableManager.moreToLoad {
                return reviewPagableManager.objects.count + 2 // 1 for order cell & 1 for loading cell
            } else if reviewPagableManager.objects.isEmpty {
                return 1 // Just 1 for message cell
            }
            
            return reviewPagableManager.objects.count + 1 // plus 1 for order cell
            
        case .albumCollection:
            if albumCollectionPagableManager.moreToLoad {
                return albumCollectionPagableManager.objects.count + 1
            } else if albumCollectionPagableManager.objects.isEmpty {
                return 1
            }
            
            return albumCollectionPagableManager.objects.count
            
        case .wantedList:
            if wantedReleasePagableManager.moreToLoad {
                return wantedReleasePagableManager.objects.count + 1
            } else if wantedReleasePagableManager.objects.isEmpty {
                return 1
            }
            
            return wantedReleasePagableManager.objects.count
            
        case .tradeList:
            if releaseForTradePagableManager.moreToLoad {
                return releaseForTradePagableManager.objects.count + 1
            } else if releaseForTradePagableManager.objects.isEmpty {
                return 1
            }
            
            return releaseForTradePagableManager.objects.count
            
        case .submittedBands:
            if submittedBandPagableManager.moreToLoad {
                return submittedBandPagableManager.objects.count + 2 // 1 for order cell & 1 for loading cell
            } else if submittedBandPagableManager.objects.isEmpty {
                return 1 // Just 1 for message cell
            }
            
            return submittedBandPagableManager.objects.count + 1 // plus 1 for order cell
            
        case .modificationHistory:
            if modificationHistoryPagableManager.moreToLoad {
                return modificationHistoryPagableManager.objects.count + 1
            } else if modificationHistoryPagableManager.objects.isEmpty {
                return 1
            }
            
            return modificationHistoryPagableManager.objects.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, 0): return userInfoTableViewCell(forRowAt: indexPath)
        case (0, 1): return horizontalMenuAnchorTableViewCell(forRowAt: indexPath)
        default: break
        }
        
        switch currentMenuOption {
        case .reviews:
            return userReviewTableViewCell(forRowAt: indexPath)
            
        case .albumCollection, .wantedList, .tradeList:
            return userCollectionTableViewCell(forRowAt: indexPath)
            
        case .submittedBands:
            return submittedBandTableViewCell(forRowAt: indexPath)
            
        case .modificationHistory:
            return modificationRecordTableViewCell(forRowAt: indexPath)
        }
    }
    
    private func simpleTableViewCell(forRowAt indexPath: IndexPath, text: String) -> UITableViewCell {
        let cell = SimpleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.displayAsItalicBodyText()
        cell.fill(with: text)
        return cell
    }
    
    private func loadingTableViewCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.displayIsLoading()
        
        return cell
    }
    
    private func userInfoTableViewCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UserInfoTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.bind(with: userProfile!)
        cell.didTapHomepageLabel = { [unowned self] in
            guard let homepageUrlString = self.userProfile?.homepage, let url = URL(string: homepageUrlString) else { return }
            self.presentAlertOpenURLInBrowsers(url, alertMessage: "View \(self.userProfile?.username ?? "user")'s homepage in browser")
        }
        userInfoTableViewCell = cell
        return cell
    }
    
    private func horizontalMenuAnchorTableViewCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = HorizontalMenuAnchorTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        horizontalMenuAnchorTableViewCell = cell
        horizontalMenuAnchorTableViewCell.contentView.heightAnchor.constraint(equalToConstant: horizontalMenuView.intrinsicHeight).isActive = true
        return cell
    }
    
    private func userReviewTableViewCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        if (!reviewPagableManager.moreToLoad && reviewPagableManager.objects.isEmpty) {
            return simpleTableViewCell(forRowAt: indexPath, text: "This user has written no review")
        }
        
        if indexPath.row == 0 {
            let orderCell = UserReviewOrderTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            orderCell.setOrderButtonTitle(currentUserReviewOrder)
            orderCell.tappedOrderButton = { [unowned self] in
                self.displayUserReviewOrderViewController(sourceRect: orderCell.positionIn(view: self.view))
            }
            return orderCell
        }
        
        if reviewPagableManager.moreToLoad && indexPath.row == reviewPagableManager.objects.count + 1 {
            return loadingTableViewCell(forRowAt: indexPath)
        }
        
        let cell = UserReviewTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let userReview = reviewPagableManager.objects[indexPath.row - 1]
        cell.bind(with: userReview)
        cell.tappedThumbnailImageView = { [unowned self] in
            self.presentPhotoViewerWithCacheChecking(photoUrlString: userReview.release.imageURLString, description: userReview.release.title, fromImageView: cell.thumbnailImageView)
        }
        return cell
    }
    
    private func userCollectionTableViewCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        let shouldDisplayLoadingCell: Bool
        let noItemMessage: String
        let release: UserCollection?
        switch currentMenuOption {
        case .albumCollection:
            shouldDisplayLoadingCell = albumCollectionPagableManager.moreToLoad && indexPath.row == albumCollectionPagableManager.objects.count
            if shouldDisplayLoadingCell {
                noItemMessage = ""
                release = nil
                break
            }
            
            noItemMessage = "Album collection is empty or private"
            if albumCollectionPagableManager.objects.count > 0 {
                release = albumCollectionPagableManager.objects[indexPath.row]
            } else {
                release = nil
            }
            
        case .wantedList:
            shouldDisplayLoadingCell = wantedReleasePagableManager.moreToLoad && indexPath.row == wantedReleasePagableManager.objects.count
            if shouldDisplayLoadingCell {
                noItemMessage = ""
                release = nil
                break
            }
            
            noItemMessage = "Wanted list is empty or private"
            if wantedReleasePagableManager.objects.count > 0 {
                release = wantedReleasePagableManager.objects[indexPath.row]
            } else {
                release = nil
            }
        
        case .tradeList:
            shouldDisplayLoadingCell = releaseForTradePagableManager.moreToLoad && indexPath.row == releaseForTradePagableManager.objects.count
            if shouldDisplayLoadingCell {
                noItemMessage = ""
                release = nil
                break
            }
            
            noItemMessage = "Trade list is empty or private"
            if releaseForTradePagableManager.objects.count > 0 {
                release = releaseForTradePagableManager.objects[indexPath.row]
            } else {
                release = nil
            }
            
        default:
            shouldDisplayLoadingCell = false
            noItemMessage = ""
            release = nil
        }
        
        if shouldDisplayLoadingCell {
            return loadingTableViewCell(forRowAt: indexPath)
        }
        
        if let release = release {
            let cell = UserCollectionTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            cell.fill(with: release)
            cell.tappedThumbnailImageView = { [unowned self] in
                self.presentPhotoViewerWithCacheChecking(photoUrlString: release.release.imageURLString, description: release.release.title, fromImageView: cell.thumbnailImageView)
            }
            return cell
        }
        
        return simpleTableViewCell(forRowAt: indexPath, text: noItemMessage)
    }
    
    private func submittedBandTableViewCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        if (!submittedBandPagableManager.moreToLoad && submittedBandPagableManager.objects.isEmpty) {
            return simpleTableViewCell(forRowAt: indexPath, text: "This user has not submitted any band yet.")
        }
        
        if indexPath.row == 0 {
            let orderCell = SubmittedBandOrderTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            orderCell.setOrderButtonTitle(currentUserReviewOrder)
            orderCell.tappedOrderButton = { [unowned self] in
            self.displaySubmittedBandOrderViewController(sourceRect: orderCell.positionIn(view: self.view))
            }
            return orderCell
        }
        
        if submittedBandPagableManager.moreToLoad && indexPath.row == submittedBandPagableManager.objects.count + 1 {
            return loadingTableViewCell(forRowAt: indexPath)
        }

        let cell = SubmittedBandTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let submittedBand = submittedBandPagableManager.objects[indexPath.row - 1]
        cell.bind(with: submittedBand)
        cell.tappedThumbnailImageView = { [unowned self] in
            self.presentPhotoViewerWithCacheChecking(photoUrlString: submittedBand.band.imageURLString, description: submittedBand.band.name, fromImageView: cell.thumbnailImageView)
        }
        return cell
    }
    
    private func modificationRecordTableViewCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        if modificationHistoryPagableManager.moreToLoad && indexPath.row == modificationHistoryPagableManager.objects.count {
            return loadingTableViewCell(forRowAt: indexPath)
        }
        
        if modificationHistoryPagableManager.objects.isEmpty {
            return simpleTableViewCell(forRowAt: indexPath, text: "This user has not modified anything.")
        }
        
        let record = modificationHistoryPagableManager.objects[indexPath.row]
        let cell = ModificationRecordTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.bind(with: record)
        cell.tappedThumbnailImageView = { [unowned self] in
            self.presentPhotoViewerWithCacheChecking(photoUrlString: record.thumbnailableObject?.imageURLString, description: record.name, fromImageView: cell.thumbnailImageView)
        }
        return cell
    }
}
