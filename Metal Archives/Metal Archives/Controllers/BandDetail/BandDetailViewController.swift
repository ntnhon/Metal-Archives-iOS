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

//MARK: - Properties
final class BandDetailViewController: RefreshableViewController {
    var bandURLString: String!

    private var band: Band!
    private var currentDiscographyType: DiscographyType = UserDefaults.selectedDiscographyType()
    private var currentMembersType: MembersType?
    private var availableMembersType: [MembersType]!
    private var lineUpHeaderCell: LineUpHeaderTableViewCell!
    
    private var bandParameters: [String : Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reloadBand()
        self.addShareBarButton()
    }
    
    override func initAppearance() {
        super.initAppearance()
        //Hide 1st header
        self.tableView.contentInset = UIEdgeInsets(top: -CGFloat.leastNormalMagnitude, left: 0, bottom: 0, right: 0)
        
        BandHeaderDetailTableViewCell.register(with: self.tableView)
        DiscographyHeaderTableViewCell.register(with: self.tableView)
        ReleaseTableViewCell.register(with: self.tableView)
        LineUpHeaderTableViewCell.register(with: self.tableView)
        MemberTableViewCell.register(with: self.tableView)
        ReviewTableViewCell.register(with: self.tableView)
        ViewMoreTableViewCell.register(with: self.tableView)
        SimilarBandTableViewCell.register(with: self.tableView)
        RelatedLinkTableViewCell.register(with: self.tableView)
        SimpleTableViewCell.register(with: self.tableView)
    }
    
    override func refresh() {
        self.currentDiscographyType = .complete
        self.currentMembersType = .complete
        self.numberOfTries = 0
        self.removeShareBarButton()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.reloadBand()
        }
        
        Analytics.logEvent(AnalyticsEvent.RefreshBand, parameters: nil)
    }
    
    private func reloadBand() {
        if self.numberOfTries == Settings.numberOfRetries {
            self.endRefreshing()
            Toast.displayMessageShortly("Error loading band. Please retry.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.navigationController?.popViewController(animated: true)
            }
            return
        }
        
        self.numberOfTries += 1
        self.removeShareBarButton()
        
        MetalArchivesAPI.reloadBand(bandURLString: self.bandURLString) { [weak self] (band, error) in
            if let _ = error {
                self?.reloadBand()
            } else if let `band` = band {
                self?.band = band
                self?.title = band.name
                self?.determineMembersTypeList()
                self?.addShareBarButton()
                self?.refreshSuccessfully()
                self?.tableView.reloadData()
                self?.bandParameters = [AnalyticsParameter.BandName: band.name, AnalyticsParameter.BandID: band.id, AnalyticsParameter.BandCountry: band.country.nameAndEmoji]
                
                Analytics.logEvent(AnalyticsEvent.ViewBand, parameters: self?.bandParameters)
                Crashlytics.sharedInstance().setObjectValue(self?.band, forKey: CrashlyticsKey.Band)
            }
        }
    }
    
    private func determineMembersTypeList() {
        //Check is array is nil or not to determine if a MembersType is available
        //"Complete Lineup" is only available when there are at least 2 available MembersType
        //Set "Current" or "Last known Lineup" as default display type
        
        self.availableMembersType = [MembersType]()
        if let currentLineup = band.currentLineup {
            if currentLineup.count > 0 {
                self.availableMembersType!.append(MembersType.current)
                self.currentMembersType = MembersType.current
            }
        }
        
        if let lastKnownLineup = band.lastKnownLineup {
            if lastKnownLineup.count > 0 {
                self.availableMembersType!.append(MembersType.lastKnown)
                self.currentMembersType = MembersType.lastKnown
            }
        }
        
        if let pastMembers = band.pastMembers {
            if pastMembers.count > 0 {
                self.availableMembersType!.append(MembersType.past)
            }
        }
        
        if let liveMusicians = band.liveMusicians {
            if liveMusicians.count > 0 {
                self.availableMembersType!.append(MembersType.live)
            }
        }
        
        if availableMembersType.count == 0 {
            self.currentMembersType = nil
            return
        }
        
        self.availableMembersType!.insert(MembersType.complete, at: 0)
        self.currentMembersType = self.availableMembersType[1]
    }
}

