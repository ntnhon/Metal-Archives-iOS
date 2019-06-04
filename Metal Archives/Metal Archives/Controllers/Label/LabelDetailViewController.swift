//
//  LabelDetailViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 24/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Toaster
import FirebaseAnalytics

final class LabelDetailViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var stretchyLogoSmokedImageView: SmokedImageView!
    @IBOutlet private weak var stretchyLogoSmokedImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var utileBarView: UtileBarView!
    
    private var tableViewContentOffsetObserver: NSKeyValueObservation?
    private unowned var labelNameTableViewCell: LabelNameTableViewCell?
    
    var urlString: String!
    
    private var label: Label!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stretchyLogoSmokedImageViewHeightConstraint.constant = Settings.strechyLogoImageViewHeight
        configureTableView()
        handleUtileBarViewActions()
        fetchLabel()
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

    private func fetchLabel() {
        MetalArchivesAPI.reloadLabel(urlString: self.urlString) { [weak self] (label, error) in
            guard let self = self else { return }
            if let _ = error {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                    self.fetchLabel()
                })
            } else if let `label` = label {
                DispatchQueue.main.async {
                    self.label = label
                    self.title = label.name
                    self.utileBarView.titleLabel.text = label.name
                    
                    if let logoURLString = label.logoURLString, let logoURL = URL(string: logoURLString) {
                        self.stretchyLogoSmokedImageView.imageView.sd_setImage(with: logoURL, placeholderImage: nil, options: [.retryFailed], completed: nil)
                    } else {
                        self.tableView.contentInset = .init(top: self.utileBarView.frame.origin.y + self.utileBarView.frame.height + 10, left: 0, bottom: 0, right: 0)
                    }
                    
                    self.tableView.reloadData()
                }
                
                Analytics.logEvent(AnalyticsEvent.ViewLabel, parameters: [AnalyticsParameter.LabelName: label.name!, AnalyticsParameter.LabelID: label.id!])
            }
        }
    }
    
    private func configureTableView() {
        SimpleTableViewCell.register(with: tableView)
        LabelNameTableViewCell.register(with: tableView)
        LabelInfoTableViewCell.register(with: tableView)
        
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.contentInset = .init(top: stretchyLogoSmokedImageViewHeightConstraint.constant, left: 0, bottom: 0, right: 0)
        
        // observe when tableView is scrolled to animate alphas because scrollViewDidScroll doesn't capture enough event.
        tableViewContentOffsetObserver = tableView.observe(\UITableView.contentOffset, options: [.new]) { [weak self] (tableView, _) in
            self?.calculateAndApplyAlphaForLabelNameAndUltileNavBar()
            self?.stretchyLogoSmokedImageView.calculateAndApplyAlpha(withTableView: tableView)
        }
        
        // detect taps on band's logo, have to do this because band's logo is overlaid by tableView
        tableView.backgroundView = UIView()
        let backgroundViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tableViewBackgroundViewTapped))
        tableView.backgroundView?.addGestureRecognizer(backgroundViewTapGestureRecognizer)
    }
    
    @objc private func tableViewBackgroundViewTapped() {
        presentLabelLogoInPhotoViewer()
    }
    
    private func presentLabelLogoInPhotoViewer() {
        guard let label = label, let logoURLString = label.logoURLString else { return }
        presentPhotoViewer(photoURLString: logoURLString, description: label.name)
    }
    
    private func handleUtileBarViewActions() {
        utileBarView.didTapBackButton = { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
        
        utileBarView.didTapShareButton = { [unowned self] in
            guard let label = self.label, let url = URL(string: label.urlString) else { return }
            
            self.presentAlertOpenURLInBrowsers(url, alertTitle: "View \(label.name!) in browser", alertMessage: label.urlString, shareMessage: "Share this label URL")
            
            Analytics.logEvent(AnalyticsEvent.ShareLabel, parameters: nil)
        }
    }
    
    private func calculateAndApplyAlphaForLabelNameAndUltileNavBar() {
        // Calculate alpha base of distant between utileBarView and the cell
        // the cell should only be dimmed only when the cell frame overlaps the utileBarView
        
        guard let labelNameTableViewCell = labelNameTableViewCell, let labelNameLabel = labelNameTableViewCell.nameLabel else {
            return
        }
        
        let labelNameLabellFrameInThisView = labelNameTableViewCell.convert(labelNameLabel.frame, to: view)
        let distanceFromLabelNameLabelToUtileBarView = labelNameLabellFrameInThisView.origin.y - (utileBarView.frame.origin.y + utileBarView.frame.size.height)
        
        // alpha = distance / label's height (dim base on label's frame)
        labelNameTableViewCell.alpha = (distanceFromLabelNameLabelToUtileBarView + labelNameLabel.frame.height) / labelNameLabel.frame.height
        utileBarView.setAlphaForBackgroundAndTitleLabel(1 - labelNameTableViewCell.alpha)
    }
}

// MARK: - UITableViewDelegate
extension LabelDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
extension LabelDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let _ = label else { return 0 }
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let _ = label else { return 0 }
        
        if section == 0 {
            return 2
        }
        
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let _ = label else {
            return UITableViewCell()
        }
        
        switch (indexPath.section, indexPath.row) {
        case (0, 0): return labelNameTableViewCell(forRowAt: indexPath)
        case (0, 1): return labelInfoTableViewCell(forRowAt: indexPath)
        default: return UITableViewCell()
        }
    }
}

// MARK: - Custom cells for section 0
extension LabelDetailViewController {
    private func labelNameTableViewCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let label = label else {
            return UITableViewCell()
        }
        
        let cell = LabelNameTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        labelNameTableViewCell = cell
        cell.fill(with: label.name)
        return cell
    }
    
    private func labelInfoTableViewCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let label = label else {
            return UITableViewCell()
        }
        
        let cell = LabelInfoTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.fill(with: label)
        
        cell.tappedLastModifiedOnLabel = { [unowned self] in
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
        
        cell.tappedWebsite = { [unowned self] in
            guard let website = label.website, let url = URL(string: website.urlString) else {
                return
            }
            
            self.presentAlertOpenURLInBrowsers(url, alertTitle: "Open this link in browser", alertMessage: website.urlString, shareMessage: "Share this link")
            
            Analytics.logEvent(AnalyticsEvent.ViewLabelWebsite, parameters: [AnalyticsParameter.LabelName: label.name!, AnalyticsParameter.LabelID: label.id!])
        }
        
        cell.tappedParentLabel = { [unowned self] in
            guard let parentLabel = self.label.parentLabel else { return }
            self.pushLabelDetailViewController(urlString: parentLabel.urlString, animated: true)
            
            Analytics.logEvent(AnalyticsEvent.ViewLabelParentLabel, parameters: [AnalyticsParameter.LabelName: label.name!, AnalyticsParameter.LabelID: label.id!])
        }
        
        return cell
    }
}
