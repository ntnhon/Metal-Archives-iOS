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
final class ReleaseDetailViewController: RefreshableViewController {
    var urlString: String!
    
    private var release: Release!
    
    private var availableLineUpType: [LineUpType]!
    private var completeLineUp: [ArtistLiteInRelease]?
    private var bandMembers: [ArtistLiteInRelease]?
    private var guestSessionMusicians: [ArtistLiteInRelease]?
    private var otherStaff: [ArtistLiteInRelease]?
    private var currentLineUpType: LineUpType = .complete
    
    private var memeberHeaderCell: ReleaseMemberHeaderTableViewCell?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.reloadRelease()
    }
    
    override func initAppearance() {
        super.initAppearance()
        //Hide 1st header
        self.tableView.contentInset = UIEdgeInsets(top: -CGFloat.leastNormalMagnitude, left: 0, bottom: 0, right: 0)
        
        ReleaseHeaderTableViewCell.register(with: self.tableView)
        ReleaseElementTableViewCell.register(with: self.tableView)
        ReleaseMemberHeaderTableViewCell.register(with: self.tableView)
        ReleaseMemberTableViewCell.register(with: self.tableView)
        ReleaseReviewTableViewCell.register(with: self.tableView)
        SimpleTableViewCell.register(with: self.tableView)
        ReleaseOtherVersionTableViewCell.register(with: self.tableView)
    }
    
    override func refresh() {
        self.currentLineUpType = .complete
        self.numberOfTries = 0
        self.completeLineUp = nil
        self.bandMembers = nil
        self.guestSessionMusicians = nil
        self.otherStaff = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.reloadRelease()
        }
        
        Analytics.logEvent(AnalyticsEvent.RefreshRelease, parameters: nil)
    }
    
    private func reloadRelease() {
        if self.numberOfTries == Settings.numberOfRetries {
            self.endRefreshing()
            Toast.displayMessageShortly("Error loading release. Please retry.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.navigationController?.popViewController(animated: true)
            }
            return
        }
        
        self.numberOfTries += 1
        self.removeShareBarButton()
        
        MetalArchivesAPI.reloadRelease(urlString: urlString) { [weak self] (release, error) in
            if let `error` = error as NSError? {
                if error.code == -999 {
                    self?.reloadRelease()
                } else {
                    self?.displayErrorLoadingAlert()
                }
            }
            else if let `release` = release {
                self?.release = release
                self?.title = release.title
                self?.determineLineUpTypeList()
                self?.addShareBarButton()
                self?.refreshSuccessfully()
                self?.tableView.reloadData()
                
                Analytics.logEvent(AnalyticsEvent.ViewRelease, parameters: [AnalyticsParameter.ReleaseTitle: release.title, AnalyticsParameter.ReleaseID: release.id])
                
                Crashlytics.sharedInstance().setValue(release, forKey: CrashlyticsKey.Release)
            }
        }
    }
    
    private func determineLineUpTypeList() {
        
        self.release.lineUp.forEach({
            switch $0.lineUpType {
            case .guest:
                if self.guestSessionMusicians == nil {
                    self.guestSessionMusicians = [ArtistLiteInRelease]()
                }
                
                
                self.guestSessionMusicians?.append($0)
            case .member:
                if self.bandMembers == nil {
                    self.bandMembers = [ArtistLiteInRelease]()
                }
                
                
                self.bandMembers?.append($0)
            case .other:
                if self.otherStaff == nil {
                    self.otherStaff = [ArtistLiteInRelease]()
                }
                
                self.otherStaff?.append($0)
            case .complete: ()
            }
        })
        
        self.availableLineUpType = [LineUpType]()
        
        if let _ = self.bandMembers {
            self.availableLineUpType.append(.member)
        }
        
        if let _ = self.guestSessionMusicians {
            self.availableLineUpType.append(.guest)
        }
        
        if let _ = self.otherStaff {
            self.availableLineUpType.append(.other)
        }
        
        if self.availableLineUpType.count > 0 {
            self.completeLineUp = self.release.lineUp
            self.availableLineUpType.insert(.complete, at: 0)
            self.currentLineUpType = self.availableLineUpType[1]
        }
    }
}