//MARK: - Share
extension BandDetailViewController {
    private func removeShareBarButton() {
        self.navigationItem.rightBarButtonItem = nil
    }
    
    private func addShareBarButton() {
        let shareBarButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapShareButton))
        self.navigationItem.rightBarButtonItem = shareBarButton
    }
    
    @objc private func didTapShareButton() {
        guard let `band` = self.band, let url = URL(string: band.urlString) else { return }
        
        self.presentAlertOpenURLInBrowsers(url, alertTitle: "View \(band.name!) in browser", alertMessage: band.urlString, shareMessage: "Share this band URL")
        
        Analytics.logEvent(AnalyticsEvent.ShareBand, parameters: self.bandParameters)
    }
}

//MARK: - UITableViewDelegate
extension BandDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //Hide 1st section header
        if section == 0 {
            return CGFloat.leastNormalMagnitude
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 530
        default: return 44
        }
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
        
        switch indexPath.section {
        case 0: return //Header
        case 1: self.didSelectRowInDiscographySection(at: indexPath)
        case 2: self.didSelectRowInLineUpSection(at: indexPath)
        case 3: self.didSelectRowInReviewsSection(at: indexPath)
        case 4: self.didSelectRowInSimilarArtistsSection(at: indexPath)
        case 5: self.didSelectRowInRelatedLinksSection(at: indexPath)
        default: return
        }
    }
}

//MARK: - UITableViewDatasource
extension BandDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if let _ = self.band {
            return 6
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            //Section HEADER
        case 0: return self.numberOfRowsInHeaderSection()
            //Section DISCOGRAPHY
        case 1: return self.numberOfRowsInDiscographySection()
            //Section LINEUP
        case 2: return self.numberOfRowsInLineUpSection()
            //Section REVIEWS
        case 3: return self.numberOfRowsInReviewsSection()
            //Section SIMILAR ARTISTS
        case 4: return self.numberOfRowsInSimilarArtistsSection()
            //Section RELATED LINKS
        case 5: return self.numberOfRowsInRelatedLinksSection()
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
            //Section HEADER
        case 0: return self.cellForBandHeaderSection(at: indexPath)
            //Section DISCOGRAPHY
        case 1: return self.cellForDiscographySection(at: indexPath)
            //Section LINEUP
        case 2: return self.cellForLineUpSection(at: indexPath)
            //Section REVIEWS
        case 3: return self.cellForReviewsSection(at: indexPath)
            //Section SIMILAR ARTISTS
        case 4: return self.cellForSimilarArtistsSection(at: indexPath)
            //Section RELATED LINKS
        case 5: return self.cellForRelatedLinksSection(at: indexPath)
        default: return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return nil //Header
        case 1: return "DISCOGRAPHY"
        case 2: return "MEMBERS"
        case 3: return "REVIEWS"
        case 4: return "SIMILAR ARTISTS"
        case 5: return "RELATED LINKS"
        default: return nil
        }
    }
}

//MARK: - No element & view more cell
extension BandDetailViewController {
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

//MARK: - Section HEADER
extension BandDetailViewController {
    private func numberOfRowsInHeaderSection() -> Int {
        return 1
    }
    
