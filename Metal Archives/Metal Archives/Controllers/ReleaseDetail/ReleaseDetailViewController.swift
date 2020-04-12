//
//  ReleaseDetailViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 05/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Toaster
import FirebaseAnalytics
import Crashlytics
import Floaty
import MBProgressHUD
import EventKitUI

//MARK: - Properties
final class ReleaseDetailViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var stretchyCoverSmokedImageView: SmokedImageView!
    @IBOutlet private weak var stretchyCoverSmokedImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var simpleNavigationBarView: SimpleNavigationBarView!
    @IBOutlet private weak var floaty: Floaty!
    
    var urlString: String!
    
    private var release: Release!
    private var currentReleaseMenuOption: ReleaseMenuOption = .trackList
    private var currentLineupType: LineUpType = .member
    private var isAscendingOrderReview = false
    private var tableViewContentOffsetObserver: NSKeyValueObservation?
    
    private var releaseTitleAndTypeTableViewCell = ReleaseTitleAndTypeTableViewCell()
    private var releaseInfoTableViewCell = ReleaseInfoTableViewCell()
    
    // Floating menu
    private var horizontalMenuView: HorizontalMenuView!
    private var horizontalMenuViewTopConstraint: NSLayoutConstraint!
    private var horizontalMenuAnchorTableViewCell: HorizontalMenuAnchorTableViewCell! {
        didSet {
            anchorHorizontalMenuViewToAnchorTableViewCell()
        }
    }
    private var yOffsetNeededToPinHorizontalViewToUtileBarView: CGFloat {
        let yOffset = releaseTitleAndTypeTableViewCell.bounds.height + releaseInfoTableViewCell.bounds.height - simpleNavigationBarView.bounds.height
        return yOffset
    }
    private var anchorHorizontalMenuToMenuAnchorTableViewCell = true
    
    var historyRecordableDelegate: HistoryRecordable?
    
    private var adjustedTableViewContentOffset = false
    
    private var addedReminderButton = false

    deinit {
        print("ReleaseDetailViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stretchyCoverSmokedImageViewHeightConstraint.constant = screenWidth
        configureTableView()
        initFloaty()
        initHorizontalMenuView()
        handleUtileBarViewActions()
        fetchRelease()
        // bring deezerButton to front because it is overlapped by horizontalMenuView
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
        stretchyCoverSmokedImageView.transform = .identity
    }
    
    private func fetchRelease() {
        floaty.isHidden = true
        showHUD(hideNavigationBar: true)
        
        MetalArchivesAPI.reloadRelease(urlString: urlString) { [weak self] (release, error) in
            guard let self = self else { return }
            if let _ = error as NSError? {
                self.showHUD()
                DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                    self.fetchRelease()
                })
            } else {
                self.hideHUD()
                guard let release = release else {
                    Toast.displayMessageShortly(errorLoadingMessage)
                    self.navigationController?.popViewController(animated: true)
                    return
                }
                self.floaty.isHidden = false
                self.release = release
                
                if let coverURLString = release.coverURLString, let coverURL = URL(string: coverURLString) {
                    self.stretchyCoverSmokedImageView.imageView.sd_setImage(with: coverURL, placeholderImage: nil, options: [.retryFailed], completed: { [weak self] (image, error, cacheType, url) in
                        self?.simpleNavigationBarView.setImageAsTitle(image, fallbackTitle: release.title, alwaysShowTitle: true, roundedCorner: true)
                    })
                } else {
                    self.tableView.contentInset = .init(top: self.simpleNavigationBarView.frame.origin.y + self.simpleNavigationBarView.frame.height + 10, left: 0, bottom: UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0, right: 0)
                    self.simpleNavigationBarView.setTitle(release.title)
                }
                
                self.updateBookmarkIconAndAddReminderOption()
                self.tableView.reloadData()
                
                // Delay this method to wait for info cells to be fully loaded
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    self.setTableViewBottomInsetToFillBottomSpace()
                })
                
                self.historyRecordableDelegate?.loaded(urlString: release.urlString, nameOrTitle: release.title, thumbnailUrlString: release.coverURLString, objectType: .release)
                
                Analytics.logEvent("view_release", parameters: ["release_title": release.title ?? "", "release_id": release.id ?? ""])
                
                Crashlytics.sharedInstance().setObjectValue(release.generalDescription, forKey: "release")
            }
        }
    }
    
    private func configureTableView() {
        SimpleTableViewCell.register(with: tableView)
        LoadingTableViewCell.register(with: tableView)
        ReleaseTitleAndTypeTableViewCell.register(with: tableView)
        ReleaseInfoTableViewCell.register(with: tableView)
        ReleaseElementTableViewCell.register(with: tableView)
        LineupOptionTableViewCell.register(with: tableView)
        ReleaseMemberTableViewCell.register(with: tableView)
        ReleaseReviewOptionTableViewCell.register(with: tableView)
        ReleaseReviewTableViewCell.register(with: tableView)
        ReleaseOtherVersionTableViewCell.register(with: tableView)
        HorizontalMenuAnchorTableViewCell.register(with: tableView)
        
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.contentInset = .init(top: stretchyCoverSmokedImageViewHeightConstraint.constant, left: 0, bottom: UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0, right: 0)
        
        // observe when tableView is scrolled to animate alphas because scrollViewDidScroll doesn't capture enough event.
        tableViewContentOffsetObserver = tableView.observe(\UITableView.contentOffset, options: [.new]) { [weak self] (tableView, _) in
            self?.calculateAndApplyAlphaForReleaseTitleTypeAndSimpleNavBar()
            self?.stretchyCoverSmokedImageView.calculateAndApplyAlpha(withTableView: tableView)
            self?.anchorHorizontalMenuViewToAnchorTableViewCell()
        }
        
        // detect taps on release's cover, have to do this because release's cover is overlaid by tableView
        tableView.backgroundView = UIView()
        let backgroundViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tableViewBackgroundViewTapped))
        tableView.backgroundView?.addGestureRecognizer(backgroundViewTapGestureRecognizer)
    }
    
    @objc private func tableViewBackgroundViewTapped() {
        presentReleaseCoverInPhotoViewer()
        
        Analytics.logEvent("view_release_cover", parameters: ["release_title": release.title ?? "", "release_id": release.id ?? ""])
    }
    
    private func presentReleaseCoverInPhotoViewer() {
        guard let release = release, let coverURLString = release.coverURLString else { return }
        presentPhotoViewer(photoUrlString: coverURLString, description: release.title, fromImageView: stretchyCoverSmokedImageView.imageView)
    }
    
    private func initFloaty() {
        floaty.customizeAppearance()
        
        floaty.addItem("Add to your collection", icon: UIImage(named: Ressources.Images.disc_collection)) { [unowned self] _ in
            self.addToCollection(type: .collection)
        }
        
        floaty.addItem("Add to your wanted list", icon: UIImage(named: Ressources.Images.wishlist)) { [unowned self] _ in
            self.addToCollection(type: .wanted)
        }
        
        floaty.addItem("Add to your trade list", icon: UIImage(named: Ressources.Images.sale)) { [unowned self] _ in
            self.addToCollection(type: .trade)
        }
        
        floaty.addItem("Deezer this release", icon: UIImage(named: Ressources.Images.deezer)) { [unowned self] _ in
            self.pushDeezerResultViewController(type: .album, term: self.release?.title ?? "")
        }
        
        floaty.addItem("Share this release", icon: UIImage(named: Ressources.Images.share)) { [unowned self] _ in
            guard let release = self.release, let url = URL(string: release.urlString) else { return }
            
            self.presentAlertOpenURLInBrowsers(url, alertTitle: "View \(release.title!) in browser", alertMessage: release.urlString, shareMessage: "Share this release URL")
            
            Analytics.logEvent("share_release", parameters: ["release_title": release.title ?? "", "release_id": release.id ?? ""])
        }
    }
    
    private func initHorizontalMenuView() {
        let releaseMenuOptionStrings = ReleaseMenuOption.allCases.map({return $0.description})
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
    
    private func handleUtileBarViewActions() {
        simpleNavigationBarView.didTapLeftButton = { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
        
        simpleNavigationBarView.setRightButtonIcon(UIImage(named: Ressources.Images.star))
        simpleNavigationBarView.didTapRightButton = { [unowned self] in
            self.toggleBookmarkIfApplicable()
        }
    }

    private func calculateAndApplyAlphaForReleaseTitleTypeAndSimpleNavBar() {
        // Calculate alpha base of distant between simpleNavBarView and the cell
        // the cell should only be dimmed only when the cell frame overlaps the utileBarView
        
        guard let releaseTitleLabel = releaseTitleAndTypeTableViewCell.titleLabel else {
            return
        }
        
        let releaseTitleLabelFrameInThisView = releaseTitleAndTypeTableViewCell.convert(releaseTitleLabel.frame, to: view)
        let distanceFromReleaseTitleLableToUtileBarView = releaseTitleLabelFrameInThisView.origin.y - (simpleNavigationBarView.frame.origin.y + simpleNavigationBarView.frame.size.height)
        
        // alpha = distance / label's height (dim base on label's frame)
        releaseTitleAndTypeTableViewCell.alpha = (distanceFromReleaseTitleLableToUtileBarView + releaseTitleLabel.frame.height) / releaseTitleLabel.frame.height
        simpleNavigationBarView.setAlphaForBackgroundAndTitleLabel(1 - releaseTitleAndTypeTableViewCell.alpha)
    }
    
    private func toggleBookmarkIfApplicable() {
        guard let release = release else { return }
        
        guard LoginService.isLoggedIn, let isBookmarked = release.isBookmarked else {
            displayLoginRequiredAlert()
            return
        }
        
        let action: BookmarkAction = isBookmarked ? .remove : .add
        
        MBProgressHUD.showAdded(to: view, animated: true)
        
        RequestHelper.Bookmark.bookmark(id: release.id, action: action, type: .releases) { [weak self] (isSuccessful) in
            guard let self = self else { return }
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if isSuccessful {
                self.release?.setIsBookmarked(!isBookmarked)
                self.updateBookmarkIconAndAddReminderOption()
                
                if isBookmarked {
                    Toast.displayMessageShortly("\"\(release.title ?? "")\" is removed from your bookmarks")
                    Analytics.logEvent("unbookmark_release", parameters: nil)
                } else {
                    Toast.displayMessageShortly("\"\(release.title ?? "")\" is added to your bookmarks")
                    Analytics.logEvent("bookmark_release", parameters: nil)
                }
                
            } else {
                Toast.displayMessageShortly(errorBookmarkMessage)
                Analytics.logEvent("bookmark_unbookmark_release_error", parameters: nil)
            }
        }
    }
    
    private func updateBookmarkIconAndAddReminderOption() {
        guard let release = release, let isBookmarked = release.isBookmarked else {
            simpleNavigationBarView.setRightButtonIcon(UIImage(named: Ressources.Images.star))
            return
        }
        
        let iconName = isBookmarked ? Ressources.Images.star_filled : Ressources.Images.star
        simpleNavigationBarView.setRightButtonIcon(UIImage(named: iconName))
        
        if let event = release.event, !addedReminderButton {
            addedReminderButton = true
            floaty.addItem("Create a reminder", icon: UIImage(named: Ressources.Images.calendar)) { [unowned self] _ in
                eventStore.requestAccess(to: EKEntityType.event) { [unowned self] (granted, error) in
                    DispatchQueue.main.async {
                        if let error = error {
                            Toast.displayMessageShortly(error.localizedDescription)
                        } else if granted {
                            let eventEditViewController = EKEventEditViewController()
                            eventEditViewController.event = event
                            eventEditViewController.eventStore = eventStore
                            eventEditViewController.editViewDelegate = self
                            self.present(eventEditViewController, animated: true, completion: nil)
                            Analytics.logEvent("create_reminder_from_release_page", parameters: nil)
                        } else {
                            self.alertNoCalendarAccess()
                        }
                    }
                }
            }
            floaty.items.swapAt(0, floaty.items.count - 1)
        }
    }
    
    private func addToCollection(type: MyCollection) {
        guard let release = release else { return }
        
        guard LoginService.isLoggedIn else {
            displayLoginRequiredAlert()
            return
        }
        MBProgressHUD.showAdded(to: view, animated: true)
        RequestHelper.Collection.add(releaseId: release.id, to: type) { [weak self] (isSuccessful) in
            guard let self = self else { return }
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if isSuccessful {
                Toast.displayMessageShortly("\"\(release.title ?? "")\" is added to your \(type.listDescription)")
                
                switch type {
                case .collection:
                    Analytics.logEvent("collection_add_success", parameters: nil)
                case .wanted:
                    Analytics.logEvent("wanted_list_add_success", parameters: nil)
                case .trade:
                    Analytics.logEvent("trade_list_add_success", parameters: nil)
                }
            } else {
                Toast.displayMessageShortly("Error adding release to \(type.listDescription). Please try again later.")
                
                switch type {
                case .collection:
                    Analytics.logEvent("collection_add_error", parameters: nil)
                case .wanted:
                    Analytics.logEvent("wanted_list_add_error", parameters: nil)
                case .trade:
                    Analytics.logEvent("trade_list_add_error", parameters: nil)
                }
            }
        }
    }
}

//MARK: - UIPopoverPresentationControllerDelegate
extension ReleaseDetailViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

// MARK: - UIScrollViewDelegate
extension ReleaseDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.panGestureRecognizer.translation(in: scrollView.superview).y < 0 {
            // scroll down
            UIView.animate(withDuration: 0.35) { [unowned self] in
                self.floaty.transform = CGAffineTransform(translationX: 0, y: 300)
            }
            
        } else {
            // scroll up
            UIView.animate(withDuration: 0.35) { [unowned self] in
                self.floaty.transform = .identity
            }
            
        }
    }
}

