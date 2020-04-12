//
//  BandDetailViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import SDWebImage
import Toaster
import FirebaseAnalytics
import Crashlytics
import Floaty
import MBProgressHUD

final class BandDetailViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var stretchyLogoSmokedImageView: SmokedImageView!
    @IBOutlet private weak var stretchyLogoSmokedImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var simpleNavigationBarView: SimpleNavigationBarView!
    @IBOutlet private weak var floaty: Floaty!
    
    var bandURLString: String!
    private var bandPhotoAndNameTableViewCell = BandPhotoAndNameTableViewCell()
    private var tableViewContentOffsetObserver: NSKeyValueObservation?
    
    private var band: Band?
    private var currentMenuOption: BandMenuOption = .discography
    
    // Discography
    private var currentDiscographyType: DiscographyType = UserDefaults.selectedDiscographyType()
    private var isAscendingOrderDiscography = true
    
    // Members
    private var currentMemberType: MembersType = .complete
    
    private var bandInfoTableViewCell = BandInfoTableViewCell()
    
    // Floating menu
    private var horizontalMenuView: HorizontalMenuView!
    private var horizontalMenuViewTopConstraint: NSLayoutConstraint!
    private var horizontalMenuAnchorTableViewCell: HorizontalMenuAnchorTableViewCell! {
        didSet {
            anchorHorizontalMenuViewToAnchorTableViewCell()
        }
    }
    private var yOffsetNeededToPinHorizontalViewToUtileBarView: CGFloat {
        let yOffset = bandPhotoAndNameTableViewCell.bounds.height + bandInfoTableViewCell.bounds.height - simpleNavigationBarView.bounds.height
        return yOffset
    }
    
    private var anchorHorizontalMenuToMenuAnchorTableViewCell = true
    
    var historyRecordableDelegate: HistoryRecordable?
    
    private var adjustedTableViewContentOffset = false
    
    deinit {
        print("BandDetailViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stretchyLogoSmokedImageViewHeightConstraint.constant = Settings.strechyLogoImageViewHeight
        configureTableView()
        initFloaty()
        initHorizontalMenuView()
        handleSimpleNavigationBarViewActions()
        fetchBand()
        navigationController?.interactivePopGestureRecognizer?.delegate = navigationController as? HomepageNavigationController
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
        stretchyLogoSmokedImageView.transform = .identity
    }

    private func fetchBand() {
        floaty.isHidden = true
        showHUD(hideNavigationBar: true)
        
        MetalArchivesAPI.reloadBand(bandURLString: bandURLString) { [weak self] (band, error) in
            
            guard let self = self else { return }
            
            if let _ = error {
                self.showHUD()
                DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                    self.fetchBand()
                })
            } else {
                self.hideHUD()
                guard let band = band else {
                    Toast.displayMessageShortly(errorLoadingMessage)
                    self.navigationController?.popViewController(animated: true)
                    return
                }
                
                self.floaty.isHidden = false
                self.band = band
                
                if band.discography?.main.count == 0 {
                    self.currentDiscographyType = .complete
                }
                
                if let logoURLString = band.logoURLString, let logoURL = URL(string: logoURLString) {
                    self.stretchyLogoSmokedImageView.imageView.sd_setImage(with: logoURL, placeholderImage: nil, options: [.retryFailed], completed: { [weak self] (image, error, cacheType, url) in
                        self?.simpleNavigationBarView.setImageAsTitle(image, fallbackTitle: band.name, alwaysShowTitle: false)
                    })
                } else {
                    self.tableView.contentInset = .init(top: self.simpleNavigationBarView.frame.origin.y + self.simpleNavigationBarView.frame.height + 10, left: 0, bottom: UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0, right: 0)
                    self.simpleNavigationBarView.setTitle(band.name)
                }

                self.currentMemberType = band.isLastKnown ? .lastKnown : .current
                
                self.updateBookmarkIcon()
                self.tableView.reloadData()
                
                // Delay this method to wait for info cells to be fully loaded
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    self.setTableViewBottomInsetToFillBottomSpace()
                })
                
                self.historyRecordableDelegate?.loaded(urlString: band.urlString, nameOrTitle: band.name, thumbnailUrlString: band.logoURLString, objectType: .band)
                
                Analytics.logEvent("view_band", parameters: ["band_id": band.id ?? "", "band_name": band.name ?? ""])
                Crashlytics.sharedInstance().setObjectValue(self.band?.generalDescription, forKey: "band")
            }
        }
    }
    
    private func initFloaty() {
        floaty.customizeAppearance()
        
        floaty.addItem("Deezer this band", icon: UIImage(named: Ressources.Images.deezer)) { [unowned self] _ in
            self.pushDeezerResultViewController(type: .artist, term: self.band?.name ?? "")
        }
        
        floaty.addItem("Share this band", icon: UIImage(named: Ressources.Images.share)) { [unowned self] _ in
            guard let band = self.band, let url = URL(string: band.urlString) else { return }
            
            self.presentAlertOpenURLInBrowsers(url, alertTitle: "View \(band.name ?? "") in browser", alertMessage: band.urlString, shareMessage: "Share this band URL")
            
            Analytics.logEvent("share_band", parameters: ["band_id": band.id ?? "", "band_name": band.name ?? ""])
        }
    }
    
    private func initHorizontalMenuView() {
        let bandMenuOptionStrings = BandMenuOption.allCases.map({return $0.description})
        horizontalMenuView = HorizontalMenuView(options: bandMenuOptionStrings, font: Settings.currentFontSize.secondaryTitleFont, normalColor: Settings.currentTheme.bodyTextColor, highlightColor: Settings.currentTheme.secondaryTitleColor)
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
    
    private func handleSimpleNavigationBarViewActions() {
        simpleNavigationBarView.didTapLeftButton = { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
        
        simpleNavigationBarView.setRightButtonIcon(UIImage(named: Ressources.Images.star))
        simpleNavigationBarView.didTapRightButton = { [unowned self] in
            self.toggleBookmarkIfApplicable()
        }
    }

    private func calculateAndApplyAlphaForBandPhotoAndNameCellAndSimpleNavBar() {
        // Calculate alpha base of distant between simpleNavBarView and the cell
        // the cell should only be dimmed only when the cell frame overlaps the utileBarView
        
        guard let bandNameLabel = bandPhotoAndNameTableViewCell.nameLabel else {
            return
        }
        
        let bandNameLabelFrameInThisView = bandPhotoAndNameTableViewCell.convert(bandNameLabel.frame, to: view)
        let distanceFromBandNameLableToUtileBarView = bandNameLabelFrameInThisView.origin.y - (simpleNavigationBarView.frame.origin.y + simpleNavigationBarView.frame.size.height)
        
        // alpha = distance / label's height (dim base on label's frame)
        bandPhotoAndNameTableViewCell.alpha = (distanceFromBandNameLableToUtileBarView + bandNameLabel.frame.height) / bandNameLabel.frame.height
        simpleNavigationBarView.setAlphaForBackgroundAndTitleLabel(1 - bandPhotoAndNameTableViewCell.alpha)
    }
    
    private func presentBandLogoInPhotoViewer() {
        guard let band = band, let bandLogoURLString = band.logoURLString else { return }
        presentPhotoViewer(photoUrlString: bandLogoURLString, description: band.name, fromImageView: stretchyLogoSmokedImageView.imageView)
    }
    
    private func presentOldBands() {
        guard let oldBands = band?.oldBands else { return }
        
        Analytics.logEvent("view_band_old_names", parameters: ["band_id": band?.id ?? "", "band_name": band?.name ?? ""])
        
        if oldBands.count == 1 {
            let oldBand = oldBands[0]
            pushBandDetailViewController(urlString: oldBand.urlString, animated: true)
            
        } else {
            var alertController: UIAlertController!
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                alertController = UIAlertController(title: "View \(band!.name!)'s old bands", message: nil, preferredStyle: .alert)
            } else {
                alertController = UIAlertController(title: "View \(band!.name!)'s old bands", message: nil, preferredStyle: .actionSheet)
            }
            
            for eachOldBand in oldBands {
                let bandAction = UIAlertAction(title: eachOldBand.name, style: .default, handler: { [unowned self] (action) in
                    self.pushBandDetailViewController(urlString: eachOldBand.urlString, animated: true)
                })
                alertController.addAction(bandAction)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    private func toggleBookmarkIfApplicable() {
        guard let band = band else { return }
        
        guard LoginService.isLoggedIn, let isBookmarked = band.isBookmarked else {
            displayLoginRequiredAlert()
            return
        }
        
        let action: BookmarkAction = isBookmarked ? .remove : .add
        
        MBProgressHUD.showAdded(to: view, animated: true)
        
        RequestHelper.Bookmark.bookmark(id: band.id, action: action, type: .bands) { [weak self] (isSuccessful) in
            guard let self = self else { return }
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if isSuccessful {
                self.band?.setIsBookmarked(!isBookmarked)
                self.updateBookmarkIcon()
                
                if isBookmarked {
                    Toast.displayMessageShortly("\"\(band.name ?? "")\" is removed from your bookmarks")
                    Analytics.logEvent("unbookmark_band", parameters: nil)
                } else {
                    Toast.displayMessageShortly("\"\(band.name ?? "")\" is added to your bookmarks")
                    Analytics.logEvent("bookmark_band", parameters: nil)
                }
                
            } else {
                Toast.displayMessageShortly(errorBookmarkMessage)
                Analytics.logEvent("bookmark_unbookmark_band_error", parameters: nil)
            }
        }
    }
    
    private func updateBookmarkIcon() {
        guard let band = band, let isBookmarked = band.isBookmarked else {
            simpleNavigationBarView.setRightButtonIcon(UIImage(named: Ressources.Images.star))
            return
        }
        
        let iconName = isBookmarked ? Ressources.Images.star_filled : Ressources.Images.star
        simpleNavigationBarView.setRightButtonIcon(UIImage(named: iconName))
    }
}

// MARK: - UIScrollViewDelegate
extension BandDetailViewController: UIScrollViewDelegate {
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

// MARK: - UI Configurations
extension BandDetailViewController {
    private func configureTableView() {
        SimpleTableViewCell.register(with: tableView)
        LoadingTableViewCell.register(with: tableView)
        BandPhotoAndNameTableViewCell.register(with: tableView)
        BandInfoTableViewCell.register(with: tableView)
        HorizontalMenuAnchorTableViewCell.register(with: tableView)
        DiscographyOptionsTableViewCell.register(with: tableView)
        ReleaseTableViewCell.register(with: tableView)
        MemberOptionTableViewCell.register(with: tableView)
        MemberTableViewCell.register(with: tableView)
        ReviewTableViewCell.register(with: tableView)
        SimilarBandTableViewCell.register(with: tableView)
        RelatedLinkTableViewCell.register(with: tableView)
        
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.contentInset = .init(top: Settings.strechyLogoImageViewHeight - Settings.bandPhotoImageViewHeight / 2, left: 0, bottom: UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0, right: 0)
        
        // observe when tableView is scrolled to animate alphas because scrollViewDidScroll doesn't capture enough event.
        tableViewContentOffsetObserver = tableView.observe(\UITableView.contentOffset, options: [.new]) { [weak self] (tableView, _) in
            self?.calculateAndApplyAlphaForBandPhotoAndNameCellAndSimpleNavBar()
            self?.stretchyLogoSmokedImageView.calculateAndApplyAlpha(withTableView: tableView)
            self?.anchorHorizontalMenuViewToAnchorTableViewCell()
        }
        
        // detect taps on band's logo, have to do this because band's logo is overlaid by tableView
        tableView.backgroundView = UIView()
        let backgroundViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tableViewBackgroundViewTapped))
        tableView.backgroundView?.addGestureRecognizer(backgroundViewTapGestureRecognizer)
    }
    
    @objc private func tableViewBackgroundViewTapped() {
        presentBandLogoInPhotoViewer()
        Analytics.logEvent("view_band_logo", parameters: ["band_id": band?.id ?? "", "band_name": band?.name ?? ""])
    }
}

// MARK: - UITableViewDelegate
extension BandDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                presentBandLogoInPhotoViewer()
            }
            return
        }
        
        switch currentMenuOption {
        case .discography: didSelectDiscographyCell(atIndexPath: indexPath)
        case .members: didSelectMemberCell(atIndexPath: indexPath)
        case .reviews: didSelectReviewCell(atIndexPath: indexPath)
        case .similarArtists: didSelectSimilarArtistCell(atIndexPath: indexPath)
        case .relatedLinks: didSelectRelatedLinkCell(atIndexPath: indexPath)
        default: return
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        case (0, 0): return bandPhotoAndNameTableViewCell.bounds.height
        case (0, 1): return bandInfoTableViewCell.bounds.height
        case (0, 2):
            if let bandMenuAnchorTableViewCell = horizontalMenuAnchorTableViewCell {
                return bandMenuAnchorTableViewCell.bounds.height
            }
        default:
            return UITableView.automaticDimension
        }
        
         return UITableView.automaticDimension
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 1
        }
        
        return Settings.spaceBetweenInfoAndDetailSection
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
}

