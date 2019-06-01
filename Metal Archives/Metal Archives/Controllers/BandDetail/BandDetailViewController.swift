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

final class BandDetailViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var stretchyLogoSmokedImageView: SmokedImageView!
    @IBOutlet private weak var stretchyLogoSmokedImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var utileBarView: UtileBarView!
    
    var bandURLString: String!
    private unowned var bandPhotoAndNameTableViewCell: BandPhotoAndNameTableViewCell?
    private var tableViewContentOffsetObserver: NSKeyValueObservation?
    
    private var band: Band?
    private var currentMenuOption: BandMenuOption = .discography
    
    // Discography
    private var currentDiscographyType: DiscographyType = UserDefaults.selectedDiscographyType()
    private var isAscendingOrderDiscography = true
    
    // Members
    private var currentMemberType: MembersType = .complete
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stretchyLogoSmokedImageViewHeightConstraint.constant = Settings.strechyBandLogoImageViewHeight
        configureTableView()
        handleUtileBarViewActions()
        reloadBand()
        navigationController?.interactivePopGestureRecognizer?.delegate = navigationController as! HomepageNavigationController
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

    private func reloadBand() {
        
        MetalArchivesAPI.reloadBand(bandURLString: self.bandURLString) { [weak self] (band, error) in
            if let _ = error {
                self?.reloadBand()
            } else if let `band` = band {
                self?.band = band
                
                if let logoURLString = band.logoURLString, let logoURL = URL(string: logoURLString) {
                    self?.stretchyLogoSmokedImageView.imageView.sd_setImage(with: logoURL, placeholderImage: nil, options: [.retryFailed], completed: nil)
                } else {
                    self?.tableView.contentInset = .zero
                }
                
                self?.utileBarView.titleLabel.text = band.name
                self?.title = band.name
                self?.currentMemberType = band.isLastKnown ? .lastKnown : .current
                
                self?.tableView.reloadData()
                
                Crashlytics.sharedInstance().setObjectValue(self?.band, forKey: CrashlyticsKey.Band)
            }
        }
    }
    
    private func handleUtileBarViewActions() {
        utileBarView.didTapBackButton = { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
        
        utileBarView.didTapShareButton = { [unowned self] in
            guard let `band` = self.band, let url = URL(string: band.urlString) else { return }
            
            self.presentAlertOpenURLInBrowsers(url, alertTitle: "View \(band.name!) in browser", alertMessage: band.urlString, shareMessage: "Share this band URL")
            
            Analytics.logEvent(AnalyticsEvent.ShareBand, parameters: nil)
        }
    }

    private func calculateAndApplyAlphaForBandPhotoAndNameCellAndUltileNavBar() {
        // Calculate alpha base of distant between utileBarView and the cell
        // the cell should only be dimmed only when the cell frame overlaps the utileBarView
        
        guard let bandPhotoAndNameTableViewCell = bandPhotoAndNameTableViewCell, let bandNameLabel = bandPhotoAndNameTableViewCell.nameLabel else {
            return
        }
        
        let bandNameLabelFrameInThisView = bandPhotoAndNameTableViewCell.convert(bandNameLabel.frame, to: view)
        let distanceFromBandNameLableToUtileBarView = bandNameLabelFrameInThisView.origin.y - (utileBarView.frame.origin.y + utileBarView.frame.size.height)
        
        // alpha = distance / label's height (dim base on label's frame)
        bandPhotoAndNameTableViewCell.alpha = (distanceFromBandNameLableToUtileBarView + bandNameLabel.frame.height) / bandNameLabel.frame.height
        utileBarView.setAlphaForBackgroundAndTitleLabel(1 - bandPhotoAndNameTableViewCell.alpha)
    }
    
    private func presentBandLogoInPhotoViewer() {
        guard let band = band, let bandLogoURLString = band.logoURLString else { return }
        presentPhotoViewer(photoURLString: bandLogoURLString, description: band.name)
    }
    
    private func presentOldBands() {
        guard let oldBands = band?.oldBands else { return }
        
        if oldBands.count == 1 {
            let oldBand = oldBands[0]
            self.pushBandDetailViewController(urlString: oldBand.urlString, animated: true)
            
        } else {
            var alertController: UIAlertController!
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                alertController = UIAlertController(title: "View \(band!.name!)'s old bands", message: nil, preferredStyle: .alert)
            } else {
                alertController = UIAlertController(title: "View \(band!.name!)'s old bands", message: nil, preferredStyle: .actionSheet)
            }
            
            for eachOldBand in oldBands {
                let bandAction = UIAlertAction(title: eachOldBand.name, style: .default, handler: { (action) in
                    self.pushBandDetailViewController(urlString: eachOldBand.urlString, animated: true)
                })
                alertController.addAction(bandAction)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
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
        BandMenuTableViewCell.register(with: tableView)
        DiscographyOptionsTableViewCell.register(with: tableView)
        ReleaseTableViewCell.register(with: tableView)
        MemberOptionTableViewCell.register(with: tableView)
        MemberTableViewCell.register(with: tableView)
        ReviewTableViewCell.register(with: tableView)
        SimilarBandTableViewCell.register(with: tableView)
        RelatedLinkTableViewCell.register(with: tableView)
        
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.contentInset = .init(top: Settings.strechyBandLogoImageViewHeight - Settings.bandPhotoImageViewHeight / 2, left: 0, bottom: 0, right: 0)
        
        // observe when tableView is scrolled to animate alphas because scrollViewDidScroll doesn't capture enough event.
        tableViewContentOffsetObserver = tableView.observe(\UITableView.contentOffset, options: [.new]) { [weak self] (tableView, _) in
            self?.calculateAndApplyAlphaForBandPhotoAndNameCellAndUltileNavBar()
            self?.stretchyLogoSmokedImageView.calculateAndApplyAlpha(withTableView: tableView)
        }
        
        // detect taps on band's logo, have to do this because band's logo is overlaid by tableView
        tableView.backgroundView = UIView()
        let backgroundViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tableViewBackgroundViewTapped))
        tableView.backgroundView?.addGestureRecognizer(backgroundViewTapGestureRecognizer)
    }
    
    @objc private func tableViewBackgroundViewTapped() {
        presentBandLogoInPhotoViewer()
    }
}