// MARK: - UITableViewDelegate
extension ReleaseDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard indexPath.section == 1 else { return }
        
        switch currentReleaseMenuOption {
        case .trackList: didSelectElementCell(atIndexPath: indexPath)
        case .lineup: didSelectMemberCell(atIndexPath: indexPath)
        case .reviews: didSelectReviewCell(atIndexPath: indexPath)
        case .otherVersions: didSelectOtherVersionCell(atIndexPath: indexPath)
        default: return
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 1
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
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let emptyView = UIView()
        emptyView.backgroundColor = Settings.currentTheme.backgroundColor
        return emptyView
    }
}

// MARK: - UITableViewDataSource
extension ReleaseDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let _ = release else { return 0 }
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let _ = release else { return 0 }
        if section == 0 {
            return 3
        }
        
        switch currentReleaseMenuOption {
        case .trackList: return numberOfRowsInTracklistSection()
        case .lineup: return numberOfRowsInLineupSection()
        case .reviews: return numberOfRowsInReviewsSection()
        case .otherVersions: return numberOfRowsInOtherVersionsSection()
        case .additionalNotes: return numberOfRowsInAdditionalNotesSection()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, 0): return releaseTitleTableViewCell(forRowAt: indexPath)
        case (0, 1): return releaseInfoTableViewCell(forRowAt: indexPath)
        case (0, 2): return horizontalMenuAnchorTableViewCell(forRowAt: indexPath)
        default:
            switch currentReleaseMenuOption {
            case .trackList: return releaseElementCell(forRowAt: indexPath)
            case .lineup: return memberCellFor(forRowAt: indexPath)
            case .reviews: return reviewCell(forRowAt: indexPath)
            case .otherVersions: return otherVersionCell(forRowAt: indexPath)
            case .additionalNotes: return additionalNotesCell(forRowAt: indexPath)
            }
        }
    }
}

