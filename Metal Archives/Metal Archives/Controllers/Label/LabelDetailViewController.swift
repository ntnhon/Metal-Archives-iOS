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

final class LabelDetailViewController: RefreshableViewController {
    
    var urlString: String!
    
    private var label: Label!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reloadLabel()
    }
    
    override func initAppearance() {
        super.initAppearance()
        //Hide 1st header
        self.tableView.contentInset = UIEdgeInsets(top: -CGFloat.leastNormalMagnitude, left: 0, bottom: 0, right: 0)
        
        SimpleTableViewCell.register(with: self.tableView)
        ViewMoreTableViewCell.register(with: self.tableView)
        LabelHeaderTableViewCell.register(with: self.tableView)
        RelatedLinkTableViewCell.register(with: self.tableView)
        SubLabelTableViewCell.register(with: self.tableView)
        BandCurrentRosterTableViewCell.register(with: self.tableView)
        BandPastRosterTableViewCell.register(with: self.tableView)
        ReleaseInLabelTableViewCell.register(with: self.tableView)
    }
    
    override func refresh() {
        self.numberOfTries = 0
        self.removeShareBarButton()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.reloadLabel()
        }
        
        Analytics.logEvent(AnalyticsEvent.RefreshLabel, parameters: nil)
    }
    
    private func reloadLabel() {
        if self.numberOfTries == Settings.numberOfRetries {
            //Dimiss controller
            self.endRefreshing()
            Toast.displayMessageShortly("Error loading label. Please retry.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.navigationController?.popViewController(animated: true)
            }
            return
        }
        
        self.numberOfTries += 1
        self.removeShareBarButton()
        
        MetalArchivesAPI.reloadLabel(urlString: self.urlString) { [weak self] (label, error) in
            if let _ = error {
                self?.reloadLabel()
            } else if let `label` = label {
                DispatchQueue.main.async {
                    self?.label = label
                    self?.title = label.name
                    self?.addShareBarButton()
                    self?.refreshSuccessfully()
                    self?.tableView.reloadData()
                }
                
                Analytics.logEvent(AnalyticsEvent.ViewLabel, parameters: [AnalyticsParameter.LabelName: label.name, AnalyticsParameter.LabelID: label.id])
            }
        }
    }
}
//MARK: - Segues
extension LabelDetailViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let sublabelListViewController as SublabelListViewController:
            sublabelListViewController.sublabels = self.label.subLabels
            sublabelListViewController.parentLabelName = self.label.name
            
        case let currentRosterListViewController as CurrentRosterListViewController:
            currentRosterListViewController.currentRosterPagableManager = self.label.currentRosterPagableManager.copy() as? PagableManager<BandCurrentRoster>
            if self.label.isLastKnown {
                currentRosterListViewController.type = .lastKnown
            } else {
                currentRosterListViewController.type = .current
            }
            currentRosterListViewController.labelName = self.label.name
            
        case let pastRosterListViewController as PastRosterListViewController:
            pastRosterListViewController.pastRosterPagableManager = self.label.pastRosterPagableManager.copy() as? PagableManager<BandPastRoster>
            pastRosterListViewController.labelName = self.label.name
            
        case let releaseInLabelListViewController as ReleaseInLabelListViewController:
            releaseInLabelListViewController.releaseInLabelPagableManager = self.label.releasesPagableManager.copy() as? PagableManager<ReleaseInLabel>
            releaseInLabelListViewController.labelName = self.label.name
            
        default:
            break
        }
    }
}

//MARK: - Share
extension LabelDetailViewController {
    private func removeShareBarButton() {
        self.navigationItem.rightBarButtonItem = nil
    }
    
    private func addShareBarButton() {
        let shareBarButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapShareButton))
        self.navigationItem.rightBarButtonItem = shareBarButton
    }
    
    @objc private func didTapShareButton() {
        guard let `label` = self.label, let url = URL(string: label.urlString) else { return }
        
        self.presentAlertOpenURLInBrowsers(url, alertTitle: "View \(label.name!) in browser", alertMessage: label.urlString, shareMessage: "Share this label URL")
        
        Analytics.logEvent(AnalyticsEvent.ShareLabel, parameters: [AnalyticsParameter.LabelName: label.name, AnalyticsParameter.LabelID: label.id])
    }
}