    private func cellForBandHeaderSection(at indexPath: IndexPath) -> BandHeaderDetailTableViewCell {
        let bandHeaderDetailCell = BandHeaderDetailTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        bandHeaderDetailCell.delegate = self
        bandHeaderDetailCell.fill(with: band)
        return bandHeaderDetailCell
    }
}

//MARK: - Section DISCOGRAPHY
extension BandDetailViewController {
    private func numberOfRowsInDiscographySection() -> Int {
        //Return plus 1 row for displaying discoraphy type row
        //In case there is no relase => 2 row: 1 for header, 1 for information
        if let discography = self.band?.discography {
            switch self.currentDiscographyType {
            case .complete:
                if discography.complete.count > 0 {
                    return discography.complete.count + 1
                }
                return 2
            case .main:
                if discography.main.count > 0 {
                    return discography.main.count + 1
                }
                return 2
            case .lives:
                if discography.lives.count > 0 {
                    return discography.lives.count + 1
                }
                return 2
            case .demos:
                if discography.demos.count > 0 {
                    return discography.demos.count + 1
                }
                return 2
            case .misc:
                if discography.misc.count > 0 {
                    return discography.misc.count + 1
                }
                return 2
            }
        }
        
        return 1
    }
    
    private func cellForDiscographySection(at indexPath: IndexPath) -> UITableViewCell {
        let noReleaseMessage = "Nothing entered yet. Please add the releases, if applicable."
        
        guard let discography = self.band?.discography else {
            return self.noElementCell(message: noReleaseMessage, at: indexPath)
        }
        
        //1st row - Header
        if indexPath.row == 0 {
            return self.discographyHeaderCell(at: indexPath)
        }
        
        //Check if there is no disc => display information
        switch self.currentDiscographyType {
        case .complete:
            if discography.complete.count == 0 {
                return noElementCell(message: noReleaseMessage, at: indexPath)
            }
        case .main:
            if discography.main.count == 0 {
                return noElementCell(message: noReleaseMessage, at: indexPath)
            }
        case .lives:
            if discography.lives.count == 0 {
                return noElementCell(message: noReleaseMessage, at: indexPath)
            }
        case .demos:
            if discography.demos.count == 0 {
                return noElementCell(message: noReleaseMessage, at: indexPath)
            }
        case .misc:
            if discography.misc.count == 0 {
                return noElementCell(message: noReleaseMessage, at: indexPath)
            }
        }
        
        return self.releaseCell(at: indexPath)
    }
    
    private func discographyHeaderCell(at indexPath: IndexPath) -> DiscographyHeaderTableViewCell {
        let discographyHeaderCell = DiscographyHeaderTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        discographyHeaderCell.delegate = self
        discographyHeaderCell.adjustSegmentControl(with: self.currentDiscographyType)
        return discographyHeaderCell
    }
    
    private func releaseCell(at indexPath: IndexPath) -> UITableViewCell {
        guard let discography = self.band?.discography else { return UITableViewCell() }
        var releases: [ReleaseLite] = []
        
        switch self.currentDiscographyType {
        case .complete: releases = discography.complete
        case .main: releases = discography.main
        case .lives: releases = discography.lives
        case .demos: releases = discography.demos
        case .misc: releases = discography.misc
        }
        
        let release = releases[indexPath.row - 1]
        
        
        let releaseCell = ReleaseTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        releaseCell.fill(with: release)
        
        return releaseCell
    }
    
