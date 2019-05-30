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

final class ArtistDetailViewController: RefreshableViewController {
    var urlString: String!
    private var artist: Artist!
    
    private var artistInfoTypes: [ArtistInfoType]!
    
    private var activeBandsRoles: [Any]!
    private var pastBandsRoles: [Any]!
    private var liveRoles: [Any]!
    private var guestSessionRoles: [Any]!
    private var miscStaffRoles: [Any]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reloadArtist()
    }
    
    override func initAppearance() {
        super.initAppearance()        //Hide 1st header
        self.tableView.contentInset = UIEdgeInsets(top: -CGFloat.leastNormalMagnitude, left: 0, bottom: 0, right: 0)
        
        ArtistHeaderTableViewCell.register(with: self.tableView)
        SimpleTableViewCell.register(with: self.tableView)
        RelatedLinkTableViewCell.register(with: self.tableView)
        RolesInBandTableViewCell.register(with: self.tableView)
        RolesInReleaseTableViewCell.register(with: self.tableView)
    }
    
    override func refresh() {
        self.numberOfTries = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.reloadArtist()
        }
        
        Analytics.logEvent(AnalyticsEvent.RefreshArtist, parameters: nil)
    }
    
    private func reloadArtist() {
        
        if self.numberOfTries == Settings.numberOfRetries {
            //Dimiss controller
            self.endRefreshing()
            Toast.displayMessageShortly("Error loading artist. Please retry.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.navigationController?.popViewController(animated: true)
            }
            return
        }
        
        self.numberOfTries += 1
        self.removeShareBarButton()
        
        MetalArchivesAPI.reloadArtist(urlString: urlString) { [weak self] (artist, error) in
            if let _ = error {
                self?.reloadArtist()
            } else {
                if let `artist` = artist {
                    DispatchQueue.main.async {
                        self?.artist = artist
                        self?.title = artist.bandMemberName
                        self?.addShareBarButton()
                        self?.determineArtistInfoTypes()
                        self?.determineArtistRoles()
                        self?.refreshSuccessfully()
                        self?.tableView.reloadData()
                        
                        Analytics.logEvent(AnalyticsEvent.ViewArtist, parameters: [AnalyticsParameter.ArtistName: artist.bandMemberName, AnalyticsParameter.ArtistID: artist.id])
                    }
                }
            }
        }
    }
    
    private func determineArtistInfoTypes() {
        self.artistInfoTypes = [ArtistInfoType]()
        if let _ = self.artist.trivia {
            self.artistInfoTypes.append(.trivia)
        }
        
        if let _ = self.artist.pastBands {
            self.artistInfoTypes.append(.pastBands)
        }
        
        if let _ = self.artist.activeBands {
            self.artistInfoTypes.append(.activeBands)
        }
        
        if let _ = self.artist.live {
            self.artistInfoTypes.append(.live)
        }
        
        if let _ = self.artist.guestSession {
            self.artistInfoTypes.append(.guestSession)
        }
        
        if let _ = self.artist.miscStaff {
            self.artistInfoTypes.append(.miscStaff)
        }
        
        if let _ = self.artist.links {
            self.artistInfoTypes.append(.links)
        }
    }
    
    private func determineArtistRoles() {
        if let pastBands = self.artist.pastBands {
            self.pastBandsRoles = []
            pastBands.forEach { (rolesInBand) in
                self.pastBandsRoles.append(rolesInBand)
                rolesInBand.rolesInReleases?.forEach({ (rolesInRelease) in
                    self.pastBandsRoles.append(rolesInRelease)
                })
            }
        }
        
        if let activeBands = self.artist.activeBands {
            self.activeBandsRoles = []
            activeBands.forEach { (rolesInBand) in
                self.activeBandsRoles.append(rolesInBand)
                rolesInBand.rolesInReleases?.forEach({ (rolesInRelease) in
                    self.activeBandsRoles.append(rolesInRelease)
                })
            }
        }
        
        if let live = self.artist.live {
            self.liveRoles = []
            live.forEach { (rolesInBand) in
                self.liveRoles.append(rolesInBand)
                rolesInBand.rolesInReleases?.forEach({ (rolesInRelease) in
                    self.liveRoles.append(rolesInRelease)
                })
            }
        }
        
        if let guestSession = self.artist.guestSession {
            self.guestSessionRoles = []
            guestSession.forEach { (rolesInBand) in
                self.guestSessionRoles.append(rolesInBand)
                rolesInBand.rolesInReleases?.forEach({ (rolesInRelease) in
                    self.guestSessionRoles.append(rolesInRelease)
                })
            }
        }
        
        if let miscStaff = self.artist.miscStaff {
            self.miscStaffRoles = []
            miscStaff.forEach { (rolesInBand) in
                self.miscStaffRoles.append(rolesInBand)
                rolesInBand.rolesInReleases?.forEach({ (rolesInRelease) in
                    self.miscStaffRoles.append(rolesInRelease)
                })
            }
        }
    }
}