// MARK: - UITableViewDataSource
extension BandDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let _ = self.band else { return 0 }
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let _ = self.band else { return 0 }
        
        if section == 0 {
            // 3 rows:
            // - Band's photo & name
            // - Band's basic infos
            // - Band's menu options
            return 3
        }
        
        switch currentMenuOption {
        case .discography: return numberOfRowsInDiscographySection()
        case .members: return numberOfRowsInMemberSection()
        case .reviews: return numberOfRowsInReviewSection()
        case .similarArtists: return numberOfRowsInSimilarArtistSection()
        case .about: return numberOfRowsInAboutSection()
        case .relatedLinks: return numberOfRowssInRelatedLinkSection()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, 0): return bandPhotoAndNameTableViewCell(forRowAt: indexPath)
        case (0, 1): return bandInfoTableViewCell(forRowAt: indexPath)
        case (0, 2): return horizontalMenuAnchorTableViewCell(forRowAt: indexPath)
        default:
            switch currentMenuOption {
            case .discography: return discographyCell(forRowAt: indexPath)
            case .members: return memberCell(forRowAt: indexPath)
            case .reviews: return reviewCell(forRowAt: indexPath)
            case .similarArtists: return similarArtistCell(forRowAt: indexPath)
            case .about: return aboutCell(forRowAt: indexPath)
            case .relatedLinks: return relatedLinkCell(forRowAt: indexPath)
            }
        }
    }
}