    private func didSelectRowInDiscographySection(at indexPath: IndexPath) {
        let index = indexPath.row - 1
        var selectedRelease: ReleaseLite?
        
        switch self.currentDiscographyType {
        case .complete:
            if band.discography?.complete.count == 0 {
                return
            }
            selectedRelease = band.discography?.complete[index]
            
        case .main:
            if band.discography?.main.count == 0 {
                return
            }
            
            selectedRelease = band.discography?.main[index]
            
        case .lives:
            if band.discography?.lives.count == 0 {
                return
            }
            
            selectedRelease = band.discography?.lives[index]
            
        case .demos:
            if band.discography?.demos.count == 0 {
                return
            }
            
            selectedRelease = band.discography?.demos[index]
            
        case .misc:
            if band.discography?.misc.count == 0 {
                return
            }
            
            selectedRelease = band.discography?.misc[index]
        }
        
        if let `selectedRelease` = selectedRelease {
            Analytics.logEvent(AnalyticsEvent.ViewBandRelease, parameters: [AnalyticsParameter.BandName: band.name, AnalyticsParameter.BandID: band.id, AnalyticsParameter.BandCountry: band.country.nameAndEmoji, AnalyticsParameter.ReleaseTitle: selectedRelease.title, AnalyticsParameter.ReleaseID: selectedRelease.id])
            
            Crashlytics.sharedInstance().setObjectValue(selectedRelease, forKey: CrashlyticsKey.SelectedRelease)
            
            self.pushReleaseDetailViewController(urlString: selectedRelease.urlString, animated: true)
        }
    }
}

//MARK: - Section LINEUP
extension BandDetailViewController {
    private func numberOfRowsInLineUpSection() -> Int {
        guard let `currentMembersType` = self.currentMembersType else {
            return 1
        }
        //Return plus 1 row for displaying lineup type row
        switch currentMembersType {
        case .complete:
            if let completeLineup = self.band?.completeLineup {
                return completeLineup.count + 1
            }
            return 1
        case .current:
            if let currentLineup = self.band?.currentLineup {
                return currentLineup.count + 1
            }
            return 1
        case .lastKnown:
            if let lastKnownLineup = self.band?.lastKnownLineup {
                return lastKnownLineup.count + 1
            }
            return 1
        case .past:
            if let pastMembers = self.band?.pastMembers {
                return pastMembers.count + 1
            }
            return 1
        case .live:
            if let liveMusicians = self.band?.liveMusicians {
                return liveMusicians.count + 1
            }
            return 1
        }
    }
    
    private func cellForLineUpSection(at indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            if let band = band {
                if band.hasNoMember {
                    return self.noElementCell(message: "No member of this band were added. Please add the artist, if applicable.", at: indexPath)
                }
            }
            
            return lineUpHeaderCell(at: indexPath)
        }
        
        return self.memberCell(at: indexPath)
    }
    
    private func lineUpHeaderCell(at indexPath: IndexPath) -> UITableViewCell {
        guard let `lineUpHeaderCell` = self.lineUpHeaderCell else {
            let cell = LineUpHeaderTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
            
            cell.initSegmentControl(availableMembersTypes: availableMembersType)
            cell.delegate = self
            
            self.lineUpHeaderCell = cell
            return cell
        }
        
        return lineUpHeaderCell
    }
    
    private func memberCell(at indexPath: IndexPath) -> UITableViewCell {
        guard let `currentMembersType` = self.currentMembersType else {
            return UITableViewCell()
        }
        var member: ArtistLite?
        
        switch currentMembersType {
        case .complete: member = band.completeLineup![indexPath.row - 1]
        case .lastKnown: member = band.lastKnownLineup![indexPath.row - 1]
        case .current: member = band.currentLineup![indexPath.row - 1]
        case .past: member = band.pastMembers![indexPath.row - 1]
        case .live: member = band.liveMusicians![indexPath.row - 1]
        }
        
        let memberCell = MemberTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        if let `member` = member {
            memberCell.bind(with: member)
        }
        
        return memberCell
    }
    
    private func didSelectRowInLineUpSection(at indexPath: IndexPath) {
        guard let `currentMembersType` = self.currentMembersType else {
            return
        }
        
        var member: ArtistLite?
        
        switch currentMembersType {
        case .complete: member = band.completeLineup![indexPath.row - 1]
        case .lastKnown: member = band.lastKnownLineup![indexPath.row - 1]
        case .current: member = band.currentLineup![indexPath.row - 1]
        case .past: member = band.pastMembers![indexPath.row - 1]
        case .live: member = band.liveMusicians![indexPath.row - 1]
        }
        
        if let `member` = member {
            if let _ = member.bands {
                self.takeActionFor(actionableObject: member)
            } else {
                self.pushArtistDetailViewController(urlString: member.urlString, animated: true)
            }
            
            Analytics.logEvent(AnalyticsEvent.ViewBandArtist, parameters: [AnalyticsParameter.BandName: band.name, AnalyticsParameter.BandID: band.id, AnalyticsParameter.BandCountry: band.country.nameAndEmoji, AnalyticsParameter.ArtistName: member.name, AnalyticsParameter.ArtistID: member.id])
        }
    }
}