//MARK: - UIPopoverPresentationControllerDelegate
extension ReleaseDetailViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

//MARK: - Share
extension ReleaseDetailViewController {
    private func removeShareBarButton() {
        self.navigationItem.rightBarButtonItem = nil
    }
    
    private func addShareBarButton() {
        let shareBarButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapShareButton))
        self.navigationItem.rightBarButtonItem = shareBarButton
    }
    
    @objc private func didTapShareButton() {
        guard let `release` = self.release, let url = URL(string: release.urlString) else { return }
        
        self.presentAlertOpenURLInBrowsers(url, alertTitle: "View this release in browser", alertMessage: self.release.title, shareMessage: "Share this release URL")
        
        Analytics.logEvent(AnalyticsEvent.ShareRelease, parameters: [AnalyticsParameter.ReleaseTitle: self.release.title, AnalyticsParameter.ReleaseID: self.release.id])
    }
}

//MARK: - UITableViewDelegate
extension ReleaseDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0: return // Header
        case 1: self.didSelectRowInSongsSection(at: indexPath)
        case 2: self.didSelectRowInLineUpSection(at: indexPath)
        case 3: self.didSelectRowInReviewsSection(at: indexPath)
        case 4: self.didSelectRowInOtherVersionsSection(at: indexPath)
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return nil // Header
        case 1: return "SONGS"
        case 2: return "LINEUP"
        case 3: return "REVIEWS"
        case 4: return "OTHER VERSIONS"
        default: return nil
        }
    }
}

//MARK: - UITableViewDatasource
extension ReleaseDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if let _ = self.release {
            return 5
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            //Section HEADER
        case 0: return self.numberOfRowsInHeaderSection()
            //Section SONGS
        case 1: return self.numberOfRowsInSongsSection()
            //Section LINEUP
        case 2: return self.numberOfRowsInLineUpSection()
            //Section REVIEWS
        case 3: return self.numberOfRowsInReviewsSection()
            //Section OTHER VERSIONS
        case 4: return self.numberOfRowsInOtherVersionsSection()
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
            //Section HEADER
        case 0: return self.cellForHeaderSection(at: indexPath)
            //Section SONGS
        case 1: return self.cellForSongsSection(at: indexPath)
            //Section LINEUP
        case 2: return self.cellForLineUpSection(at: indexPath)
            //Section REVIEWS
        case 3: return self.cellForReviewsSection(at: indexPath)
            //Section OTHER VERSIONS
        case 4: return self.cellForOtherVersionsSection(at: indexPath)
        default: return UITableViewCell()
        }
    }
    
}

//MARK: - No element cell
extension ReleaseDetailViewController {
    private func noElementCell(message: String, at indexPath: IndexPath) -> SimpleTableViewCell {
        let noElementCell = SimpleTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        noElementCell.fill(with: message)
        return noElementCell
    }
}

//MARK: - Section HEADER
extension ReleaseDetailViewController {
    private func numberOfRowsInHeaderSection() -> Int {
        return 1
    }
    
    private func cellForHeaderSection(at indexPath: IndexPath) -> UITableViewCell {
        let headerCell = ReleaseHeaderTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        headerCell.fill(with: self.release)
        headerCell.delegate = self
        return headerCell
    }
}

//MARK: - Section SONGS
extension ReleaseDetailViewController {
    private func numberOfRowsInSongsSection() -> Int {
        return self.release.elements.count
    }
    
    private func cellForSongsSection(at indexPath: IndexPath) -> UITableViewCell {
        let elementCell = ReleaseElementTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        let element = self.release.elements[indexPath.row]
        elementCell.fill(with: element)
        return elementCell
    }
    
