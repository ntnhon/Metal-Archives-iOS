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
    @IBOutlet private weak var stretchyLogoSmokedImageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var stretchyLogoSmokedImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var utileBarView: UtileBarView!
    
    var bandURLString: String!
    private var band: Band?
    private var currentMenuOption: BandMenuOption = .discography
    
    private var currentDiscographyType: DiscographyType = UserDefaults.selectedDiscographyType()
    private var isAscendingOrderDiscography = true
    
    private unowned var bandPhotoAndNameTableViewCell: BandPhotoAndNameTableViewCell?
    private var tableViewContentOffsetObserver: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureStretchyImageView()
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
                    self?.stretchyLogoSmokedImageView.imageView.sd_setImage(with: logoURL)
                }
                
                self?.utileBarView.titleLabel.text = band.name
                
                self?.title = band.name
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
    
    private func calculateAndApplyAlphaForStretchyLogoSmokedImageView() {
        
        let scaleRatio = abs(tableView.contentOffset.y) / tableView.contentInset.top
        
        guard scaleRatio >= 0 && scaleRatio <= 2 else { return }
        
        if scaleRatio > 1.0 {
            // Zoom stretchyLogoSmokedImageView
            stretchyLogoSmokedImageView.transform = CGAffineTransform(scaleX: scaleRatio, y: scaleRatio)
        } else {
            guard tableView.contentOffset.y < 0 else { return }
            // Move stretchyLogoSmokedImageView up
            let translationY = (20 * scaleRatio)
            stretchyLogoSmokedImageView.transform = CGAffineTransform(translationX: 0, y: translationY)
            
            stretchyLogoSmokedImageView.smokeDegree(1 - scaleRatio)
            
        }
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
    private func configureStretchyImageView() {
        stretchyLogoSmokedImageView.clipsToBounds = false
        stretchyLogoSmokedImageView.contentMode = .scaleAspectFill
        stretchyLogoSmokedImageViewHeightConstraint.constant = Settings.strechyImageViewHeight
    }
    
    private func configureTableView() {
        BandPhotoAndNameTableViewCell.register(with: tableView)
        BandInfoTableViewCell.register(with: tableView)
        BandMenuTableViewCell.register(with: tableView)
        DiscographyOptionsTableViewCell.register(with: tableView)
        ReleaseTableViewCell.register(with: tableView)
        
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.contentInset = .init(top: Settings.strechyImageViewHeight - Settings.bandPhotoImageViewHeight / 3 * 4, left: 0, bottom: 0, right: 0)
        
        // observe when tableView is scrolled to animate alphas because scrollViewDidScroll doesn't capture enough event.
        tableViewContentOffsetObserver = tableView.observe(\UITableView.contentOffset, options: [.new]) { [weak self] (tableView, _) in
            self?.calculateAndApplyAlphaForBandPhotoAndNameCellAndUltileNavBar()
            self?.calculateAndApplyAlphaForStretchyLogoSmokedImageView()
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
        if indexPath.section == 0 && indexPath.row == 0 {
            presentBandLogoInPhotoViewer()
            return
        }
        
        switch currentMenuOption {
        case .discography: didSelectDiscographyCell(atIndexPath: indexPath)
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
        case .discography: return numberOfRowForDiscographySection()
        case .members: return numberOfRowForMemberSection()
        case .reviews: return numberOfRowForReviewSection()
        case .similarArtists: return numberOfRowForSimilarArtistSection()
        case .about: return numberOfRowForAboutSection()
        case .relatedLinks: return numberOfRowsForRelatedLinkSection()
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
    private func numberOfRowForDiscographySection() -> Int {
        guard let band = band, let discography = band.discography else { return 0 }
        
        switch currentDiscographyType {
        case .complete: return discography.complete.count + 1
        case .main: return discography.main.count + 1
        case .lives: return discography.lives.count + 1
        case .demos: return discography.demos.count + 1
        case .misc: return discography.misc.count + 1
        }
    }
    
    private func discographyCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let band = band, let discography = band.discography else {
            return UITableViewCell()
        }
        
        if indexPath.row == 0 {
            return discographyOptionsTableViewCell(atIndexPath: indexPath)
        }
        
        let cell = ReleaseTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
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
        
        switch currentDiscographyType {
        case .complete: release = discography.complete[index]
        case .main: release = discography.main[index]
        case .lives: release = discography.lives[index]
        case .demos: release = discography.demos[index]
        case .misc: release = discography.misc[index]
        }
        
        if let release = release {
            cell.fill(with: release)
        }

        return cell
    }
    
    private func didSelectDiscographyCell(atIndexPath indexPath: IndexPath) {
        
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
        
        cell.discographyTypeButton.setTitle(description, for: .normal)
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
        //discographyOptionListViewController.preferredContentSize = CGSize(width: screenWidth - 50, height: screenHeight*2/3)
        
        discographyOptionListViewController.popoverPresentationController?.delegate = self
        discographyOptionListViewController.popoverPresentationController?.sourceView = self.tableView
    
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
    private func numberOfRowForMemberSection() -> Int {
        guard let band = band, let completeLineup = band.completeLineup else { return 0 }
        return completeLineup.count
    }
    
    private func memberCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

// MARK: - Reviews
extension BandDetailViewController {
    private func numberOfRowForReviewSection() -> Int {
        guard let band = band, let reviews = band.reviews else { return 0 }
        return reviews.count
    }
    
    private func reviewCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

// MARK: - Similar Artists
extension BandDetailViewController {
    private func numberOfRowForSimilarArtistSection() -> Int {
        guard let band = band, let similarArtists = band.similarArtists else { return 0 }
        return similarArtists.count
    }
    
    private func similarArtistCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

// MARK: - About
extension BandDetailViewController {
    private func numberOfRowForAboutSection() -> Int {
        guard let band = band, let _ = band.completeHTMLDescription else { return 0 }
        return 1
    }
    
    private func aboutCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

// MARK: - Related Links
extension BandDetailViewController {
    private func numberOfRowsForRelatedLinkSection() -> Int {
        guard let band = band, let relatedLinks = band.relatedLinks else { return 0 }
        return relatedLinks.count
    }
    
    private func relatedLinkCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