// MARK: - Custom cells
extension BandDetailViewController {
    private func bandPhotoAndNameTableViewCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = BandPhotoAndNameTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        bandPhotoAndNameTableViewCell = cell
        cell.fill(with: band!)
        cell.tappedPhotoImageView = { [unowned self] in
            if let band = self.band, let bandPhotoURLString = band.photoURLString {
                self.presentPhotoViewer(photoUrlString: bandPhotoURLString, description: band.name, fromImageView: cell.photoImageView)
                Analytics.logEvent("view_band_photo", parameters: ["band_id": band.id ?? "", "band_name": band.name ?? ""])
            } else {
                Toast.displayMessageShortly("No photo added")
            }
        }
        
        return cell
    }
    
    private func bandInfoTableViewCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = BandInfoTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        bandInfoTableViewCell = cell
        cell.fill(with: band!)
        
        cell.tappedYearsActiveLabel = { [unowned self] in
            self.presentOldBands()
        }
        cell.tappedLastModifiedOnLabel = { [unowned self] in
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            Analytics.logEvent("view_band_last_modified_date", parameters: ["band_id": self.band?.id ?? "", "band_name": self.band?.name ?? ""])
        }
        cell.tappedLastLabelLabel = { [unowned self] in
            guard let lastLabelUrlString = self.band?.lastLabel.urlString else { return }
            self.pushLabelDetailViewController(urlString: lastLabelUrlString, animated: true)
            Analytics.logEvent("view_band_last_label", parameters: ["band_id": self.band?.id ?? "", "band_name": self.band?.name ?? ""])
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
extension BandDetailViewController: HorizontalMenuViewDelegate {
    func horizontalMenu(_ horizontalMenu: HorizontalMenuView, didSelectItemAt index: Int) {
        currentMenuOption = BandMenuOption(rawValue: index) ?? .discography
        pinHorizontalMenuViewThenRefreshAndScrollTableView()
        
        switch currentMenuOption {
        case .discography: Analytics.logEvent("view_band_discography", parameters: ["band_id": band?.id ?? "", "band_name": band?.name ?? ""])
        case .members: Analytics.logEvent("view_band_members", parameters: ["band_id": band?.id ?? "", "band_name": band?.name ?? ""])
        case .reviews: Analytics.logEvent("view_band_reviews", parameters: ["band_id": band?.id ?? "", "band_name": band?.name ?? ""])
        case .similarArtists: Analytics.logEvent("view_band_similar_artists", parameters: nil)
        case .about: Analytics.logEvent("view_band_about", parameters: ["band_id": band?.id ?? "", "band_name": band?.name ?? ""])
        case .relatedLinks: Analytics.logEvent("view_band_related_links", parameters: ["band_id": band?.id ?? "", "band_name": band?.name ?? ""])
        }
    }
    
    private func pinHorizontalMenuViewThenRefreshAndScrollTableView() {
        anchorHorizontalMenuToMenuAnchorTableViewCell = false
        horizontalMenuViewTopConstraint.constant = simpleNavigationBarView.frame.origin.y + simpleNavigationBarView.frame.height
        tableView.reloadSections([1], with: .none)
        tableView.scrollToRow(at: IndexPath(row: 2, section: 0), at: .top, animated: false)
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

// MARK: - UIPopoverPresentationControllerDelegate
extension BandDetailViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

// MARK: - Discography
extension BandDetailViewController {
    private func numberOfRowsInDiscographySection() -> Int {
        guard let band = band else { return 0 }
        
        guard let discography = band.discography else { return 1 }
        
        // return at least 2 rows: 1 for the options, 1 for displaying message
        switch currentDiscographyType {
        case .complete: return max(discography.complete.count + 1, 2)
        case .main: return max(discography.main.count + 1, 2)
        case .lives: return max(discography.lives.count + 1, 2)
        case .demos: return max(discography.demos.count + 1, 2)
        case .misc: return max(discography.misc.count + 1, 2)
        }
    }
    
    private func discographyCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let band = band else {
            return UITableViewCell()
        }
        
        guard let _ = band.discography else {
            let simpleCell = SimpleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            simpleCell.fill(with: "This band has no release yet")
            return simpleCell
        }
        
        if indexPath.row == 0 {
            return discographyOptionsTableViewCell(atIndexPath: indexPath)
        }
        
        if let release = release(forIndexPath: indexPath) {
            let cell = ReleaseTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            cell.fill(with: release)
            
            cell.tappedThumbnailImageView = { [unowned self] in
                self.presentPhotoViewerWithCacheChecking(photoUrlString: release.imageURLString, description: release.title, fromImageView: cell.thumbnailImageView)
                Analytics.logEvent("view_band_release_thumbnail", parameters: ["band_id": self.band?.id ?? "", "band_name": self.band?.name ?? "", "release_id": release.id, "release_title": release.title])
            }
            
            return cell
        }

        let simpleCell = SimpleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        simpleCell.displayAsBodyText()
        simpleCell.fill(with: "No release for \"\(currentDiscographyType.description)\"")
        return simpleCell
    }
    
    private func didSelectDiscographyCell(atIndexPath indexPath: IndexPath) {
        guard indexPath.row != 0 else { return }
        
        if let release = release(forIndexPath: indexPath) {
            pushReleaseDetailViewController(urlString: release.urlString, animated: true)
            
            Analytics.logEvent("select_band_release", parameters: ["band_id": band?.id ?? "", "band_name": band?.name ?? "", "release_id": release.id, "release_title": release.title])
        }
    }
    
    private func release(forIndexPath indexPath: IndexPath) -> ReleaseLite? {
        guard let band = band, let discography = band.discography else {
            return nil
        }
        
        var release: ReleaseLite?
        var index = 0
        
        if isAscendingOrderDiscography {
            index = indexPath.row - 1
        } else {
            switch currentDiscographyType {
            case .complete: index = discography.complete.count - indexPath.row
            case .main: index = discography.main.count - indexPath.row
            case .lives: index = discography.lives.count - indexPath.row
            case .demos: index = discography.demos.count - indexPath.row
            case .misc: index = discography.misc.count - indexPath.row
            }
        }
        
        guard index >= 0 else { return nil }
        
        switch currentDiscographyType {
        case .complete:
            if discography.complete.count > index {
                release = discography.complete[index]
            }
        case .main:
            if discography.main.count > index {
                release = discography.main[index]
            }
        case .lives:
            if discography.lives.count > index {
                release = discography.lives[index]
            }
        case .demos:
            if discography.demos.count > index {
                release = discography.demos[index]
            }
        case .misc:
            if discography.misc.count > index {
                release = discography.misc[index]
            }
        }
        
        return release
    }
    
    private func discographyOptionsTableViewCell(atIndexPath indexPath: IndexPath) -> UITableViewCell {
        guard let band = band, let discography = band.discography else {
            return UITableViewCell()
        }
        
        let cell = DiscographyOptionsTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        
        var description = ""
        switch currentDiscographyType {
        case .complete: description = discography.completeDescription
        case .main: description = discography.mainDescription
        case .lives: description = discography.livesDescription
        case .demos: description = discography.demosDescription
        case .misc: description = discography.miscDescription
        }
        
        cell.discographyTypeButton.setTitle(" " + description + " ≡ ", for: .normal)
        cell.setOrderingTitle(isAscending: isAscendingOrderDiscography)
        
        cell.tappedDiscographyTypeButton = { [unowned self] in
            let rect = cell.convert(cell.discographyTypeButton.frame, to: self.view)
            self.displayDiscographyOptionList(fromRect: rect)
        }
        
        cell.tappedOrderingButton = { [unowned self] in
            self.isAscendingOrderDiscography.toggle()
            cell.setOrderingTitle(isAscending: self.isAscendingOrderDiscography)
            self.tableView.reloadSections([1], with: .automatic)
            Analytics.logEvent("change_band_discography_order", parameters: ["band_id": self.band?.id ?? "", "band_name": self.band?.name ?? "", "is_ascending": self.isAscendingOrderDiscography])
        }
        
        return cell
    }
    
    private func displayDiscographyOptionList(fromRect rect: CGRect) {
        guard let band = band, let discography = band.discography else {
            return
        }
        
        let discographyOptionListViewController = UIStoryboard(name: "BandDetail", bundle: nil).instantiateViewController(withIdentifier: "DiscographyOptionListViewController") as! DiscographyOptionListViewController
        discographyOptionListViewController.discography = discography
        discographyOptionListViewController.currentDiscographyType = currentDiscographyType
        
        discographyOptionListViewController.modalPresentationStyle = .popover
        discographyOptionListViewController.popoverPresentationController?.permittedArrowDirections = .any
        
        discographyOptionListViewController.popoverPresentationController?.delegate = self
        discographyOptionListViewController.popoverPresentationController?.sourceView = view
    
        discographyOptionListViewController.popoverPresentationController?.sourceRect = rect
        
        discographyOptionListViewController.selectedDiscographyType = { [unowned self] (discographyType) in
            self.currentDiscographyType = discographyType
            self.pinHorizontalMenuViewThenRefreshAndScrollTableView()
            Analytics.logEvent("change_band_discography_type", parameters: ["band_id": self.band?.id ?? "", "band_name": self.band?.name ?? "", "discography_type": discographyType.description])
        }
        
        self.present(discographyOptionListViewController, animated: true, completion: nil)
    }
}

// MARK: - Members
extension BandDetailViewController {
    private func numberOfRowsInMemberSection() -> Int {
        guard let band = band else { return 0 }
        
        if band.hasNoMember {
            return 1
        }
        
        switch currentMemberType {
        case .complete:
            if let complete = band.completeLineup {
                return complete.count + 1
            }
        case .lastKnown:
            if let lastKnown = band.lastKnownLineup {
                return lastKnown.count + 1
            }
        case .current:
            if let current = band.currentLineup {
                return current.count + 1
            }
        case .past:
            if let past = band.pastMembers {
                return past.count + 1
            }
        case .live:
            if let live = band.liveMusicians {
                return live.count + 1
            }
        }
        
        return 2
    }
    
    private func didSelectMemberCell(atIndexPath indexPath: IndexPath) {
        guard let artist = artist(forRowAt: indexPath) else { return }
        takeActionFor(actionableObject: artist)
        Analytics.logEvent("select_band_member", parameters: ["band_id": band?.id ?? "", "band_name": band?.name ?? "", "artist_id": artist.id, "artist_name": artist.name])
    }
    
    private func memberCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let band = band else {
            return UITableViewCell()
        }
        
        if band.hasNoMember {
            let simpleCell = SimpleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            simpleCell.fill(with: "No artist added")
            return simpleCell
        }
        
        if indexPath.row == 0 {
            return memberOptionTableViewCell(forRowAt: indexPath)
        }
        
        if let artist = artist(forRowAt: indexPath) {
            let cell = MemberTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            cell.fill(with: artist)
            
            cell.tappedThumbnailImageView = { [unowned self] in
                self.presentPhotoViewerWithCacheChecking(photoUrlString: artist.imageURLString, description: artist.name, fromImageView: cell.thumbnailImageView)
                Analytics.logEvent("view_band_member_thumbnail", parameters: ["band_id": self.band?.id ?? "", "band_name": self.band?.name ?? "", "artist_id": artist.id, "artist_name": artist.name])
            }
            
            return cell
        }
        
        let simpleCell = SimpleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        simpleCell.fill(with: "No artist for \"\(currentMemberType.description)\"")
        return simpleCell
    }
    
    private func artist(forRowAt indexPath: IndexPath) -> ArtistLite? {
        guard let band = band else { return nil }
        
        var artist: ArtistLite?
        let index = indexPath.row - 1
        
        switch currentMemberType {
        case .complete:
            if let complete = band.completeLineup, complete.indices.contains(index) {
                artist = complete[index]
            }
            
        case .current:
            if let current = band.currentLineup, current.indices.contains(index) {
                artist = current[index]
            }
        case .lastKnown:
            if let lastKnown = band.lastKnownLineup, lastKnown.indices.contains(index) {
                artist = lastKnown[index]
            }
        case .past:
            if let past = band.pastMembers, past.indices.contains(index) {
                artist = past[index]
            }
        case .live:
            if let live = band.liveMusicians, live.indices.contains(index) {
                artist = live[index]
            }
        }
        
        return artist
    }
    
    private func memberOptionTableViewCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MemberOptionTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        
        guard let band = band else {
            return cell
        }
        
        var description = ""
        switch currentMemberType {
        case .complete: description = band.completeLineupDescription
        case .lastKnown: description = band.lastKnownLineupDescription
        case .current: description = band.currentLineupDescription
        case .past: description = band.pastMembersDescription
        case .live: description = band.liveMusiciansDescription
        }
        
        cell.memberTypeButton.setTitle(" " + description + " ≡ ", for: .normal)
        
        cell.tappedMemberTypeButton = { [unowned self] in
            let rect = cell.convert(cell.memberTypeButton.frame, to: self.view)
            self.displayMemberTypeList(fromRect: rect)
        }

        return cell
    }
    
    private func displayMemberTypeList(fromRect rect: CGRect) {
        guard let band = band else {
            return
        }
        
        let memberTypeListViewController = UIStoryboard(name: "BandDetail", bundle: nil).instantiateViewController(withIdentifier: "MemberTypeListViewController") as! MemberTypeListViewController
        memberTypeListViewController.band = band
        memberTypeListViewController.currentMemberType = currentMemberType
        
        memberTypeListViewController.modalPresentationStyle = .popover
        memberTypeListViewController.popoverPresentationController?.permittedArrowDirections = .any
        
        memberTypeListViewController.popoverPresentationController?.delegate = self
        memberTypeListViewController.popoverPresentationController?.sourceView = view
        
        memberTypeListViewController.popoverPresentationController?.sourceRect = rect
        
        memberTypeListViewController.selectedMemberType = { [unowned self] (currentMemberType) in
            self.currentMemberType = currentMemberType
            self.pinHorizontalMenuViewThenRefreshAndScrollTableView()
            
            Analytics.logEvent("change_band_lineup_type", parameters: ["band_id": band.id ?? "", "band_name": band.name ?? "", "lineup_type": currentMemberType.description])
        }
        
        self.present(memberTypeListViewController, animated: true, completion: nil)
    }
}

