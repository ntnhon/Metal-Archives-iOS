//
//  ArtistDetailViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 18/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Toaster
import FirebaseAnalytics

final class ArtistDetailViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var stretchyPhotoSmokedImageView: SmokedImageView!
    @IBOutlet private weak var stretchyPhotoSmokedImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var simpleNavigationBarView: SimpleNavigationBarView!
    
    private var tableViewContentOffsetObserver: NSKeyValueObservation?
    
    var urlString: String!
    private var artist: Artist!
    
    private var artistInfoTypes: [ArtistInfoType]!
    private var currentArtistInfoType: ArtistInfoType!
    
    private var activeBandsRoles: [Any]!
    private var pastBandsRoles: [Any]!
    private var liveRoles: [Any]!
    private var guestSessionRoles: [Any]!
    private var miscStaffRoles: [Any]!
    
    private var artistNameTableViewCell: ArtistNameTableViewCell!
    private var artistInfoTableViewCell: ArtistInfoTableViewCell!
    
    // Floating menu
    private var horizontalMenuView: HorizontalMenuView!
    private var horizontalMenuViewTopConstraint: NSLayoutConstraint!
    private var horizontalMenuAnchorTableViewCell: HorizontalMenuAnchorTableViewCell! {
        didSet {
            anchorHorizontalMenuViewToAnchorTableViewCell()
        }
    }
    private lazy var yOffsetNeededToPinHorizontalViewToUtileBarView: CGFloat = {
        let yOffset = artistNameTableViewCell.bounds.height + artistInfoTableViewCell.bounds.height - simpleNavigationBarView.bounds.height
        return yOffset
    }()
    private var anchorHorizontalMenuToMenuAnchorTableViewCell = true
    
    deinit {
        print("ArtistDetailViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stretchyPhotoSmokedImageViewHeightConstraint.constant = screenWidth
        configureTableView()
        handleSimpleNavigationBarViewActions()
        reloadArtist()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingToParent {
            tableViewContentOffsetObserver?.invalidate()
            tableViewContentOffsetObserver = nil
        }
        stretchyPhotoSmokedImageView.transform = .identity
    }

    private func reloadArtist() {
        MetalArchivesAPI.reloadArtist(urlString: urlString) { [weak self] (artist, error) in
            guard let self = self else { return }
            if let _ = error {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                    self.reloadArtist()
                })
            } else {
                if let `artist` = artist {
                    DispatchQueue.main.async {
                        self.artist = artist
                        self.simpleNavigationBarView.setTitle(artist.bandMemberName)
                        
                        if let photoUrlString = artist.photoURLString, let photoURL = URL(string: photoUrlString) {
                            self.stretchyPhotoSmokedImageView.imageView.sd_setImage(with: photoURL, placeholderImage: nil, options: [.retryFailed], completed: nil)
                        } else {
                            self.tableView.contentInset = .init(top: self.simpleNavigationBarView.frame.origin.y + self.simpleNavigationBarView.frame.height + 10, left: 0, bottom: 0, right: 0)
                        }
                        
                        self.determineArtistInfoTypes()
                        self.determineArtistRoles()
                        self.initHorizontalMenuView()
                        self.tableView.reloadData()
                        
                        // Delay this method to wait for info cells to be fully loaded
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                            self.setTableViewBottomInsetToFillBottomSpace()
                        })
                        
                        Analytics.logEvent(AnalyticsEvent.ViewArtist, parameters: [AnalyticsParameter.ArtistName: artist.bandMemberName!, AnalyticsParameter.ArtistID: artist.id!])
                    }
                }
            }
        }
    }
    
    private func determineArtistInfoTypes() {
        artistInfoTypes = [ArtistInfoType]()
        if let _ = artist.activeBands {
            artistInfoTypes.append(.activeBands)
        }
        
        if let _ = artist.pastBands {
            artistInfoTypes.append(.pastBands)
        }
        
        if let _ = artist.live {
            artistInfoTypes.append(.live)
        }
        
        if let _ = artist.guestSession {
            artistInfoTypes.append(.guestSession)
        }
        
        if let _ = artist.miscStaff {
            artistInfoTypes.append(.miscStaff)
        }
        
        if let _ = artist.biography {
            artistInfoTypes.append(.biography)
        }
        
        if let _ = artist.links {
            artistInfoTypes.append(.links)
        }
        
        currentArtistInfoType = artistInfoTypes[0]
    }
    
    private func determineArtistRoles() {
        if let pastBands = artist.pastBands {
            pastBandsRoles = []
            pastBands.forEach { (rolesInBand) in
                pastBandsRoles.append(rolesInBand)
                rolesInBand.rolesInReleases?.forEach({ (rolesInRelease) in
                    pastBandsRoles.append(rolesInRelease)
                })
            }
        }
        
        if let activeBands = artist.activeBands {
            activeBandsRoles = []
            activeBands.forEach { (rolesInBand) in
                activeBandsRoles.append(rolesInBand)
                rolesInBand.rolesInReleases?.forEach({ (rolesInRelease) in
                    activeBandsRoles.append(rolesInRelease)
                })
            }
        }
        
        if let live = artist.live {
            liveRoles = []
            live.forEach { (rolesInBand) in
                liveRoles.append(rolesInBand)
                rolesInBand.rolesInReleases?.forEach({ (rolesInRelease) in
                    liveRoles.append(rolesInRelease)
                })
            }
        }
        
        if let guestSession = artist.guestSession {
            guestSessionRoles = []
            guestSession.forEach { (rolesInBand) in
                guestSessionRoles.append(rolesInBand)
                rolesInBand.rolesInReleases?.forEach({ (rolesInRelease) in
                    guestSessionRoles.append(rolesInRelease)
                })
            }
        }
        
        if let miscStaff = artist.miscStaff {
            miscStaffRoles = []
            miscStaff.forEach { (rolesInBand) in
                miscStaffRoles.append(rolesInBand)
                rolesInBand.rolesInReleases?.forEach({ (rolesInRelease) in
                    miscStaffRoles.append(rolesInRelease)
                })
            }
        }
    }
    
    private func configureTableView() {
        SimpleTableViewCell.register(with: tableView)
        ArtistNameTableViewCell.register(with: tableView)
        ArtistInfoTableViewCell.register(with: tableView)
        RolesInBandTableViewCell.register(with: tableView)
        RolesInReleaseTableViewCell.register(with: tableView)
        RelatedLinkTableViewCell.register(with: tableView)
        HorizontalMenuAnchorTableViewCell.register(with: tableView)
        
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.contentInset = .init(top: stretchyPhotoSmokedImageViewHeightConstraint.constant, left: 0, bottom: 0, right: 0)
        
        // observe when tableView is scrolled to animate alphas because scrollViewDidScroll doesn't capture enough event.
        tableViewContentOffsetObserver = tableView.observe(\UITableView.contentOffset, options: [.new]) { [weak self] (tableView, _) in
            self?.calculateAndApplyAlphaForArtistNameAndSimpleNavBar()
            self?.stretchyPhotoSmokedImageView.calculateAndApplyAlpha(withTableView: tableView)
            self?.anchorHorizontalMenuViewToAnchorTableViewCell()
        }
        
        // detect taps on band's logo, have to do this because band's logo is overlaid by tableView
        tableView.backgroundView = UIView()
        let backgroundViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tableViewBackgroundViewTapped))
        tableView.backgroundView?.addGestureRecognizer(backgroundViewTapGestureRecognizer)
    }
    
    @objc private func tableViewBackgroundViewTapped() {
        presentArtistInPhotoViewer()
    }
    
    private func presentArtistInPhotoViewer() {
        guard let artist = artist, let photoURLString = artist.photoURLString else { return }
        presentPhotoViewer(photoUrlString: photoURLString, description: "\(artist.realFullName!) (\(artist.bandMemberName!))", fromImageView: stretchyPhotoSmokedImageView.imageView)
    }
    
    private func initHorizontalMenuView() {
        var options = [String]()
        artistInfoTypes.forEach({
            options.append($0.description)
        })
        horizontalMenuView = HorizontalMenuView(options: options, font: Settings.currentFontSize.secondaryTitleFont, normalColor: Settings.currentTheme.bodyTextColor, highlightColor: Settings.currentTheme.secondaryTitleColor)
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
        
        simpleNavigationBarView.didTapRightButton = { [unowned self] in
            guard let artist = self.artist, let url = URL(string: artist.urlString) else { return }
            
            self.presentAlertOpenURLInBrowsers(url, alertTitle: "View \(artist.bandMemberName!) in browser", alertMessage: artist.urlString, shareMessage: "Share this artist URL")
            
            Analytics.logEvent(AnalyticsEvent.ShareRelease, parameters: nil)
        }
    }
    
    private func calculateAndApplyAlphaForArtistNameAndSimpleNavBar() {
        // Calculate alpha base of distant between simpleNavBarView and the cell
        // the cell should only be dimmed only when the cell frame overlaps the utileBarView
        
        guard let artistNameTableViewCell = artistNameTableViewCell, let artistNameLabel = artistNameTableViewCell.nameLabel else {
            return
        }
        
        let artistNameLabellFrameInThisView = artistNameTableViewCell.convert(artistNameLabel.frame, to: view)
        let distanceFromArtistNameLabelToUtileBarView = artistNameLabellFrameInThisView.origin.y - (simpleNavigationBarView.frame.origin.y + simpleNavigationBarView.frame.size.height)
        
        // alpha = distance / label's height (dim base on label's frame)
        artistNameTableViewCell.alpha = (distanceFromArtistNameLabelToUtileBarView + artistNameLabel.frame.height) / artistNameLabel.frame.height
        simpleNavigationBarView.setAlphaForBackgroundAndTitleLabel(1 - artistNameTableViewCell.alpha)
    }
}

