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
import Crashlytics

final class LabelDetailViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var stretchyLogoSmokedImageView: SmokedImageView!
    @IBOutlet private weak var stretchyLogoSmokedImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var simpleNavigationBarView: SimpleNavigationBarView!
    
    private var tableViewContentOffsetObserver: NSKeyValueObservation?
    
    private var labelMenuOptions: [LabelMenuOption]!
    private var currentLabelMenuOption: LabelMenuOption!
    
    var urlString: String!
    
    private var label: Label!
    
    private var labelNameTableViewCell: LabelNameTableViewCell!
    private var labelInfoTableViewCell: LabelInfoTableViewCell!
    
    // Floating menu
    private var horizontalMenuView: HorizontalMenuView!
    private var horizontalMenuViewTopConstraint: NSLayoutConstraint!
    private var horizontalMenuAnchorTableViewCell: HorizontalMenuAnchorTableViewCell! {
        didSet {
            anchorHorizontalMenuViewToAnchorTableViewCell()
        }
    }
    private var yOffsetNeededToPinHorizontalViewToUtileBarView: CGFloat {
        let yOffset = labelNameTableViewCell.bounds.height + labelInfoTableViewCell.bounds.height - simpleNavigationBarView.bounds.height
        return yOffset
    }
    private var anchorHorizontalMenuToMenuAnchorTableViewCell = true
    
    var historyRecordableDelegate: HistoryRecordable?
    
    private var adjustedTableViewContentOffset = false
    
    deinit {
        print("LabelDetailViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stretchyLogoSmokedImageViewHeightConstraint.constant = Settings.strechyLogoImageViewHeight
        configureTableView()
        handleSimpleNavigationBarViewActions()
        fetchLabel()
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

    private func fetchLabel() {
        showHUD(hideNavigationBar: true)
        
        MetalArchivesAPI.reloadLabel(urlString: self.urlString) { [weak self] (label, error) in
            guard let self = self else { return }
            if let _ = error {
                self.showHUD()
                DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                    self.fetchLabel()
                })
            } else {
                self.hideHUD()
                guard let label = label else {
                    Toast.displayMessageShortly(errorLoadingMessage)
                    self.navigationController?.popViewController(animated: true)
                    return
                }
                
                self.label = label
                self.title = label.name
                self.simpleNavigationBarView.setTitle(label.name)
                self.determineLabelMenuOptions()
                self.initHorizontalMenuView()
                
                if let logoURLString = label.logoURLString, let logoURL = URL(string: logoURLString) {
                    self.stretchyLogoSmokedImageView.imageView.sd_setImage(with: logoURL, placeholderImage: nil, options: [.retryFailed], completed: nil)
                } else {
                    self.tableView.contentInset = .init(top: self.simpleNavigationBarView.frame.origin.y + self.simpleNavigationBarView.frame.height + 10, left: 0, bottom: UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0, right: 0)
                }
                
                self.label.currentRosterPagableManager.delegate = self
                self.label.pastRosterPagableManager.delegate = self
                self.label.releasesPagableManager.delegate = self
                
                self.tableView.reloadData()
                
                // Delay this method to wait for info cells to be fully loaded
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    self.setTableViewBottomInsetToFillBottomSpace()
                })
                
                self.historyRecordableDelegate?.loaded(urlString: label.urlString, nameOrTitle: label.name, thumbnailUrlString: label.logoURLString, objectType: .label)
            
                Analytics.logEvent("view_label", parameters: ["label_id": label.id ?? "", "label_name": label.name ?? ""])
                Crashlytics.sharedInstance().setObjectValue(label.generalDescription, forKey: "label")
            }
        }
    }
    
    private func determineLabelMenuOptions() {
        labelMenuOptions = [LabelMenuOption]()
        
        if let _ = label.subLabels {
            labelMenuOptions.append(.subLabels)
        }
        
        if let _ = label.currentRosterPagableManager.totalRecords {
            if label.isLastKnown {
                labelMenuOptions.append(.lastKnownRoster)
            } else {
                labelMenuOptions.append(.currentRoster)
            }
        }
        
        if let _ = label.pastRosterPagableManager.totalRecords {
            labelMenuOptions.append(.pastRoster)
        }
        
        if let _ = label.releasesPagableManager.totalRecords {
            labelMenuOptions.append(.releases)
        }
        
        if let _ = label.additionalNotes {
            labelMenuOptions.append(.additionalNotes)
        }
        
        if let _ = label.links {
            labelMenuOptions.append(.links)
        }
        
        currentLabelMenuOption = labelMenuOptions[0]
    }
    
    private func configureTableView() {
        SimpleTableViewCell.register(with: tableView)
        LoadingTableViewCell.register(with: tableView)
        LabelNameTableViewCell.register(with: tableView)
        LabelInfoTableViewCell.register(with: tableView)
        SubLabelTableViewCell.register(with: tableView)
        BandCurrentRosterTableViewCell.register(with: tableView)
        BandPastRosterTableViewCell.register(with: tableView)
        ReleaseInLabelTableViewCell.register(with: tableView)
        RelatedLinkTableViewCell.register(with: tableView)
        HorizontalMenuAnchorTableViewCell.register(with: tableView)
        
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.contentInset = .init(top: stretchyLogoSmokedImageViewHeightConstraint.constant, left: 0, bottom: UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0, right: 0)
        
        // observe when tableView is scrolled to animate alphas because scrollViewDidScroll doesn't capture enough event.
        tableViewContentOffsetObserver = tableView.observe(\UITableView.contentOffset, options: [.new]) { [weak self] (tableView, _) in
            self?.calculateAndApplyAlphaForLabelNameAndSimpleNavBar()
            self?.stretchyLogoSmokedImageView.calculateAndApplyAlpha(withTableView: tableView)
            self?.anchorHorizontalMenuViewToAnchorTableViewCell()
        }
        
        // detect taps on label's logo, have to do this because label's logo is overlaid by tableView
        tableView.backgroundView = UIView()
        let backgroundViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tableViewBackgroundViewTapped))
        tableView.backgroundView?.addGestureRecognizer(backgroundViewTapGestureRecognizer)
    }
    
    @objc private func tableViewBackgroundViewTapped() {
        presentLabelLogoInPhotoViewer()
    }
    
    private func presentLabelLogoInPhotoViewer() {
        guard let label = label, let logoURLString = label.logoURLString else { return }
        presentPhotoViewer(photoUrlString: logoURLString, description: label.name, fromImageView: stretchyLogoSmokedImageView.imageView)
    }
    
    private func initHorizontalMenuView() {
        horizontalMenuView = HorizontalMenuView(options: labelMenuOptions.map({$0.description}), font: Settings.currentFontSize.secondaryTitleFont, normalColor: Settings.currentTheme.bodyTextColor, highlightColor: Settings.currentTheme.secondaryTitleColor)
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
            guard let label = self.label, let url = URL(string: label.urlString) else { return }
            
            self.presentAlertOpenURLInBrowsers(url, alertTitle: "View \(label.name!) in browser", alertMessage: label.urlString, shareMessage: "Share this label URL")
            
            Analytics.logEvent("share_label", parameters: ["label_id": label.id ?? "", "label_name": label.name ?? ""])
        }
    }
    
    private func calculateAndApplyAlphaForLabelNameAndSimpleNavBar() {
        // Calculate alpha base of distant between simpleNavBarView and the cell
        // the cell should only be dimmed only when the cell frame overlaps the utileBarView
        
        guard let labelNameTableViewCell = labelNameTableViewCell, let labelNameLabel = labelNameTableViewCell.nameLabel else {
            return
        }
        
        let labelNameLabellFrameInThisView = labelNameTableViewCell.convert(labelNameLabel.frame, to: view)
        let distanceFromLabelNameLabelToUtileBarView = labelNameLabellFrameInThisView.origin.y - (simpleNavigationBarView.frame.origin.y + simpleNavigationBarView.frame.size.height)
        
        // alpha = distance / label's height (dim base on label's frame)
        labelNameTableViewCell.alpha = (distanceFromLabelNameLabelToUtileBarView + labelNameLabel.frame.height) / labelNameLabel.frame.height
        simpleNavigationBarView.setAlphaForBackgroundAndTitleLabel(1 - labelNameTableViewCell.alpha)
    }
}