//MARK: - Share
extension ArtistDetailViewController {
    private func removeShareBarButton() {
        self.navigationItem.rightBarButtonItem = nil
    }
    
    private func addShareBarButton() {
        let shareBarButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapShareButton))
        self.navigationItem.rightBarButtonItem = shareBarButton
    }
    
    @objc private func didTapShareButton() {
        guard let `artist` = self.artist, let url = URL(string: artist.urlString) else { return }
        
        self.presentAlertOpenURLInBrowsers(url, alertTitle: "View \(artist.bandMemberName!) in browser", alertMessage: artist.urlString, shareMessage: "Share this artist URL")
        
        Analytics.logEvent(AnalyticsEvent.ShareArtist, parameters: [AnalyticsParameter.ArtistName: artist.bandMemberName, AnalyticsParameter.ArtistID: artist.id])
    }
}

//MARK: - UITableViewDelegate
extension ArtistDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //Hide 1st section header
        if section == 0 {
            return CGFloat.leastNormalMagnitude
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //Section Header
        if section == 0 {
            return nil
        }
        
        let artistInfoType = self.artistInfoTypes[section - 1]
        return artistInfoType.description
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //Section Header
        if indexPath.section == 0 {
            return
        }
        
        let artistInfoType = self.artistInfoTypes[indexPath.section - 1]
        self.didSelectRowForArtistInfoType(artistInfoType: artistInfoType, atIndexPath: indexPath)
    }
}

//MARK: - UITableViewDataSource
extension ArtistDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if let _ = self.artist {
            //+ 1 for header section
            return self.artistInfoTypes.count + 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return self.numberOfRowsInHeaderSection()
        default:
            let artistInfoType = self.artistInfoTypes[section - 1]
            return self.numberOfRowsInArtistInfoTypeSection(artistInfoType)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0: return self.cellForHeaderSection(atIndexPath: indexPath)
        default:
            let artistInfoType = self.artistInfoTypes[indexPath.section - 1]
            return self.cellForArtistInfoType(artistInfoType, atIndexPath: indexPath)
        }
    }
}


//MARK: - Header
extension ArtistDetailViewController {
    private func numberOfRowsInHeaderSection() -> Int {
        return 1
    }
    
    private func cellForHeaderSection(atIndexPath indexPath: IndexPath) -> UITableViewCell {
        let headerCell = ArtistHeaderTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        headerCell.fill(with: artist)
        headerCell.delegate = self
        return headerCell
    }
}

//MARK: - ArtistHeaderTableViewCellDelegate
extension ArtistDetailViewController: ArtistHeaderTableViewCellDelegate {
    func didTapPhotoImageView() {
        guard let photoURLString = self.artist.photoURLString else {
            return
        }
        
        self.presentPhotoViewer(photoURLString: photoURLString, description: artist.bandMemberName)
        
        Analytics.logEvent(AnalyticsEvent.ViewArtistPhoto, parameters: [AnalyticsParameter.ArtistName: artist.bandMemberName, AnalyticsParameter.ArtistID: artist.id])
    }
    
    func didTapBiographyLabel() {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        
        Analytics.logEvent(AnalyticsEvent.ViewArtistBio, parameters: [AnalyticsParameter.ArtistName: artist.bandMemberName, AnalyticsParameter.ArtistID: artist.id])
    }
}

//MARK: - ArtistInfoType
extension ArtistDetailViewController {
    private func numberOfRowsInArtistInfoTypeSection(_ artistInfoType: ArtistInfoType) -> Int {
        switch artistInfoType {
        case .trivia: return 1
        case .activeBands: return self.activeBandsRoles.count
        case .pastBands: return self.pastBandsRoles.count
        case .live: return self.liveRoles.count
        case .guestSession: return self.guestSessionRoles.count
        case .miscStaff: return self.miscStaffRoles.count
        case .links: return self.artist.links!.count
        }
    }
    