// MARK: - UITableViewDelegate
extension ArtistDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let _ = artist, indexPath.section > 0 else { return }
        
        switch currentArtistInfoType! {
        case .biography: return
        case .links: didSelectRelatedLinkCell(atIndexPath: indexPath)
        default: didSelectRolesTableViewCell(atIndexPath: indexPath)
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
extension ArtistDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let _ = artist else { return 0 }
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let artist = artist else { return 0}
        
        if section == 0 {
            return 3
        }
        
        switch currentArtistInfoType! {
        case .activeBands: return activeBandsRoles.count
        case .pastBands: return pastBandsRoles.count
        case .live: return liveRoles.count
        case .guestSession: return guestSessionRoles.count
        case .miscStaff: return miscStaffRoles.count
        case .biography: return 1
        case .links:
            if let links = artist.links {
                return links.count
            }
            
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let _ = artist else {
            return UITableViewCell()
        }
        
        switch (indexPath.section, indexPath.row) {
        case (0, 0): return artistNameTableViewCell(forRowAt: indexPath)
        case (0, 1): return artistInfoTableViewCell(forRowAt: indexPath)
        case (0, 2): return horizontalMenuAnchorTableViewCell(forRowAt: indexPath)
        default:
            switch currentArtistInfoType! {
            case .biography: return biographyCell(forRowAt: indexPath)
            case .links: return relatedLinkCell(forRowAt: indexPath)
            default: return rolesTableViewCell(forRowAt: indexPath)
            }
        }
    }
}