    private func didSelectRowInSongsSection(at indexPath: IndexPath) {
        let element = self.release.elements[indexPath.row]
        if element.type == .song {
            let song = element as! Song
            if let lyricID = song.lyricID {
                ToastCenter.default.cancelAll()
                let lyricViewController = UIStoryboard(name: "Lyric", bundle: nil).instantiateViewController(withIdentifier: "LyricViewController") as! LyricViewController
                lyricViewController.lyricID = lyricID
                lyricViewController.title = song.title
                
                let navLyricViewController = UINavigationController(rootViewController: lyricViewController)
                navLyricViewController.modalPresentationStyle = .popover
                navLyricViewController.popoverPresentationController?.permittedArrowDirections = .any
                navLyricViewController.preferredContentSize = CGSize(width: screenWith - 50, height: screenHeight*2/3)
                
                navLyricViewController.popoverPresentationController?.delegate = self
                navLyricViewController.popoverPresentationController?.sourceView = self.tableView
                
                let rect = self.tableView.rectForRow(at: indexPath)
                navLyricViewController.popoverPresentationController?.sourceRect = rect
                
                self.present(navLyricViewController, animated: true, completion: nil)
                
                Analytics.logEvent(AnalyticsEvent.ViewLyric, parameters: [AnalyticsParameter.ReleaseTitle: self.release.title, AnalyticsParameter.ReleaseID: self.release.id, AnalyticsParameter.SongTitle: song.title])
            } else {
                ToastCenter.default.cancelAll()
                Toast(text: "This song has no lyric", duration: Delay.short).show()
            }
        }
    }
}

//MARK: - Section LINEUP
extension ReleaseDetailViewController {
    private func numberOfRowsInLineUpSection() -> Int {
        // Plus 1 row for segmented header
        switch self.currentLineUpType {
        case .complete:
            if let count =  self.completeLineUp?.count {
                return count + 1
            }
            
            return 1 //Display no member row
        case .member:
            if let count =  self.bandMembers?.count {
                return count + 1
            }
            
            return 1
        case .guest:
            if let count =  self.guestSessionMusicians?.count {
                return count + 1
            }
            
            return 1
        case .other:
            if let count =  self.otherStaff?.count {
                return count + 1
            }
            
            return 1
        }
    }
    
    private func cellForLineUpSection(at indexPath: IndexPath) -> UITableViewCell {
        if self.release.lineUp.count == 0 {
            return noElementCell(message: "No information available.", at: indexPath)
        }
        
        if indexPath.row == 0 {
            return self.lineUpHeaderCell(at: indexPath)
        }
        
        return self.memberCell(at: indexPath)
    }
    
    private func lineUpHeaderCell(at indexPath: IndexPath) -> UITableViewCell {
        guard let `memberHeaderCell` = self.memeberHeaderCell else {
            let cell = ReleaseMemberHeaderTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
            
            cell.initSegmentControl(availableLineupTypes: self.availableLineUpType)
            cell.delegate = self
            self.memeberHeaderCell = cell
            return cell
        }
        
        return memberHeaderCell
    }
    
    private func memberCell(at indexPath: IndexPath) -> UITableViewCell {
        let cell = ReleaseMemberTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        
        var artist: ArtistLiteInRelease?
        let index = indexPath.row - 1
        
        switch self.currentLineUpType {
        case .complete: artist = self.completeLineUp?[index]
        case .member: artist = self.bandMembers?[index]
        case .guest: artist = self.guestSessionMusicians?[index]
        case .other: artist = self.otherStaff?[index]
        }
        
        if let `artist` = artist {
            cell.fill(with: artist)
        }
        
        return cell
    }
    
    private func didSelectRowInLineUpSection(at indexPath: IndexPath) {
        var artist: ArtistLiteInRelease?
        let index = indexPath.row - 1
        
        switch self.currentLineUpType {
        case .complete: artist = self.completeLineUp?[index]
        case .member: artist = self.bandMembers?[index]
        case .guest: artist = self.guestSessionMusicians?[index]
        case .other: artist = self.otherStaff?[index]
        }
        
        if let `artist` = artist {
            self.pushArtistDetailViewController(urlString: artist.urlString, animated: true)
            
            Analytics.logEvent(AnalyticsEvent.ViewReleaseArtist, parameters: [AnalyticsParameter.ReleaseTitle: self.release.title, AnalyticsParameter.ReleaseID: self.release.id, AnalyticsParameter.ArtistName: artist.name, AnalyticsParameter.ArtistID: artist.id])
        }
    }
}

//MARK: - Section REVIEWS
extension ReleaseDetailViewController {
    private func numberOfRowsInReviewsSection() -> Int {
        if self.release.reviews.count == 0 {
            return 1
        }
        
        return self.release.reviews.count
    }
    
