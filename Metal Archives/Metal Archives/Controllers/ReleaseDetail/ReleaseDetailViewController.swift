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
    private var tableViewContentOffsetObserver: NSKeyValueObservation?
    private unowned var releaseTitleAndTypeTableViewCell: ReleaseTitleAndTypeTableViewCell?

    override func viewDidLoad() {
        super.viewDidLoad()
        stretchyLogoSmokedImageViewHeightConstraint.constant = screenWidth
        configureTableView()
        handleUtileBarViewActions()
        self.reloadRelease()
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
            if let _ = error as NSError? {
                self?.reloadRelease()
            }
            else if let `release` = release {
                self?.release = release
                
                if let coverURLString = release.coverURLString, let coverURL = URL(string: coverURLString) {
                    self?.stretchyLogoSmokedImageView.imageView.sd_setImage(with: coverURL)
                }
                
                self?.utileBarView.titleLabel.text = release.title
                self?.title = release.title
                self?.tableView.reloadData()
                
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
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 1
        }
        
        return 20
    }
}

// MARK: - UITableViewDataSource
extension ReleaseDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, 0): return releaseTitleTableViewCell(forRowAt: indexPath)
        case (0, 1): return releaseInfoTableViewCell(forRowAt: indexPath)
        default:
            return UITableViewCell()
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
        cell.fill(with: release)
        return cell
    }
    
    private func releaseInfoTableViewCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let release = release else {
            return UITableViewCell()
        }
        
        let cell = ReleaseInfoTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.fill(with: release)
        return cell
    }
}