// MARK: - UITableViewDelegate
extension LabelDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let _ = label, indexPath.section > 0 else { return }
        
        switch currentLabelMenuOption! {
        case .subLabels: didSelectSubLabelTableViewCell(atIndexPath: indexPath)
        case .lastKnownRoster, .currentRoster: didSelectCurrentOrLastKnownRosterTableViewCell(atIndexPath: indexPath)
        case .pastRoster: didSelectPastRosterTableViewCell(atIndexPath: indexPath)
        case .releases: didSelectReleaseTableViewCell(atIndexPath: indexPath)
        case .links: didSelectRelatedLinkTableViewCell(atIndexPath: indexPath)
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
extension LabelDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let _ = label else { return 0 }
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let _ = label else { return 0 }
        
        if section == 0 {
            return 3
        }
        
        switch currentLabelMenuOption! {
        case .subLabels: return label.subLabels!.count
        case .lastKnownRoster, .currentRoster:
            if label.currentRosterPagableManager.moreToLoad {
                return label.currentRosterPagableManager.objects.count + 1
            }
            return label.currentRosterPagableManager.objects.count
            
        case .pastRoster:
            if label.pastRosterPagableManager.moreToLoad {
                return label.pastRosterPagableManager.objects.count + 1
            }
            return label.pastRosterPagableManager.objects.count
            
        case .releases:
            if label.releasesPagableManager.moreToLoad {
                return label.releasesPagableManager.objects.count + 1
            }
            return label.releasesPagableManager.objects.count
            
        case .additionalNotes: return 1
        case .links: return label.links!.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let _ = label else {
            return UITableViewCell()
        }
        
        switch (indexPath.section, indexPath.row) {
        case (0, 0): return labelNameTableViewCell(forRowAt: indexPath)
        case (0, 1): return labelInfoTableViewCell(forRowAt: indexPath)
        case (0, 2): return horizontalMenuAnchorTableViewCell(forRowAt: indexPath)
        default:
            switch currentLabelMenuOption! {
            case .subLabels: return subLabelTableViewCell(forRowAt: indexPath)
            case .lastKnownRoster, .currentRoster: return currentOrLastKnownRosterTableViewCell(forRowAt: indexPath)
            case .pastRoster: return pastRosterTableViewCell(forRowAt: indexPath)
            case .releases: return releaseTableViewCell(forRowAt: indexPath)
            case .additionalNotes: return additionalNotesTableViewCell(forRowAt: indexPath)
            case .links: return relatedLinkTableViewCell(forRowAt: indexPath)
            }
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
        labelInfoTableViewCell = cell
        cell.fill(with: label)
        
        cell.tappedLastModifiedOnLabel = { [unowned self] in
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            
            Analytics.logEvent("view_label_last_modified_date", parameters: ["label_id": label.id ?? "", "label_name": label.name ?? ""])
        }
        
        cell.tappedWebsite = { [unowned self] in
            guard let website = label.website, let url = URL(string: website.urlString) else {
                return
            }
            
            self.presentAlertOpenURLInBrowsers(url, alertTitle: "Open this link in browser", alertMessage: website.urlString, shareMessage: "Share this link")
            
            Analytics.logEvent("view_label_website", parameters: ["label_id": label.id ?? "", "label_name": label.name ?? ""])
        }
        
        cell.tappedParentLabel = { [unowned self] in
            guard let parentLabel = self.label.parentLabel else { return }
            self.pushLabelDetailViewController(urlString: parentLabel.urlString, animated: true)
            
            Analytics.logEvent("view_label_parent_label", parameters: ["label_id": label.id ?? "", "label_name": label.name ?? "", "parent_label_id": parentLabel.id, "parent_label_name": parentLabel.name])
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

// MARK: - Sub-labels
extension LabelDetailViewController {
    private func subLabelTableViewCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let label = label else {
            return UITableViewCell()
        }
        
        let cell = SubLabelTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let subLabel = label.subLabels![indexPath.row]
        cell.fill(with: subLabel)
        
        cell.tappedThumbnailImageView = { [unowned self] in
            self.presentPhotoViewerWithCacheChecking(photoUrlString: subLabel.imageURLString, description: subLabel.name, fromImageView: cell.thumbnailImageView)
            
            Analytics.logEvent("view_label_sublabel_thumbnail", parameters: ["label_id": label.id ?? "", "label_name": label.name ?? "", "sublabel_id": subLabel.id, "sublabel_name": subLabel.name])
        }
        
        return cell
    }
    
    private func didSelectSubLabelTableViewCell(atIndexPath indexPath: IndexPath) {
        guard let label = label else { return }
        
        let subLabel = label.subLabels![indexPath.row]
        pushLabelDetailViewController(urlString: subLabel.urlString, animated: true)
        
        Analytics.logEvent("select_label_sublabel", parameters: ["label_id": label.id ?? "", "label_name": label.name ?? "", "sublabel_id": subLabel.id, "sublabel_name": subLabel.name])
    }
}

// MARK: - HorizontalMenuViewDelegate
extension LabelDetailViewController: HorizontalMenuViewDelegate {
    func horizontalMenu(_ horizontalMenu: HorizontalMenuView, didSelectItemAt index: Int) {
        currentLabelMenuOption = labelMenuOptions[index]
        pinHorizontalMenuViewThenRefreshAndScrollTableView()
        
        switch currentLabelMenuOption! {
        case .subLabels: Analytics.logEvent("view_label_sub_labels", parameters: ["label_id": label.id ?? "", "label_name": label.name ?? ""])
        case .currentRoster: Analytics.logEvent("view_label_current_roster", parameters: ["label_id": label.id ?? "", "label_name": label.name ?? ""])
        case .pastRoster: Analytics.logEvent("view_label_past_roster", parameters: ["label_id": label.id ?? "", "label_name": label.name ?? ""])
        case .lastKnownRoster: Analytics.logEvent("view_label_lastknown_roster", parameters: ["label_id": label.id ?? "", "label_name": label.name ?? ""])
        case .releases: Analytics.logEvent("view_label_releases", parameters: ["label_id": label.id ?? "", "label_name": label.name ?? ""])
        case .additionalNotes: Analytics.logEvent("view_label_additional_notes", parameters: ["label_id": label.id ?? "", "label_name": label.name ?? ""])
        case .links: Analytics.logEvent("view_label_links", parameters: ["label_id": label.id ?? "", "label_name": label.name ?? ""])
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

// MARK: - Rosters
extension LabelDetailViewController {
    private func currentOrLastKnownRosterTableViewCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let label = label else {
            return UITableViewCell()
        }
        
        if label.currentRosterPagableManager.moreToLoad && indexPath.row == label.currentRosterPagableManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            label.currentRosterPagableManager.fetch()
            return loadingCell
        }
        
        let roster = label.currentRosterPagableManager.objects[indexPath.row]
        let cell = BandCurrentRosterTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.fill(with: roster)
        
        cell.tappedThumbnailImageView = { [unowned self] in
            self.presentPhotoViewerWithCacheChecking(photoUrlString: roster.imageURLString, description: roster.name, fromImageView: cell.thumbnailImageView)
            
            Analytics.logEvent("view_label_current_or_last_roster_thumbnail", parameters: ["label_id": label.id ?? "", "label_name": label.name ?? "", "roster_id": roster.id, "roster_name": roster.name])
        }
        
        return cell
    }
    
    private func didSelectCurrentOrLastKnownRosterTableViewCell(atIndexPath indexPath: IndexPath) {
        guard let label = label else { return }
        
        if label.currentRosterPagableManager.moreToLoad && indexPath.row == label.currentRosterPagableManager.objects.count {
            return
        }
        
        let roster = label.currentRosterPagableManager.objects[indexPath.row]
        pushBandDetailViewController(urlString: roster.urlString, animated: true)
        
        Analytics.logEvent("select_label_current_lastknown_roster", parameters: ["label_id": label.id ?? "", "label_name": label.name ?? "", "roster_id": roster.id, "roster_name": roster.name])
    }
    
    private func pastRosterTableViewCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let label = label else {
            return UITableViewCell()
        }
        
        if label.pastRosterPagableManager.moreToLoad && indexPath.row == label.pastRosterPagableManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            label.pastRosterPagableManager.fetch()
            return loadingCell
        }
        
        let pastRoster = label.pastRosterPagableManager.objects[indexPath.row]
        let cell = BandPastRosterTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.fill(with: pastRoster)
        
        cell.tappedThumbnailImageView = { [unowned self] in
            self.presentPhotoViewerWithCacheChecking(photoUrlString: pastRoster.imageURLString, description: pastRoster.name, fromImageView: cell.thumbnailImageView)
            
            Analytics.logEvent("view_label_past_roster_thumbnail", parameters: ["label_id": label.id ?? "", "label_name": label.name ?? "", "roster_id": pastRoster.id, "roster_name": pastRoster.name])
        }
        
        return cell
    }
    
    private func didSelectPastRosterTableViewCell(atIndexPath indexPath: IndexPath) {
        guard let label = label else { return }
        
        if label.pastRosterPagableManager.moreToLoad && indexPath.row == label.pastRosterPagableManager.objects.count {
            return
        }
        
        let pastRoster = label.pastRosterPagableManager.objects[indexPath.row]
        pushBandDetailViewController(urlString: pastRoster.urlString, animated: true)
        
        Analytics.logEvent("select_label_past_roster", parameters: ["label_id": label.id ?? "", "label_name": label.name ?? "", "past_roster_id": pastRoster.id, "past_roster_name": pastRoster.name])
    }
}

// MARK: - Additional Notes & Related Links
extension LabelDetailViewController {
    private func additionalNotesTableViewCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let label = label, let additionalNotes = label.additionalNotes else {
            return UITableViewCell()
        }
        
        let simpleCell = SimpleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        simpleCell.fill(with: additionalNotes)
        return simpleCell
    }
    
    private func relatedLinkTableViewCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let label = label, let links = label.links else {
            return UITableViewCell()
        }
        
        let cell = RelatedLinkTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.fill(with: links[indexPath.row])
        return cell
    }
    
    private func didSelectRelatedLinkTableViewCell(atIndexPath indexPath: IndexPath) {
        guard let label = label, let links = label.links else { return }
        
        let link = links[indexPath.row]
        presentAlertOpenURLInBrowsers(URL(string: link.urlString)!, alertTitle: "Open this link in browser", alertMessage: link.urlString, shareMessage: "Share this link")
        
        Analytics.logEvent("select_label_link", parameters: ["label_id": label.id ?? "", "label_name": label.name ?? "", "link_title": link.title, "link_url": link.urlString])
    }
}

