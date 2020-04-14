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

final class UserDetailViewController: RefreshableViewController {
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
            anchorHorizontalMenuViewToAnchorTableViewCell()
        }
    }
    private var yOffsetNeededToPinHorizontalViewToUtileBarView: CGFloat {
        let yOffset = userInfoTableViewCell.bounds.height + userInfoTableViewCell.bounds.height - simpleNavigationBarView.bounds.height
        return yOffset
    }
    private var anchorHorizontalMenuToMenuAnchorTableViewCell = true
    
    var historyRecordableDelegate: HistoryRecordable?
    
    private var adjustedTableViewContentOffset = false
    
    // Pagable managers
    private var reviewPagableManager: PagableManager<UserReview>!
    
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
        HorizontalMenuAnchorTableViewCell.register(with: tableView)
        UserInfoTableViewCell.register(with: tableView)
        
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        
        // observe when tableView is scrolled to animate alphas because scrollViewDidScroll doesn't capture enough event.
        tableViewContentOffsetObserver = tableView.observe(\UITableView.contentOffset, options: [.new]) { [weak self] (tableView, _) in
            self?.anchorHorizontalMenuViewToAnchorTableViewCell()
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
    
    private func anchorHorizontalMenuViewToAnchorTableViewCell() {
           guard let horizontalMenuAnchorTableViewCell = horizontalMenuAnchorTableViewCell, anchorHorizontalMenuToMenuAnchorTableViewCell else { return }
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
            }
        }
    }
    
    private func initPagableManagers() {
        reviewPagableManager = PagableManager<UserReview>(options: ["<USER_ID>": userProfile!.id])
        reviewPagableManager.delegate = self
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
        endRefreshing()
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
        case .albumCollection: Analytics.logEvent("view_user_album_collection", parameters: nil)
        case .wantedList: Analytics.logEvent("view_user_wanted_list", parameters: nil)
        case .tradeList: Analytics.logEvent("view_user_trade_list", parameters: nil)
        case .submittedBands: Analytics.logEvent("view_user_submitted_bands", parameters: nil)
        case .modificationHistory: Analytics.logEvent("view_user_modification_history", parameters: nil)
        }
    }
    
    private func pinHorizontalMenuViewThenRefreshAndScrollTableView() {
        anchorHorizontalMenuToMenuAnchorTableViewCell = false
        horizontalMenuViewTopConstraint.constant = simpleNavigationBarView.frame.origin.y + simpleNavigationBarView.frame.height
        tableView.reloadSections([1], with: .none)
        tableView.scrollToRow(at: IndexPath(row: 1, section: 0), at: .top, animated: false)
        tableView.setContentOffset(.init(x: 0, y: yOffsetNeededToPinHorizontalViewToUtileBarView), animated: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + CATransaction.animationDuration()) { [weak self] in
            guard let self = self else { return }
            self.setTableViewBottomInsetToFillBottomSpace()
            self.anchorHorizontalMenuToMenuAnchorTableViewCell = true
        }
    }
    
    private func setTableViewBottomInsetToFillBottomSpace() {
        let minimumBottomInset = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        self.tableView.contentInset.bottom = max(minimumBottomInset, screenHeight - self.tableView.contentSize.height + self.yOffsetNeededToPinHorizontalViewToUtileBarView - minimumBottomInset)
    }
}

// MARK: - UITableViewDelegate
extension UserDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
        case .reviews: return reviewPagableManager.objects.count
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, 0): return userInfoTableViewCell(forRowAt: indexPath)
        case (0, 1): return horizontalMenuAnchorTableViewCell(forRowAt: indexPath)
        default: break
        }
        
        switch currentMenuOption {
        case .reviews: return userReviewTableViewCell(forRowAt: indexPath)
        default: return UITableViewCell()
        }
    }
    
    private func userReviewCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    private func userInfoTableViewCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UserInfoTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.bind(with: userProfile!)
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
        return UITableViewCell()
    }
}