//MARK: - Section REVIEWS
extension BandDetailViewController {
    private func numberOfRowsInReviewsSection() -> Int {
        guard let reviews = band.reviews else {
            return 1
        }
        
        if reviews.count > Settings.shortListDisplayCount {
            return Settings.shortListDisplayCount + 1 //plus 1 row for "view more" cell
        }
        
        return reviews.count
    }
    
    private func cellForReviewsSection(at indexPath: IndexPath) -> UITableViewCell {
        guard let reviews = band.reviews else {
            return self.noElementCell(message: "This band has no reviews yet.", at: indexPath)
        }
        
        
        if indexPath.row == Settings.shortListDisplayCount {
            return self.viewMoreCell(message: "View all \(self.band.totalReviews!) reviews", at: indexPath)
        }
        
        let review = reviews[indexPath.row]
        let reviewCell = ReviewTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        reviewCell.fill(with: review)
        
        return reviewCell
    }
    
    private func didSelectRowInReviewsSection(at indexPath: IndexPath) {
        if let reviews = self.band.reviews {
            if indexPath.row == Settings.shortListDisplayCount {
                self.didSelectMoreReviews()
                return
            }
            
            let review = reviews[indexPath.row]
            self.presentReviewController(urlString: review.urlString, animated: true, completion: nil)
            
            Analytics.logEvent(AnalyticsEvent.ViewBandReview, parameters: self.bandParameters)
        }
    }
    
    private func didSelectMoreReviews() {
        let bandReviewListViewController = UIStoryboard(name: "BandDetail", bundle: nil).instantiateViewController(withIdentifier: "BandReviewListViewController") as! BandReviewListViewController
        bandReviewListViewController.band = band
        self.navigationController?.pushViewController(bandReviewListViewController, animated: true)
        
        Analytics.logEvent(AnalyticsEvent.ViewBandAllReviews, parameters: self.bandParameters)
    }
}

//MARK: - Section SIMILAR ARTISTS
extension BandDetailViewController {
    private func numberOfRowsInSimilarArtistsSection() -> Int {
        guard let similarArtists = band.similarArtists else {
            return 1
        }
        
        if similarArtists.count > Settings.shortListDisplayCount {
            return Settings.shortListDisplayCount + 1 //plus 1 row for "view more" cell
        }
        
        return similarArtists.count
    }
    
    private func cellForSimilarArtistsSection(at indexPath: IndexPath) -> UITableViewCell {
        guard let similarArtists = band.similarArtists else {
            return self.noElementCell(message: "No similar artist has been recommended yet.", at: indexPath)
        }
        
        if indexPath.row == Settings.shortListDisplayCount {
            return self.viewMoreCell(message: "View all \(similarArtists.count) similar artists", at: indexPath)
        }
        
        let similarBand = similarArtists[indexPath.row]
        let similarBandCell = SimilarBandTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        similarBandCell.bind(band: similarBand)
        
        return similarBandCell
    }
    
    private func didSelectRowInSimilarArtistsSection(at indexPath: IndexPath) {
        if let similarArtists = self.band.similarArtists {
            if indexPath.row == Settings.shortListDisplayCount {
                self.didSelectMoreSimilarArtists()
                return
            }
            
            let similarArtist = similarArtists[indexPath.row]
            self.pushBandDetailViewController(urlString: similarArtist.urlString, animated: true)
            
            Analytics.logEvent(AnalyticsEvent.ViewBandSimilarArtist, parameters: [AnalyticsParameter.BandName: band.name, AnalyticsParameter.BandID: band.id, AnalyticsParameter.BandCountry: band.country.nameAndEmoji, AnalyticsParameter.SimilarBandName: similarArtist.name, AnalyticsParameter.SimilarBandID: similarArtist.id])
        }
    }
    