// MARK: - Releases
extension LabelDetailViewController {
    private func releaseTableViewCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let label = label else {
            return UITableViewCell()
        }
        
        if label.releasesPagableManager.moreToLoad && indexPath.row == label.releasesPagableManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            label.releasesPagableManager.fetch()
            return loadingCell
        }
        
        let release = label.releasesPagableManager.objects[indexPath.row]
        let cell = ReleaseInLabelTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.fill(with: release)
        
        cell.tappedThumbnailImageView = { [unowned self] in
            self.presentPhotoViewerWithCacheChecking(photoUrlString: release.imageURLString, description: release.release.title, fromImageView: cell.thumbnailImageView)
            
            Analytics.logEvent("view_label_release_thumbnail", parameters: ["label_id": label.id ?? "", "label_name": label.name ?? "", "release_id": release.id, "release_name": release.release.title])
        }
        
        return cell
    }
    
    private func didSelectReleaseTableViewCell(atIndexPath indexPath: IndexPath) {
        guard let label = label else { return }
        
        if label.releasesPagableManager.moreToLoad && indexPath.row == label.releasesPagableManager.objects.count {
            return
        }
        
        let release = label.releasesPagableManager.objects[indexPath.row]
        takeActionFor(actionableObject: release)
        
        Analytics.logEvent("select_label_release", parameters: ["label_id": label.id ?? "", "label_name": label.name ?? "", "release_id": release.id, "release_title": release.release.title])
    }
}

//MARK: - PagableManagerProtocol
extension LabelDetailViewController: PagableManagerDelegate {
    func pagableManagerDidFailFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        Toast.displayMessageShortly(errorLoadingMessage)
    }
    
    func pagableManagerDidFinishFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        self.tableView.reloadSections([1], with: .automatic)
    }
    
    func pagableManagerIsBeingBlocked<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        Toast.displayBlockedMessageWithDelay()
    }
}