// MARK: - Reviews
extension BandDetailViewController {
    private func numberOfRowsInReviewSection() -> Int {
        guard let band = band else { return 0 }
        
        guard let _ = band.reviewLitePagableManager.totalRecords else {
            return 1
        }
        
        if band.reviewLitePagableManager.moreToLoad {
            return band.reviewLitePagableManager.objects.count + 1
        }
        return band.reviewLitePagableManager.objects.count
    }
    
    private func reviewCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let band = band else {
            return UITableViewCell()
        }
        
        guard let _ = band.reviewLitePagableManager.totalRecords else {
            let simpleCell = SimpleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            simpleCell.fill(with: "No review yet")
            return simpleCell
        }
        
        if indexPath.row == band.reviewLitePagableManager.objects.count && band.reviewLitePagableManager.moreToLoad {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            band.reviewLitePagableManager.fetch { [weak self] (error) in
                if let _ = error { return }
                DispatchQueue.main.async {
                    self?.band?.associateReleasesToReviews()
                    self?.tableView.reloadSections([1], with: .automatic)
                }
            }
            return loadingCell
        }
        
        let cell = ReviewTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let review = band.reviewLitePagableManager.objects[indexPath.row]
        cell.fill(with: review)
        
        cell.tappedThumbnailImageView = { [unowned self] in
            self.presentPhotoViewerWithCacheChecking(photoUrlString: review.release?.imageURLString, description: review.release?.title ?? "", fromImageView: cell.thumbnailImageView)
            Analytics.logEvent("view_band_review_thumbnail", parameters: ["band_id": self.band?.id ?? "", "band_name": self.band?.name ?? "", "release_id": review.release?.id ?? "", "release_title": review.release?.title ?? "", "review_url": review.urlString])
        }
        