// MARK: - Custom cells
extension ReleaseDetailViewController {
    private func releaseTitleTableViewCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let release = release else {
            return UITableViewCell()
        }
        
        let cell = ReleaseTitleAndTypeTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        releaseTitleAndTypeTableViewCell = cell
        cell.backgroundColor = .clear
        releaseTitleAndTypeTableViewCell = cell
        cell.fill(with: release)
        return cell
    }
    
    private func releaseInfoTableViewCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let release = release else {
            return UITableViewCell()
        }
        
        let cell = ReleaseInfoTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        releaseInfoTableViewCell = cell
        cell.fill(with: release)
        
        cell.tappedBandNameLabel = { [unowned self] in
            self.takeActionFor(actionableObject: release)
            
            Analytics.logEvent("view_release_band_list", parameters: ["release_title": release.title ?? "", "release_id": release.id ?? ""])
        }
        
        cell.tappedLastModifiedOnLabel = { [unowned self] in
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            
            Analytics.logEvent("view_release_last_modified_date", parameters: ["release_title": release.title ?? "", "release_id": release.id ?? ""])
        }
        cell.tappedLabelLabel = { [unowned self] in
            guard let labelUrlString = release.label.urlString else { return }
            self.pushLabelDetailViewController(urlString: labelUrlString, animated: true)
            
            Analytics.logEvent("view_release_label", parameters: ["release_title": release.title ?? "", "release_id": release.id ?? ""])
        }
        
        return cell
    }
    
    private func horizontalMenuAnchorTableViewCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = HorizontalMenuAnchorTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        horizontalMenuAnchorTableViewCell = cell
        horizontalMenuAnchorTableViewCell.contentView.heightAnchor.constraint(equalToConstant: horizontalMenuView.intrinsicHeight).isActive = true
        return cell
    }
}