// MARK: - Custom cells for section 0
extension ArtistDetailViewController {
    private func artistNameTableViewCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let artist = artist else {
            return UITableViewCell()
        }
        
        let cell = ArtistNameTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        artistNameTableViewCell = cell
        cell.fill(with: artist.bandMemberName)
        return cell
    }
    
    private func artistInfoTableViewCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let artist = artist else {
            return UITableViewCell()
        }
        
        let cell = ArtistInfoTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        artistInfoTableViewCell = cell
        cell.fill(with: artist)
        return cell
    }
    
    private func horizontalMenuAnchorTableViewCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = HorizontalMenuAnchorTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        horizontalMenuAnchorTableViewCell = cell
        horizontalMenuAnchorTableViewCell.contentView.heightAnchor.constraint(equalToConstant: horizontalMenuView.intrinsicHeight).isActive = true
        return cell
    }
}

// MARK: - Roles
extension ArtistDetailViewController {
    private func rolesTableViewCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        var roles: Any?
        
        switch currentArtistInfoType! {
        case .activeBands: roles = activeBandsRoles[indexPath.row]
        case .pastBands: roles = pastBandsRoles[indexPath.row]
        case .live: roles = liveRoles[indexPath.row]
        case .guestSession: roles = guestSessionRoles[indexPath.row]
        case .miscStaff: roles = miscStaffRoles[indexPath.row]
        default: return UITableViewCell()
        }
        