    private func didSelectMoreSimilarArtists() {
        let bandSimilarArtistListViewController = UIStoryboard(name: "BandDetail", bundle: nil).instantiateViewController(withIdentifier: "BandSimilarArtistListViewController") as! BandSimilarArtistListViewController
        bandSimilarArtistListViewController.similarArtists = band.similarArtists
        self.navigationController?.pushViewController(bandSimilarArtistListViewController, animated: true)
        
        Analytics.logEvent(AnalyticsEvent.ViewBandAllSimilarArtists, parameters: self.bandParameters)
    }
}

//MARK: - Section RELATED LINKS
extension BandDetailViewController {
    private func numberOfRowsInRelatedLinksSection() -> Int {
        guard let relatedLinks = band.relatedLinks else {
            return 1
        }
        
        if relatedLinks.count > Settings.shortListDisplayCount {
            return Settings.shortListDisplayCount + 1 //plus 1 row for "view more" cell
        }
        
        return relatedLinks.count
    }
    
    private func cellForRelatedLinksSection(at indexPath: IndexPath) -> UITableViewCell {
        guard let relatedLinks = band.relatedLinks else {
            return self.noElementCell(message: "No available related links.", at: indexPath)
        }
        
        if indexPath.row == Settings.shortListDisplayCount {
            return self.viewMoreCell(message: "View all \(self.band.relatedLinks!.count) links", at: indexPath)
        }
        
        let relatedLink = relatedLinks[indexPath.row]
        let relatedLinkCell = RelatedLinkTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        relatedLinkCell.bind(relatedLink: relatedLink)
        
        return relatedLinkCell
    }
    
    private func didSelectRowInRelatedLinksSection(at indexPath: IndexPath) {
        if let relatedLinks = self.band.relatedLinks {
            if indexPath.row == Settings.shortListDisplayCount {
                self.didSelectMoreRelatedLinks()
                return
            }
            
            let relatedLink = relatedLinks[indexPath.row]
            
            self.presentAlertOpenURLInBrowsers(URL(string: relatedLink.urlString)!, alertTitle: "Open this link in browser", alertMessage: relatedLink.urlString, shareMessage: "Share this link")
            
            Analytics.logEvent(AnalyticsEvent.ViewBandLink, parameters: [AnalyticsParameter.BandName: band.name, AnalyticsParameter.BandID: band.id, AnalyticsParameter.BandCountry: band.country.nameAndEmoji, AnalyticsParameter.LinkTitle: relatedLink.title])
        }
    }
    
    private func didSelectMoreRelatedLinks() {
        guard let relatedLinks = self.band.relatedLinks else { return }
        self.pushRelatedLinkListViewController(relatedLinks, animated: true)
        
        Analytics.logEvent(AnalyticsEvent.ViewBandAllLinks, parameters: self.bandParameters)
    }
}

//MARK: - BandHeaderDetailTableViewCellDelegate
extension BandDetailViewController: BandHeaderDetailTableViewCellDelegate {
    func didTapBandLogo() {
        if let bandLogoURLString = self.band?.logoURLString, let bandName = self.band?.name {
            self.presentPhotoViewer(photoURLString: bandLogoURLString, description: bandName)
            
            Analytics.logEvent(AnalyticsEvent.ViewBandLogo, parameters: self.bandParameters)
        }
    }
    
    func didTapBandPhoto() {
        if let bandPhotoURLString = self.band?.photoURLString, let bandName = self.band?.name  {
            self.presentPhotoViewer(photoURLString: bandPhotoURLString, description: bandName)
            
            Analytics.logEvent(AnalyticsEvent.ViewBandPhoto, parameters: self.bandParameters)
        }
    }
    