// MARK: - HorizontalMenuViewDelegate
extension ReleaseDetailViewController: HorizontalMenuViewDelegate {
    func horizontalMenu(_ horizontalMenu: HorizontalMenuView, didSelectItemAt index: Int) {
        currentReleaseMenuOption = ReleaseMenuOption(rawValue: index) ?? .trackList
        pinHorizontalMenuViewThenRefreshAndScrollTableView()
        
        switch currentReleaseMenuOption {
        case .trackList: Analytics.logEvent("view_release_tracklist", parameters: ["release_title": release.title ?? "", "release_id": release.id ?? ""])
        case .lineup: Analytics.logEvent("view_release_lineup", parameters: ["release_title": release.title ?? "", "release_id": release.id ?? ""])
        case .reviews: Analytics.logEvent("view_release_reviews", parameters: ["release_title": release.title ?? "", "release_id": release.id ?? ""])
        case .otherVersions: Analytics.logEvent("view_release_other_versions", parameters: ["release_title": release.title ?? "", "release_id": release.id ?? ""])
        case .additionalNotes: Analytics.logEvent("view_release_additional_notes", parameters: ["release_title": release.title ?? "", "release_id": release.id ?? ""])
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

// MARK: - Tracklist
extension ReleaseDetailViewController {
    private func numberOfRowsInTracklistSection() -> Int {
        guard let release = release else { return 0 }
        return release.elements.count
    }
    
    private func releaseElementCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let release = release else {
            return UITableViewCell()
        }
        
        let cell = ReleaseElementTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let element = release.elements[indexPath.row]
        cell.fill(with: element)
        return cell
    }
    
    private func didSelectElementCell(atIndexPath indexPath: IndexPath) {
        guard let release = release else {
            return
        }
    
        let element = release.elements[indexPath.row]
        guard element.type == .song, let song = element as? Song else { return }
        
        if let lyricID = song.lyricID {
            ToastCenter.default.cancelAll()
            let lyricViewController = UIStoryboard(name: "Lyric", bundle: nil).instantiateViewController(withIdentifier: "LyricViewController") as! LyricViewController
            lyricViewController.lyricID = lyricID
            lyricViewController.title = song.title
            
            let navLyricViewController = UINavigationController(rootViewController: lyricViewController)
            navLyricViewController.modalPresentationStyle = .popover
            navLyricViewController.popoverPresentationController?.permittedArrowDirections = .any
            navLyricViewController.preferredContentSize = CGSize(width: screenWidth - 50, height: screenHeight * 2 / 3)
            
            navLyricViewController.popoverPresentationController?.delegate = self
            navLyricViewController.popoverPresentationController?.sourceView = self.tableView
            
            let rect = tableView.rectForRow(at: indexPath)
            navLyricViewController.popoverPresentationController?.sourceRect = rect
            
            present(navLyricViewController, animated: true, completion: nil)
            
            Analytics.logEvent("view_lyric", parameters: ["release_title": release.title ?? "", "release_id": release.id ?? "", "lyric_id": lyricID])
        } else if song.isInstrumental {
            ToastCenter.default.cancelAll()
            Toast(text: "This is an instrumental song", duration: Delay.short).show()
        } else {
            ToastCenter.default.cancelAll()
            Toast(text: "This song has no lyric", duration: Delay.short).show()
        }
    }
}

// MARK: - Lineup
extension ReleaseDetailViewController {
    private func numberOfRowsInLineupSection() -> Int {
        guard let release = release else { return 0 }
        
        if release.completeLineup.count == 0 {
            return 1
        }
        
        switch currentLineupType {
        case .complete:
            if release.completeLineup.count > 0 {
                return release.completeLineup.count + 1
            }
        case .member:
            if release.bandMembers.count > 0 {
                return release.bandMembers.count + 1
            }
        case .guest:
            if release.guestSession.count > 0 {
                return release.guestSession.count + 1
            }
        case .other:
            if release.otherStaff.count > 0 {
                return release.otherStaff.count + 1
            }
        }
        
        return 2
    }
    
    private func memberCellFor(forRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let release = release else {
            return UITableViewCell()
        }
        
        if release.completeLineup.count == 0 {
            let simpleCell = SimpleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            simpleCell.fill(with: "No artist added")
            return simpleCell
        }
        
        if indexPath.row == 0 {
            return lineupOptionCell(forRowAt: indexPath)
        }
        
        let cell = ReleaseMemberTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        
        var artist: ArtistLiteInRelease?
        switch currentLineupType {
        case .complete:
            if release.completeLineup.count > 0 {
                artist = release.completeLineup[indexPath.row - 1]
            }
        case .member:
            if release.bandMembers.count > 0 {
                artist = release.bandMembers[indexPath.row - 1]
            }
        case .guest:
            if release.guestSession.count > 0 {
                artist = release.guestSession[indexPath.row - 1]
            }
        case .other:
            if release.otherStaff.count > 0 {
                artist = release.otherStaff[indexPath.row - 1]
            }
        }
        
        if let artist = artist {
            cell.fill(with: artist)
            
            cell.tappedThumbnailImageView = { [unowned self] in
                self.presentPhotoViewerWithCacheChecking(photoUrlString: artist.imageURLString, description: artist.name, fromImageView: cell.thumbnailImageView)
                Analytics.logEvent("view_release_lineup_member", parameters: ["release_title": release.title ?? "", "release_id": release.id ?? "", "artist_id": artist.id, "artist_name": artist.name])
            }
            
            return cell
        }
        
        let simpleCell = SimpleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        simpleCell.fill(with: "No artist of this type")
        return simpleCell
    }
    
    private func lineupOptionCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = LineupOptionTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.tappedLineupOptionButton = { [unowned self] in
            let rect = cell.convert(cell.lineupOptionButton.frame, to: self.view)
            self.displayLineupOptionList(fromRect: rect)
        }
        
        var description: String?
        switch currentLineupType {
        case .complete: description = release.completeLineupDescription
        case .member: description = release.bandMembersDescription
        case .guest: description = release.guestSessionDescription
        case .other: description = release.otherStaffDescription
        }
        
        if let description = description {
            cell.lineupOptionButton.setTitle(" " + description + " ≡ ", for: .normal)
        }
        
        return cell
    }
    
    private func displayLineupOptionList(fromRect rect: CGRect) {
        guard let release = release else {
            return
        }
        
        let lineupOptionListViewController = UIStoryboard(name: "ReleaseDetail", bundle: nil).instantiateViewController(withIdentifier: "LineupOptionListViewController") as! LineupOptionListViewController
        lineupOptionListViewController.release = release
        lineupOptionListViewController.currentLineupType = currentLineupType
        
        lineupOptionListViewController.modalPresentationStyle = .popover
        lineupOptionListViewController.popoverPresentationController?.permittedArrowDirections = .any
        
        lineupOptionListViewController.popoverPresentationController?.delegate = self
        lineupOptionListViewController.popoverPresentationController?.sourceView = view
        
        lineupOptionListViewController.popoverPresentationController?.sourceRect = rect
        
        lineupOptionListViewController.selectedLineupType = { [unowned self] (lineupType) in
            self.currentLineupType = lineupType
            self.pinHorizontalMenuViewThenRefreshAndScrollTableView()
            
            Analytics.logEvent("change_release_lineup_type", parameters: ["release_title": release.title ?? "", "release_id": release.id ?? "", "lineup_type": lineupType.description])
        }
        
        present(lineupOptionListViewController, animated: true, completion: nil)
    }
    
    private func didSelectMemberCell(atIndexPath indexPath: IndexPath) {
        guard indexPath.row > 0 else { return }
        
        var artist: ArtistLiteInRelease?
        switch currentLineupType {
        case .complete: artist = release.completeLineup[indexPath.row - 1]
        case .member: artist = release.bandMembers[indexPath.row - 1]
        case .guest: artist = release.guestSession[indexPath.row - 1]
        case .other: artist = release.otherStaff[indexPath.row - 1]
        }
        
        if let artist = artist {
            pushArtistDetailViewController(urlString: artist.urlString, animated: true)
            
            Analytics.logEvent("select_release_member", parameters: ["release_title": release.title ?? "", "release_id": release.id ?? "", "artist_id": artist.id, "artist_name": artist.name])
        }
    }
}

// MARK: - Reviews
extension ReleaseDetailViewController {
    private func numberOfRowsInReviewsSection() -> Int {
        guard let release = release else { return 0 }
        
        if release.reviews.count == 0 {
            return 1
        }
        
        return release.reviews.count + 1
    }
    