        return cell
    }
    
    private func didSelectReviewCell(atIndexPath indexPath: IndexPath) {
        guard let band = band else { return }
        
        // tapped loading cell => return
        if indexPath.row == band.reviewLitePagableManager.objects.count && band.reviewLitePagableManager.moreToLoad {
            return
        }
        
        let review = band.reviewLitePagableManager.objects[indexPath.row]
        takeActionFor(actionableObject: review)
        Analytics.logEvent("select_band_review", parameters: ["band_id": band.id ?? "", "band_name": band.name ?? "", "review_url": review.urlString])
    }
}

// MARK: - Similar Artists
extension BandDetailViewController {
    private func numberOfRowsInSimilarArtistSection() -> Int {
        guard let band = band else { return 0 }
        
        guard let similarArtists = band.similarArtists else {
            return 1
        }
        
        return similarArtists.count
    }
    
    private func similarArtistCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let band = band else {
            return UITableViewCell()
        }
        
        guard let similarArtists = band.similarArtists else {
            let simpleCell = SimpleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            simpleCell.fill(with: "No similar band")
            return simpleCell
        }
        
        let cell = SimilarBandTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let similarArtist = similarArtists[indexPath.row]
        cell.fill(with: similarArtist)
        
        cell.tappedThumbnailImageView = { [unowned self] in
            self.presentPhotoViewerWithCacheChecking(photoUrlString: similarArtist.imageURLString, description: similarArtist.name, fromImageView: cell.thumbnailImageView)
            Analytics.logEvent("view_band_similar_artist_thumbnail", parameters: ["band_id": self.band?.id ?? "", "band_name": self.band?.name ?? "", "artist_id": similarArtist.id, "artist_name": similarArtist.name])
        }
        