    private func cellForReviewsSection(at indexPath: IndexPath) -> UITableViewCell {

        if self.release.reviews.count == 0 {
            return self.noElementCell(message: "No review available.", at: indexPath)
        }
        
        let cell = ReleaseReviewTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        let review = self.release.reviews[indexPath.row]
        cell.full(with: review)
        
        return cell
    }
    
    private func didSelectRowInReviewsSection(at indexPath: IndexPath) {
        if self.release.reviews.count == 0 {
            return
        }
        
        let review = self.release.reviews[indexPath.row]
        self.presentReviewController(urlString: review.urlString, animated: true, completion: nil)
        
        Analytics.logEvent(AnalyticsEvent.ViewReleaseReview, parameters: [AnalyticsParameter.ReleaseTitle: self.release.title, AnalyticsParameter.ReleaseID: self.release.id])
    }
}

//MARK: - Section OTHER VERSIONS
extension ReleaseDetailViewController {
    private func numberOfRowsInOtherVersionsSection() -> Int {
        if self.release.otherVersions.count == 0 {
            return 1
        }
        
        return self.release.otherVersions.count
    }
    
    private func cellForOtherVersionsSection(at indexPath: IndexPath) -> UITableViewCell {
        if self.release.otherVersions.count == 0 {
            return self.noElementCell(message: "No other version available.", at: indexPath)
        }
        
        let cell = ReleaseOtherVersionTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        let version = self.release.otherVersions[indexPath.row]
        cell.fill(with: version)
        
        if indexPath.row == 0 {
            cell.markAsThisVersion()
        }
        
        return cell
    }
    
    private func didSelectRowInOtherVersionsSection(at indexPath: IndexPath) {
        guard let otherVersions = self.release.otherVersions else {
            return
        }
        
        if otherVersions.count > 1 {
            if indexPath.row == 0 {
                ToastCenter.default.cancelAll()
                Toast(text: "This version", duration: Delay.short).show()
            } else {
                let otherVersion = otherVersions[indexPath.row]
                self.pushReleaseDetailViewController(urlString: otherVersion.urlString, animated: true)
                
                Analytics.logEvent(AnalyticsEvent.ViewReleaseOtherVersion, parameters: [AnalyticsParameter.ReleaseTitle: self.release.title, AnalyticsParameter.ReleaseID: self.release.id])
            }
        }
    }
}

//MARK: - ReleaseHeaderTableViewCellDelegate
extension ReleaseDetailViewController: ReleaseHeaderTableViewCellDelegate {
    func didTapCoverImageView() {
        if let urlString = self.release.coverURLString {
            self.presentPhotoViewer(photoURLString: urlString, description: release.title)
            
            Analytics.logEvent(AnalyticsEvent.ViewReleaseCover, parameters: [AnalyticsParameter.ReleaseTitle: self.release.title, AnalyticsParameter.ReleaseID: self.release.id])
        }
    }
    
    func didTapLastModifiedOn() {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        
        Analytics.logEvent(AnalyticsEvent.ViewReleaseLastModifiedDate, parameters: [AnalyticsParameter.ReleaseTitle: self.release.title, AnalyticsParameter.ReleaseID: self.release.id])
    }
}

//MARK: - ReleaseMemberHeaderTableViewCellDelegate
extension ReleaseDetailViewController: ReleaseMemberHeaderTableViewCellDelegate {
    func lineUpTypeChanged(_ lineUpTypeIndex: Int) {
        self.currentLineUpType = self.availableLineUpType[lineUpTypeIndex]
        self.tableView.beginUpdates()
        self.tableView.reloadSections([2], with: .none)
        self.tableView.endUpdates()
        
        Analytics.logEvent(AnalyticsEvent.ChangeLineUpType, parameters: [AnalyticsParameter.ReleaseTitle: self.release.title, AnalyticsParameter.ReleaseID: self.release.id, AnalyticsParameter.LineUpType: self.currentLineUpType.description])
        
        Crashlytics.sharedInstance().setValue(self.currentLineUpType.description, forKey: CrashlyticsKey.LineupType)
    }
}