    private func reviewCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let release = release else {
            return UITableViewCell()
        }
        
        if release.reviews.count == 0 {
            let simpleCell = SimpleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            simpleCell.fill(with: "No review yet")
            return simpleCell
        }
        
        if indexPath.row == 0 {
            return reviewOptionCell(forRowAt: indexPath)
        }
        
        let cell = ReleaseReviewTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        var index = 0
        
        if isAscendingOrderReview {
            index = release.reviews.count - indexPath.row
        } else {
            index = indexPath.row - 1
        }
        
        let review = release.reviews[index]
        cell.fill(with: review)
        return cell
    }
    
    private func reviewOptionCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let _ = release else {
            return UITableViewCell()
        }
        
        let cell = ReleaseReviewOptionTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.setOrderingTitle(isAscending: isAscendingOrderReview)
        cell.tappedOrderingButton = { [unowned self] in
            self.isAscendingOrderReview.toggle()
            cell.setOrderingTitle(isAscending: self.isAscendingOrderReview)
            self.tableView.reloadSections([1], with: .automatic)
            
            Analytics.logEvent("change_release_reviews_order", parameters: ["release_title": self.release.title ?? "", "release_id": self.release.id ?? "", "is_ascending": self.isAscendingOrderReview])
        }
        return cell
    }
    
    private func didSelectReviewCell(atIndexPath indexPath: IndexPath) {
        guard let release = release, release.reviews.count > 0, indexPath.row > 0 else { return }

        var index = 0
        
        if isAscendingOrderReview {
            index = release.reviews.count - indexPath.row
        } else {
            index = indexPath.row - 1
        }
        
        let review = release.reviews[index]
        presentReviewController(urlString: review.urlString, animated: true)
        
        Analytics.logEvent("select_release_review", parameters: ["release_title": release.title ?? "", "release_id": release.id ?? "", "review_url": review.urlString])
    }
}