        return cell
    }
    
    private func didSelectSimilarArtistCell(atIndexPath indexPath: IndexPath) {
        guard let band = band, let similarArtists = band.similarArtists else { return }
        
        pushBandDetailViewController(urlString: similarArtists[indexPath.row].urlString, animated: true)
        
        Analytics.logEvent("select_band_similar_artist", parameters: ["band_id": band.id ?? "", "band_name": band.name ?? "", "similar_artist_id": similarArtists[indexPath.row].id, "similar_artist_name": similarArtists[indexPath.row].name])
    }
}

// MARK: - About
extension BandDetailViewController {
    private func numberOfRowsInAboutSection() -> Int {
        guard let _ = band else { return 0 }
        return 1
    }
    
    private func aboutCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let band = band else {
            return UITableViewCell()
        }
        
        let simpleCell = SimpleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        
        if let about = band.completeHTMLDescription {
            simpleCell.fill(with: about)
        } else {
            simpleCell.fill(with: "No information added")
        }
        
        return simpleCell
    }
}

// MARK: - Related Links
extension BandDetailViewController {
    private func numberOfRowssInRelatedLinkSection() -> Int {
        guard let band = band else { return 0 }
        guard let relatedLinks = band.relatedLinks else { return 1 }
        return relatedLinks.count
    }
    
    private func relatedLinkCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let band = band else {
            return UITableViewCell()
        }
        
        guard let relatedLinks = band.relatedLinks else {
            let simpleCell = SimpleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            simpleCell.fill(with: "No link added")
            return simpleCell
        }
        
        let cell = RelatedLinkTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let relatedLink = relatedLinks[indexPath.row]
        cell.fill(with: relatedLink)
        return cell
    }
    
    private func didSelectRelatedLinkCell(atIndexPath indexPath: IndexPath) {
        guard let band = band, let relatedLinks = band.relatedLinks else { return }
        let relatedLink = relatedLinks[indexPath.row]
        guard let url = URL(string: relatedLink.urlString) else { return }
        presentAlertOpenURLInBrowsers(url, alertMessage: relatedLink.urlString)
        
        Analytics.logEvent("select_band_related_link", parameters: ["band_id": band.id ?? "", "band_name": band.name ?? "", "url_title": relatedLink.title, "url_string": relatedLink.urlString])
    }
}