    func didTapBandAbout() {
        if let readMoreString = self.band?.completeHTMLDescription, let bandName = self.band?.name {
            let readMoreViewController = UIStoryboard(name: "ReadMore", bundle: nil).instantiateViewController(withIdentifier: "ReadMoreViewController" ) as! ReadMoreViewController
            readMoreViewController.title = bandName
            readMoreViewController.readMoreString = readMoreString
            self.present(readMoreViewController, animated: true, completion: nil)
            
            Analytics.logEvent(AnalyticsEvent.ViewBandAbout, parameters: self.bandParameters)
        }
    }
    
    func didTapLastModifiedOn() {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        
        Analytics.logEvent(AnalyticsEvent.ViewBandLastModifiedDate, parameters: self.bandParameters)
    }
    
    func didTapYearsActive() {
        guard let oldBands = self.band.oldBands else { return }
        
        if oldBands.count == 1 {
            let oldBand = oldBands[0]
            self.pushBandDetailViewController(urlString: oldBand.urlString, animated: true)
            
        } else {
            var alertController: UIAlertController!
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                alertController = UIAlertController(title: "View \(self.band.name!)'s old bands", message: nil, preferredStyle: .alert)
            } else {
                alertController = UIAlertController(title: "View \(self.band.name!)'s old bands", message: nil, preferredStyle: .actionSheet)
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
        
        Analytics.logEvent(AnalyticsEvent.ViewBandOldNames, parameters: self.bandParameters)
    }
    
    func didTapLastLabelLabel() {
        
        if let lastLabelURLString = self.band.lastLabel.urlString {
            self.pushLabelDetailViewController(urlString: lastLabelURLString, animated: true)
        
            Analytics.logEvent(AnalyticsEvent.ViewBandLastLabel, parameters: [AnalyticsParameter.BandName: band.name, AnalyticsParameter.BandID: band.id, AnalyticsParameter.BandCountry: band.country.nameAndEmoji, AnalyticsParameter.LabelName: self.band.lastLabel.name])
        }
    }
}

//MARK: - DiscographyHeaderTableViewCellDelegate
extension BandDetailViewController: DiscographyHeaderTableViewCellDelegate {
    func discographyTypeChanged(_ discographyType: DiscographyType) {
        self.currentDiscographyType = discographyType
        self.tableView.beginUpdates()
        self.tableView.reloadSections([1], with: .none)
        self.tableView.endUpdates()
        
        Analytics.logEvent(AnalyticsEvent.ChangeDiscographyType, parameters: [AnalyticsParameter.BandName: band.name, AnalyticsParameter.BandID: band.id, AnalyticsParameter.BandCountry: band.country.nameAndEmoji, AnalyticsParameter.DiscographyType: self.currentDiscographyType.description])
        
        Crashlytics.sharedInstance().setObjectValue(discographyType.description, forKey: CrashlyticsKey.DiscographyMode)
    }
}

//MARK: - MembersHeaderTableViewCellDelegate
extension BandDetailViewController: MembersHeaderTableViewCellDelegate {
    func membersTypeChanged(_ membersTypeIndex: Int) {
        guard let availableMembersType = self.availableMembersType else { return }
        self.currentMembersType = availableMembersType[membersTypeIndex]
        self.tableView.beginUpdates()
        self.tableView.reloadSections([2], with: .none)
        self.tableView.endUpdates()
        
        Analytics.logEvent(AnalyticsEvent.ChangeMemberType, parameters: [AnalyticsParameter.BandName: band.name, AnalyticsParameter.BandID: band.id, AnalyticsParameter.BandCountry: band.country.nameAndEmoji, AnalyticsParameter.MemberType: self.currentMembersType!.description])
        
        Crashlytics.sharedInstance().setObjectValue(self.currentMembersType?.description, forKey: CrashlyticsKey.MemberType)
    }
}