// MARK: - Other versions
extension ReleaseDetailViewController {
    private func numberOfRowsInOtherVersionsSection() -> Int {
        guard let release = release else { return 0 }
        return max(release.otherVersions.count, 1)
    }
    
    private func otherVersionCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let release = release else {
            return UITableViewCell()
        }
        
        if release.otherVersions.count == 0 {
            let simpleCell = SimpleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            simpleCell.fill(with: "No other version")
            return simpleCell
        }
        
        let cell = ReleaseOtherVersionTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let otherVersion = release.otherVersions[indexPath.row]
        cell.fill(with: otherVersion)
        
        if indexPath.row == 0 {
            cell.markAsThisVersion()
        }
        
        return cell
    }
    
    private func didSelectOtherVersionCell(atIndexPath indexPath: IndexPath) {
        guard let release = release, release.otherVersions.count > 0 else { return }
        
        if indexPath.row == 0 {
            Toast.displayMessageShortly("This version")
            return
        }
        
        let otherVersion = release.otherVersions[indexPath.row]
        pushReleaseDetailViewController(urlString: otherVersion.urlString, animated: true)
        
        Analytics.logEvent("select_release_other_version", parameters: ["release_title": release.title ?? "", "release_id": release.id ?? "", "other_version_url": otherVersion.urlString])
    }
}

// MARK: - Additional Notes
extension ReleaseDetailViewController {
    private func numberOfRowsInAdditionalNotesSection() -> Int {
        guard let _ = release else { return 0 }
        return 1
    }
    
    private func additionalNotesCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let release = release else {
            return UITableViewCell()
        }
        let simpleCell = SimpleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        if let additionalNotes = release.additionalHTMLNotes?.htmlToString {
            simpleCell.fill(with: additionalNotes)
        } else {
            simpleCell.fill(with: "No additional notes")
        }
        
        return simpleCell
    }
}