//MARK: - No element & view more cell
extension LabelDetailViewController {
    private func noElementCell(message: String, at indexPath: IndexPath) -> SimpleTableViewCell {
        let noElementCell = SimpleTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        noElementCell.fill(with: message)
        return noElementCell
    }
    
    private func viewMoreCell(message: String, at indexPath: IndexPath) -> UITableViewCell {
        let cell = ViewMoreTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        cell.fill(message: message)
        return cell
    }
}

//MARK: - UITableViewDelegate
extension LabelDetailViewController: UITableViewDelegate {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let _ = self.label.subLabels {
            switch indexPath.section {
            case 0: return
            case 1: self.didSelectRowInSublabelsSection(at: indexPath)
            case 2: self.didSelectRowInCurrentRosterSection(at: indexPath)
            case 3: self.didSelectRowInPastRosterSection(at: indexPath)
            case 4: self.didSelectRowInReleasesSection(at: indexPath)
            case 5: self.didSelectRowInLinksSection(at: indexPath)
            default: return
            }
        } else {
            switch indexPath.section {
            case 0: return
            case 1: self.didSelectRowInCurrentRosterSection(at: indexPath)
            case 2: self.didSelectRowInPastRosterSection(at: indexPath)
            case 3: self.didSelectRowInReleasesSection(at: indexPath)
            case 4: self.didSelectRowInLinksSection(at: indexPath)
            default: return
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let _ = self.label.subLabels {
            switch section {
            case 0: return nil
            case 1: return "Sub-labels"
            case 2:
                if self.label.isLastKnown {
                    return "Last Known Roster"
                } else {
                    return "Current Roster"
                }
            case 3: return "Past Roster"
            case 4: return "Releases"
            case 5: return "Links"
            default: return nil
            }
        } else {
            switch section {
            case 0: return nil
            case 1:
                if self.label.isLastKnown {
                    return "Last Known Roster"
                } else {
                    return "Current Roster"
                }
            case 2: return "Past Roster"
            case 3: return "Releases"
            case 4: return "Links"
            default: return nil
            }
        }
    }
}

//MARK: - UITableViewDatasource
extension LabelDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let label = self.label else { return 0 }
        