// MARK: - UITableViewDelegate
extension BandDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 && indexPath.row == 0 {
            presentBandLogoInPhotoViewer()
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 1
        }
        
        return 20
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
        case (0, 0):
            let cell = bandPhotoAndNameTableViewCell(forRowAt: indexPath)
            return cell
            
        case (0, 1):
            let cell = bandInfoTableViewCell(forRowAt: indexPath)
            return cell
            
        case (0, 2):
            let cell = bandMenuOptionsTableViewCell(forRowAt: indexPath)
            return cell
            
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
        cell.fill(with: band!)
        cell.tappedPhotoImageView = { [unowned self] in
            guard let band = self.band, let bandPhotoURLString = band.photoURLString else {
                return
            }
            
            self.presentPhotoViewer(photoURLString: bandPhotoURLString, description: band.name)
        }
        bandPhotoAndNameTableViewCell = cell
        return cell
    }
    
    private func bandInfoTableViewCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = BandInfoTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.fill(with: band!)
        
        cell.tappedYearsActiveLabel = { [unowned self] in
            self.presentOldBands()
        }
        cell.tappedLastModifiedOnLabel = { [unowned self] in
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
        cell.tappedLastLabelLabel = { [unowned self] in
            guard let lastLabelUrlString = self.band?.lastLabel.urlString else { return }
            self.pushLabelDetailViewController(urlString: lastLabelUrlString, animated: true)
        }
        return cell
    }
    
    private func bandMenuOptionsTableViewCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = BandMenuTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.horizontalMenuView.delegate = self
        return cell
    }
}

// MARK: - HorizontalMenuViewDelegate
extension BandDetailViewController: HorizontalMenuViewDelegate {
    func didSelectItem(atIndex index: Int) {
        currentMenuOption = BandMenuOption(rawValue: index) ?? .discography
        tableView.reloadSections([1], with: .automatic)
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
        guard let band = band, let discography = band.discography else { return 0 }
        
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
        guard let _ = band else {
            return UITableViewCell()
        }
        
        if indexPath.row == 0 {
            return discographyOptionsTableViewCell(atIndexPath: indexPath)
        }
        
        let cell = ReleaseTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        if let release = release(forIndexPath: indexPath) {
            cell.fill(with: release)
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
            self.tableView.reloadSections([1], with: .automatic)
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
        
        pushArtistDetailViewController(urlString: artist.urlString, animated: true)
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
        
        let cell = MemberTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        
        if let artist = artist(forRowAt: indexPath) {
            cell.fill(with: artist)
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
            if let complete = band.completeLineup, complete.count > index {
                artist = complete[index]
            }
            
        case .current:
            if let current = band.currentLineup, current.count > index {
                artist = current[index]
            }
        case .lastKnown:
            if let lastKnown = band.lastKnownLineup, lastKnown.count > index {
                artist = lastKnown[index]
            }
        case .past:
            if let past = band.pastMembers, past.count > index {
                artist = past[index]
            }
        case .live:
            if let live = band.liveMusicians, live.count > index {
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
            self.tableView.reloadSections([1], with: .automatic)
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
                self?.band?.associateReleasesToReviews()
                self?.tableView.reloadSections([1], with: .automatic)
            }
            return loadingCell
        }
        
        let cell = ReviewTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let review = band.reviewLitePagableManager.objects[indexPath.row]
        cell.fill(with: review)
        return cell
    }
    
    private func didSelectReviewCell(atIndexPath indexPath: IndexPath) {
        guard let band = band else { return }
        
        // tapped loading cell => return
        if indexPath.row == band.reviewLitePagableManager.objects.count && band.reviewLitePagableManager.moreToLoad {
            return
        }
        
        let review = band.reviewLitePagableManager.objects[indexPath.row]
        if let release = review.release {
            pushReleaseDetailViewController(urlString: release.urlString, animated: true)
        }
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
        return cell
    }
    
    private func didSelectSimilarArtistCell(atIndexPath indexPath: IndexPath) {
        guard let band = band, let similarArtists = band.similarArtists else { return }
        
        pushBandDetailViewController(urlString: similarArtists[indexPath.row].urlString, animated: true)
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
    }
}
