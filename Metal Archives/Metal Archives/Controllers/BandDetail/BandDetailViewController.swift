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
    
    func calculateAndApplyAlphaForStretchyLogoSmokedImageView() {
        
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
        if indexPath.row == 0 {
            presentBandLogoInPhotoViewer()
        }
    }
}

// MARK: - UITableViewDataSource
extension BandDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let _ = self.band else {
            return 0
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let _ = self.band else {
            return 0
        }
        
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = bandPhotoAndNameTableViewCell(forRowAt: indexPath)
            return cell
            
        case 1:
            let cell = bandInfoTableViewCell(forRowAt: indexPath)
            return cell
        case 2:
            let cell = bandMenuOptionsTableViewCell(forRowAt: indexPath)
            return cell
        default:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = "\(indexPath.row)"
            return cell
        }
    }
}

// MARK: - Custom cells
extension BandDetailViewController {
    func bandPhotoAndNameTableViewCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    func bandInfoTableViewCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    func bandMenuOptionsTableViewCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = BandMenuTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.horizontalMenuView.delegate = self
        return cell
    }
}

extension BandDetailViewController: HorizontalMenuViewDelegate {
    func didSelectItem(atIndex index: Int) {
        currentMenuOption = BandMenuOption(rawValue: index) ?? .discography
        
        tableView.reloadData()
    }
}