        if let _ = label.subLabels {
            return 6
        } else {
            return 5
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _ = self.label.subLabels {
            switch section {
            case 0: return self.numberOfRowsInHeaderSection()
            case 1: return self.numberOfRowsInSublabelsSection()
            case 2: return self.numberOfRowsInCurrentRosterSection()
            case 3: return self.numberOfRowsInPastRosterSection()
            case 4: return self.numberOfRowsInReleasesSection()
            case 5: return self.numberOfRowsInLinksSection()
            default: return 0
            }
        } else {
            switch section {
            case 0: return self.numberOfRowsInHeaderSection()
            case 1: return self.numberOfRowsInCurrentRosterSection()
            case 2: return self.numberOfRowsInPastRosterSection()
            case 3: return self.numberOfRowsInReleasesSection()
            case 4: return self.numberOfRowsInLinksSection()
            default: return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let _ = self.label.subLabels {
            switch indexPath.section {
            case 0: return self.cellForHeaderSection(at: indexPath)
            case 1: return self.cellForSublabelsSection(at: indexPath)
            case 2: return self.cellForCurrentRosterSection(at: indexPath)
            case 3: return self.cellForPastRosterSection(at: indexPath)
            case 4: return self.cellForRowInReleasesSection(at: indexPath)
            case 5: return self.cellForRowInLinksSection(at: indexPath)
            default: return UITableViewCell()
            }
        } else {
            switch indexPath.section {
            case 0: return self.cellForHeaderSection(at: indexPath)
            case 1: return self.cellForCurrentRosterSection(at: indexPath)
            case 2: return self.cellForPastRosterSection(at: indexPath)
            case 3: return self.cellForRowInReleasesSection(at: indexPath)
            case 4: return self.cellForRowInLinksSection(at: indexPath)
            default: return UITableViewCell()
            }
        }
    }
}

//MARK: - Section Header
extension LabelDetailViewController {
    private func numberOfRowsInHeaderSection() -> Int {
        return 1
    }
    
    private func cellForHeaderSection(at indexPath: IndexPath) -> UITableViewCell {
        let cell = LabelHeaderTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        cell.fill(with: self.label)
        cell.delegate = self
        return cell
    }
}

//MARK: - Section Sub-labels
extension LabelDetailViewController {
    private func numberOfRowsInSublabelsSection() -> Int {
        guard let subLabels = self.label.subLabels else {
            return 0
        }
        
        if subLabels.count > Settings.shortListDisplayCount {
            return Settings.shortListDisplayCount + 1
        } else {
            return subLabels.count
        }
    }
    
    private func cellForSublabelsSection(at indexPath: IndexPath) -> UITableViewCell {
        guard let subLabels = self.label.subLabels else {
            return self.noElementCell(message: "No sub-labels.", at: indexPath)
        }
        
        if indexPath.row == Settings.shortListDisplayCount {
            return self.viewMoreCell(message: "View all \(subLabels.count) sub-labels", at: indexPath)
        }
        
        let cell = SubLabelTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        let subLabel = subLabels[indexPath.row]
        cell.fill(with: subLabel)
        
        return cell
    }
    
    private func didSelectRowInSublabelsSection(at indexPath: IndexPath) {
        guard let subLabels = self.label.subLabels else { return }
        if indexPath.row == Settings.shortListDisplayCount {
            self.didSelectViewMoreSublabels()
            return
        }
        
        let subLabel = subLabels[indexPath.row]
        self.pushLabelDetailViewController(urlString: subLabel.urlString, animated: true)
        
        Analytics.logEvent(AnalyticsEvent.ViewLabelSubLabel, parameters: [AnalyticsParameter.LabelName: label.name, AnalyticsParameter.LabelID: label.id])
    }
    
    private func didSelectViewMoreSublabels() {
        self.performSegue(withIdentifier: "ShowSubLabelList", sender: nil)
        
        Analytics.logEvent(AnalyticsEvent.ViewLabelAllSubLabels, parameters: [AnalyticsParameter.LabelName: label.name, AnalyticsParameter.LabelID: label.id])
    }
}

//MARK: - Section Current/Last Known Roster
extension LabelDetailViewController {
    private func numberOfRowsInCurrentRosterSection() -> Int {
        if self.label.currentRosterPagableManager.objects.count == 0 {
            return 1
        }
        
        if self.label.currentRosterPagableManager.objects.count > Settings.shortListDisplayCount {
            return Settings.shortListDisplayCount + 1
        } else {
            
            if self.label.currentRosterPagableManager.objects.count == 0 {
                return 1
            }
            
            return self.label.currentRosterPagableManager.objects.count
        }
    }
    
    private func cellForCurrentRosterSection(at indexPath: IndexPath) -> UITableViewCell {
        if self.label.currentRosterPagableManager.objects.count == 0 && indexPath.row == 0 {
            return self.noElementCell(message: "No bands are currently signed on this label.", at: indexPath)
        }
        
        if self.label.currentRosterPagableManager.objects.count > Settings.shortListDisplayCount && indexPath.row == Settings.shortListDisplayCount {
            if let totalRecord = self.label.currentRosterPagableManager.totalRecords {
                return self.viewMoreCell(message: "View all \(totalRecord) bands", at: indexPath)
            }
            return self.viewMoreCell(message: "View all bands", at: indexPath)
        }
        
        let cell = BandCurrentRosterTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        let band = self.label.currentRosterPagableManager.objects[indexPath.row]
        cell.fill(with: band)
        
        return cell
    }
    
    private func didSelectRowInCurrentRosterSection(at indexPath: IndexPath) {
        if self.label.currentRosterPagableManager.objects.count > 0 && indexPath.row == Settings.shortListDisplayCount {
            self.didSelectViewMoreCurrentRoster()
            return
        }
        
        let band = self.label.currentRosterPagableManager.objects[indexPath.row]
        self.pushBandDetailViewController(urlString: band.urlString, animated: true)
        
        Analytics.logEvent(AnalyticsEvent.ViewLabelCurrentRoster, parameters: [AnalyticsParameter.LabelName: label.name, AnalyticsParameter.LabelID: label.id])
    }
    
    private func didSelectViewMoreCurrentRoster() {
        self.performSegue(withIdentifier: "ShowCurrentRoster", sender: nil)
        
        Analytics.logEvent(AnalyticsEvent.ViewLabelAllCurrentRosters, parameters: [AnalyticsParameter.LabelName: label.name, AnalyticsParameter.LabelID: label.id])
    }
}

//MARK: - Section Past Roster
extension LabelDetailViewController {
    private func numberOfRowsInPastRosterSection() -> Int {
        if self.label.pastRosterPagableManager.objects.count > Settings.shortListDisplayCount {
            return Settings.shortListDisplayCount + 1
        } else {
            if self.label.pastRosterPagableManager.objects.count == 0 {
                return 1
            }
            
            return self.label.pastRosterPagableManager.objects.count
        }
    }
    
    private func cellForPastRosterSection(at indexPath: IndexPath) -> UITableViewCell {
        if self.label.pastRosterPagableManager.objects.count == 0 && indexPath.row == 0 {
            return self.noElementCell(message: "No records to display.", at: indexPath)
        }
        
        if self.label.pastRosterPagableManager.objects.count > Settings.shortListDisplayCount && indexPath.row == Settings.shortListDisplayCount {
            if let totalRecord = self.label.pastRosterPagableManager.totalRecords {
                return self.viewMoreCell(message: "View all \(totalRecord) bands", at: indexPath)
            }
            return self.viewMoreCell(message: "View all bands", at: indexPath)
        }
        
        let cell = BandPastRosterTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        let band = self.label.pastRosterPagableManager.objects[indexPath.row]
        cell.fill(with: band)
        
        return cell
    }
    
    private func didSelectRowInPastRosterSection(at indexPath: IndexPath) {
        if self.label.pastRosterPagableManager.objects.count > 0 && indexPath.row == Settings.shortListDisplayCount {
            self.didSelectViewMorePastRoster()
            return
        }
        
        let band = self.label.pastRosterPagableManager.objects[indexPath.row]
        self.pushBandDetailViewController(urlString: band.urlString, animated: true)
        
        Analytics.logEvent(AnalyticsEvent.ViewLabelPastRoster, parameters: [AnalyticsParameter.LabelName: label.name, AnalyticsParameter.LabelID: label.id])
    }
    
    private func didSelectViewMorePastRoster() {
        self.performSegue(withIdentifier: "ShowPastRoster", sender: nil)
        
        Analytics.logEvent(AnalyticsEvent.ViewLabelAllPastRosters, parameters: [AnalyticsParameter.LabelName: label.name, AnalyticsParameter.LabelID: label.id])
    }
}

//MARK: - Section Releases
extension LabelDetailViewController {
    private func numberOfRowsInReleasesSection() -> Int {
        if self.label.releasesPagableManager.objects.count > Settings.shortListDisplayCount {
            return Settings.shortListDisplayCount + 1
        } else {
            if self.label.releasesPagableManager.objects.count == 0 {
                return 1
            }
            
            return self.label.releasesPagableManager.objects.count
        }
    }
    
    private func cellForRowInReleasesSection(at indexPath: IndexPath) -> UITableViewCell {
        if self.label.releasesPagableManager.objects.count == 0 && indexPath.row == 0 {
            return self.noElementCell(message: "No records to display.", at: indexPath)
        }
        
        if self.label.releasesPagableManager.objects.count > Settings.shortListDisplayCount && indexPath.row == Settings.shortListDisplayCount {
            if let totalRecord = self.label.releasesPagableManager.totalRecords {
                return self.viewMoreCell(message: "View all \(totalRecord) releases", at: indexPath)
            }
            return self.viewMoreCell(message: "View all releases", at: indexPath)
        }
        
        let cell = ReleaseInLabelTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        let release = self.label.releasesPagableManager.objects[indexPath.row]
        cell.fill(with: release)
        
        return cell
    }
    
    private func didSelectRowInReleasesSection(at indexPath: IndexPath) {
        if self.label.releasesPagableManager.objects.count > 0 && indexPath.row == Settings.shortListDisplayCount {
            self.didSelectViewMoreReleases()
            return
        }
        
        let release = self.label.releasesPagableManager.objects[indexPath.row]
        self.takeActionFor(actionableObject: release)
        
        Analytics.logEvent(AnalyticsEvent.ViewLabelRelease, parameters: [AnalyticsParameter.LabelName: label.name, AnalyticsParameter.LabelID: label.id])
    }
    
    private func didSelectViewMoreReleases() {
        self.performSegue(withIdentifier: "ShowReleasesInLabel", sender: nil)
        
        Analytics.logEvent(AnalyticsEvent.ViewLabelAllReleases, parameters: [AnalyticsParameter.LabelName: label.name, AnalyticsParameter.LabelID: label.id])
    }
}

//MARK: - Section Links
extension LabelDetailViewController {
    private func numberOfRowsInLinksSection() -> Int {
        guard let links = self.label.links else {
            return 1
        }
        
        if links.count > Settings.shortListDisplayCount {
            return Settings.shortListDisplayCount + 1
        }
        
        return links.count
    }
    
    private func cellForRowInLinksSection(at indexPath: IndexPath) -> UITableViewCell {
        guard let links = self.label.links else {
            return self.noElementCell(message: "No links available.", at: indexPath)
        }
        
        if links.count > Settings.shortListDisplayCount && indexPath.row == Settings.shortListDisplayCount {
            return self.viewMoreCell(message: "View all \(links.count) links", at: indexPath)
        }
        
        let cell = RelatedLinkTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        let link = links[indexPath.row]
        cell.fill(with: link)
        
        return cell
    }
    
    private func didSelectRowInLinksSection(at indexPath: IndexPath) {
        guard let links = self.label.links else { return }
        
        if links.count > Settings.shortListDisplayCount && indexPath.row == Settings.shortListDisplayCount {
            self.didSelectViewMoreLinks()
            return
        }
        
        let link = links[indexPath.row]
        self.presentAlertOpenURLInBrowsers(URL(string: link.urlString)!, alertTitle: "Open this link in browser", alertMessage: link.urlString, shareMessage: "Share this link")
        
        Analytics.logEvent(AnalyticsEvent.ViewLabelLink, parameters: [AnalyticsParameter.LabelName: label.name, AnalyticsParameter.LabelID: label.id])
    }
    
    private func didSelectViewMoreLinks() {
        guard let links = self.label.links else { return }
        
        self.pushRelatedLinkListViewController(links, animated: true)
        
        Analytics.logEvent(AnalyticsEvent.ViewLabelAllLinks, parameters: [AnalyticsParameter.LabelName: label.name, AnalyticsParameter.LabelID: label.id])
    }
}

//MARK: - LabelHeaderTableViewCellDelegate
extension LabelDetailViewController: LabelHeaderTableViewCellDelegate {
    func didTapLogo() {
        guard let logoURLString = self.label.logoURLString else { return }
        self.presentPhotoViewer(photoURLString: logoURLString, description: self.label.name)
        
        Analytics.logEvent(AnalyticsEvent.ViewLabelLogo, parameters: [AnalyticsParameter.LabelName: label.name, AnalyticsParameter.LabelID: label.id])
    }
    
    func didTapParentLabel() {
        guard let parentLabel = self.label.parentLabel else { return }
        self.pushLabelDetailViewController(urlString: parentLabel.urlString, animated: true)
        
        Analytics.logEvent(AnalyticsEvent.ViewLabelParentLabel, parameters: [AnalyticsParameter.LabelName: label.name, AnalyticsParameter.LabelID: label.id])
    }
    
    func didTapWebsite() {
        guard let website = self.label.website, let url = URL(string: website.urlString) else {
            return
        }
        
        self.presentAlertOpenURLInBrowsers(url, alertTitle: "Open this link in browser", alertMessage: website.urlString, shareMessage: "Share this link")
        
        Analytics.logEvent(AnalyticsEvent.ViewLabelWebsite, parameters: [AnalyticsParameter.LabelName: label.name, AnalyticsParameter.LabelID: label.id])
    }
    
    func didTapLastModifiedOn() {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        
        Analytics.logEvent(AnalyticsEvent.ViewLabelLastModifiedDate, parameters: [AnalyticsParameter.LabelName: label.name, AnalyticsParameter.LabelID: label.id])
    }
}