    private func cellForArtistInfoType(_ artistInfoType: ArtistInfoType, atIndexPath indexPath: IndexPath) -> UITableViewCell {
        switch artistInfoType {
        case .trivia: return self.cellForTrivia(atIndexPath: indexPath)
        case .links: return self.cellForLink(atIndexPath: indexPath)
        default: return self.cellForRolesInBand(withArtistInfoType: artistInfoType, atIndexPath: indexPath)
        }
    }
    
    private func cellForTrivia(atIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = SimpleTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        cell.fill(with: self.artist.trivia!)
        return cell
    }
    
    private func cellForLink(atIndexPath indexPath: IndexPath) -> UITableViewCell {
        let link = self.artist.links![indexPath.row]
        let linkCell = RelatedLinkTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        linkCell.fill(with: link)
        
        return linkCell
    }
    
    private func cellForRolesInBand(withArtistInfoType artistInfoType: ArtistInfoType, atIndexPath indexPath: IndexPath) -> UITableViewCell {
        var roles: Any!
        switch artistInfoType {
        case .trivia, .links: return UITableViewCell()
        case .activeBands: roles = self.activeBandsRoles[indexPath.row]
        case .pastBands: roles = self.pastBandsRoles[indexPath.row]
        case .live: roles = self.liveRoles[indexPath.row]
        case .guestSession: roles = self.guestSessionRoles[indexPath.row]
        case .miscStaff: roles = self.miscStaffRoles[indexPath.row]
        }
    
        if let `roles` = roles as? RolesInBand {
            let cell = RolesInBandTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
            cell.fill(with: roles)
            return cell
        } else if let `roles` = roles as? RolesInRelease {
            let cell = RolesInReleaseTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
            cell.fill(with: roles)
            return cell
        }
        
        return UITableViewCell()
    }
    
    private func didSelectRowForArtistInfoType(artistInfoType: ArtistInfoType, atIndexPath indexPath: IndexPath) {
        switch artistInfoType {
        case .trivia: return
        case .pastBands: return self.didSelectRoles(roles: self.pastBandsRoles[indexPath.row])
        case .activeBands: return self.didSelectRoles(roles: self.activeBandsRoles[indexPath.row])
        case .live: return self.didSelectRoles(roles: self.liveRoles[indexPath.row])
        case .guestSession: return self.didSelectRoles(roles: self.guestSessionRoles[indexPath.row])
        case .miscStaff: return self.didSelectRoles(roles: self.miscStaffRoles[indexPath.row])
        case .links: return self.didSelectLink(link: self.artist.links![indexPath.row])
        }
    }
    
    private func didSelectRoles(roles: Any) {
        if let rolesInBand = roles as? RolesInBand {
            self.didSelectRolesInBand(rolesInBand: rolesInBand)
        } else if let rolesInRelease = roles as? RolesInRelease {
            self.didSelectRolesInRelease(rolesInRelease: rolesInRelease)
        }
    }
    
    private func didSelectRolesInBand(rolesInBand: RolesInBand) {
        if let bandURLString = rolesInBand.bandURLString {
            self.pushBandDetailViewController(urlString: bandURLString, animated: true)
            
            Analytics.logEvent(AnalyticsEvent.ViewArtistRoleInBand, parameters:[AnalyticsParameter.ArtistName: artist.bandMemberName, AnalyticsParameter.ArtistID: artist.id])
        }
    }
    
    private func didSelectRolesInRelease(rolesInRelease: RolesInRelease) {
        self.pushReleaseDetailViewController(urlString: rolesInRelease.releaseURLString, animated: true)
        
        Analytics.logEvent(AnalyticsEvent.ViewArtistRoleInRelease, parameters:[AnalyticsParameter.ArtistName: artist.bandMemberName, AnalyticsParameter.ArtistID: artist.id])
    }
    
    private func didSelectLink(link: RelatedLink) {
        self.presentAlertOpenURLInBrowsers(URL(string: link.urlString)!, alertTitle: "Open this link in browser", alertMessage: link.urlString, shareMessage: "Share this link")
        
        Analytics.logEvent(AnalyticsEvent.ViewArtistLink, parameters:[AnalyticsParameter.ArtistName: artist.bandMemberName, AnalyticsParameter.ArtistID: artist.id])
    }
}
