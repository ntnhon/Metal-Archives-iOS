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

//MARK: - Properties
final class ReleaseDetailViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var stretchyLogoSmokedImageView: SmokedImageView!
    @IBOutlet private weak var stretchyLogoSmokedImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var utileBarView: UtileBarView!
    
    var urlString: String!
    
    private var release: Release!
    private var currentReleaseMenuOption: ReleaseMenuOption = .trackList
    private var currentLineupType: LineUpType = .member
    private var isAscendingOrderReview = false
    private var tableViewContentOffsetObserver: NSKeyValueObservation?
    private unowned var releaseTitleAndTypeTableViewCell: ReleaseTitleAndTypeTableViewCell?

    override func viewDidLoad() {
        super.viewDidLoad()
        stretchyLogoSmokedImageViewHeightConstraint.constant = screenWidth
        configureTableView()
        handleUtileBarViewActions()
        reloadRelease()
    }
    
    deinit {
        print("ReleaseDetailViewController is deallocated")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingToParent {
            tableViewContentOffsetObserver?.invalidate()
            tableViewContentOffsetObserver = nil
        }
        navigationController?.isNavigationBarHidden = false
        stretchyLogoSmokedImageView.transform = .identity
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func reloadRelease() {
        MetalArchivesAPI.reloadRelease(urlString: urlString) { [weak self] (release, error) in
            guard let self = self else { return }
            if let _ = error as NSError? {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                    self.reloadRelease()
                })
            }
            else if let `release` = release {
                self.release = release
                
                if let coverURLString = release.coverURLString, let coverURL = URL(string: coverURLString) {
                    self.stretchyLogoSmokedImageView.imageView.sd_setImage(with: coverURL, placeholderImage: nil, options: [.retryFailed], completed: nil)
                } else {
                    self.tableView.contentInset = .init(top: self.utileBarView.frame.origin.y + self.utileBarView.frame.height + 10, left: 0, bottom: 0, right: 0)
                }
                
                self.utileBarView.titleLabel.text = release.title
                self.title = release.title
                self.tableView.reloadData()
                
                Analytics.logEvent(AnalyticsEvent.ViewRelease, parameters: [AnalyticsParameter.ReleaseTitle: release.title!, AnalyticsParameter.ReleaseID: release.id!])
                
                Crashlytics.sharedInstance().setObjectValue(release, forKey: CrashlyticsKey.Release)
            }
        }
    }
    
    private func configureTableView() {
        SimpleTableViewCell.register(with: tableView)
        LoadingTableViewCell.register(with: tableView)
        ReleaseTitleAndTypeTableViewCell.register(with: tableView)
        ReleaseInfoTableViewCell.register(with: tableView)
        ReleaseMenuTableViewCell.register(with: tableView)
        ReleaseElementTableViewCell.register(with: tableView)
        LineupOptionTableViewCell.register(with: tableView)
        ReleaseMemberTableViewCell.register(with: tableView)
        ReleaseReviewOptionTableViewCell.register(with: tableView)
        ReleaseReviewTableViewCell.register(with: tableView)
        ReleaseOtherVersionTableViewCell.register(with: tableView)
        
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.contentInset = .init(top: stretchyLogoSmokedImageViewHeightConstraint.constant, left: 0, bottom: 0, right: 0)
        
        // observe when tableView is scrolled to animate alphas because scrollViewDidScroll doesn't capture enough event.
        tableViewContentOffsetObserver = tableView.observe(\UITableView.contentOffset, options: [.new]) { [weak self] (tableView, _) in
            self?.calculateAndApplyAlphaForReleaseTitleTypeAndUltileNavBar()
            self?.stretchyLogoSmokedImageView.calculateAndApplyAlpha(withTableView: tableView)
        }
        
        // detect taps on band's logo, have to do this because band's logo is overlaid by tableView
        tableView.backgroundView = UIView()
        let backgroundViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tableViewBackgroundViewTapped))
        tableView.backgroundView?.addGestureRecognizer(backgroundViewTapGestureRecognizer)
    }
    
    @objc private func tableViewBackgroundViewTapped() {
        presentReleaseCoverInPhotoViewer()
    }
    
    private func presentReleaseCoverInPhotoViewer() {
        guard let release = release, let coverURLString = release.coverURLString else { return }
        presentPhotoViewer(photoURLString: coverURLString, description: release.title)
    }
    
    private func handleUtileBarViewActions() {
        utileBarView.didTapBackButton = { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
        
        utileBarView.didTapShareButton = { [unowned self] in
            guard let release = self.release, let url = URL(string: release.urlString) else { return }
            
            self.presentAlertOpenURLInBrowsers(url, alertTitle: "View \(release.title!) in browser", alertMessage: release.urlString, shareMessage: "Share this release URL")
            
            Analytics.logEvent(AnalyticsEvent.ShareRelease, parameters: nil)
        }
    }

    private func calculateAndApplyAlphaForReleaseTitleTypeAndUltileNavBar() {
        // Calculate alpha base of distant between utileBarView and the cell
        // the cell should only be dimmed only when the cell frame overlaps the utileBarView
        
        guard let releaseTitleAndTypeTableViewCell = releaseTitleAndTypeTableViewCell, let releaseTitleLabel = releaseTitleAndTypeTableViewCell.titleLabel else {
            return
        }
        
        let releaseTitleLabelFrameInThisView = releaseTitleAndTypeTableViewCell.convert(releaseTitleLabel.frame, to: view)
        let distanceFromReleaseTitleLableToUtileBarView = releaseTitleLabelFrameInThisView.origin.y - (utileBarView.frame.origin.y + utileBarView.frame.size.height)
        
        // alpha = distance / label's height (dim base on label's frame)
        releaseTitleAndTypeTableViewCell.alpha = (distanceFromReleaseTitleLableToUtileBarView + releaseTitleLabel.frame.height) / releaseTitleLabel.frame.height
        utileBarView.setAlphaForBackgroundAndTitleLabel(1 - releaseTitleAndTypeTableViewCell.alpha)
    }
}

//MARK: - UIPopoverPresentationControllerDelegate
extension ReleaseDetailViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
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
        
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }
        
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: screenWidth, height: 20)))
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
        case (0, 2): return releaseMenuTableViewCell(forRowAt: indexPath)
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
        cell.fill(with: release)
        

        cell.tappedLastModifiedOnLabel = { [unowned self] in
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
        cell.tappedLabelLabel = { [unowned self] in
            guard let labelUrlString = release.label.urlString else { return }
            self.pushLabelDetailViewController(urlString: labelUrlString, animated: true)
        }
        
        return cell
    }
    
    private func releaseMenuTableViewCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let _ = release else {
            return UITableViewCell()
        }
        
        let cell = ReleaseMenuTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.horizontalMenuView.delegate = self
        return cell
    }
}

// MARK: - HorizontalMenuViewDelegate
extension ReleaseDetailViewController: HorizontalMenuViewDelegate {
    func didSelectItem(atIndex index: Int) {
        currentReleaseMenuOption = ReleaseMenuOption(rawValue: index) ?? .trackList
        tableView.reloadSections([1], with: .automatic)
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
            
            Analytics.logEvent(AnalyticsEvent.ViewLyric, parameters: [AnalyticsParameter.ReleaseTitle: release.title!, AnalyticsParameter.ReleaseID: release.id!, AnalyticsParameter.SongTitle: song.title])
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
            self.tableView.reloadSections([1], with: .automatic)
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
        presentReviewController(urlString: review.urlString, animated: true, completion: nil)
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