        if let rolesInBand = roles as? RolesInBand {
            let cell = RolesInBandTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            cell.fill(with: rolesInBand)
            return cell
        } else if let rolesInRelease = roles as? RolesInRelease {
            let cell = RolesInReleaseTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            cell.fill(with: rolesInRelease)
            return cell
        }
        
        return UITableViewCell()
    }
    
    private func didSelectRolesTableViewCell(atIndexPath indexPath: IndexPath) {
        guard let _ = artist else { return }
        
        var roles: Any?
        
        switch currentArtistInfoType! {
        case .activeBands: roles = activeBandsRoles[indexPath.row]
        case .pastBands: roles = pastBandsRoles[indexPath.row]
        case .live: roles = liveRoles[indexPath.row]
        case .guestSession: roles = guestSessionRoles[indexPath.row]
        case .miscStaff: roles = miscStaffRoles[indexPath.row]
        default: return
        }
        
        if let rolesInBand = roles as? RolesInBand, let bandURLString = rolesInBand.bandURLString {
            pushBandDetailViewController(urlString: bandURLString, animated: true)
        } else if let rolesInRelease = roles as? RolesInRelease {
            pushReleaseDetailViewController(urlString: rolesInRelease.releaseURLString, animated: true)
        }
    }
}

// MARK: - Biography
extension ArtistDetailViewController {
    private func biographyCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let artist = artist, let biography = artist.biography else {
            return UITableViewCell()
        }
        
        let simpleCell = SimpleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        simpleCell.fill(with: biography)
        return simpleCell
    }
}

extension ArtistDetailViewController {
    private func relatedLinkCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let artist = artist, let links = artist.links else {
            return UITableViewCell()
        }
        
        let cell = RelatedLinkTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.fill(with: links[indexPath.row])
        return cell
    }
    
    private func didSelectRelatedLinkCell(atIndexPath indexPath: IndexPath) {
        guard let artist = artist, let links = artist.links else { return }
        
        let link = links[indexPath.row]
        presentAlertOpenURLInBrowsers(URL(string: link.urlString)!, alertTitle: "Open this link in browser", alertMessage: link.urlString, shareMessage: "Share this link")
    }
}

// MARK: - HorizontalMenuViewDelegate
extension ArtistDetailViewController: HorizontalMenuViewDelegate {
    func horizontalMenu(_ horizontalMenu: HorizontalMenuView, didSelectItemAt index: Int) {
        currentArtistInfoType = artistInfoTypes[index]
        pinHorizontalMenuViewThenRefreshAndScrollTableView()
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
        self.tableView.contentInset.bottom = max(0, screenHeight - self.tableView.contentSize.height + self.yOffsetNeededToPinHorizontalViewToUtileBarView)
    }
}
