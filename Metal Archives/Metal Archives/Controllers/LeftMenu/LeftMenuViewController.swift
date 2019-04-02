//
//  LeftMenuViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 12/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift
import FirebaseAnalytics

final class LeftMenuViewController: UIViewController {
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    private lazy var homePageViewController: UIViewController = {
        let rootNavigationController = self.slideMenuController()?.mainViewController as! UINavigationController
        return rootNavigationController.viewControllers[0]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initAppearance()
        self.initObservers()
    }
    
    private func initAppearance() {
        self.view.backgroundColor = Settings.currentTheme.backgroundColor
        self.tableView.backgroundColor = Settings.currentTheme.backgroundColor
        self.tableView.separatorColor = Settings.currentTheme.secondaryTitleColor
        self.tableView.rowHeight = UITableView.automaticDimension
        //Hide 1st section's header
        self.tableView.contentInset = UIEdgeInsets(top: -CGFloat.leastNormalMagnitude, left: 0, bottom: 0, right: 0)
        
        LeftMenuOptionTableViewCell.register(with: self.tableView)
        
        self.view.layer.shadowColor = UIColor.black.cgColor
        self.view.layer.shadowOpacity = 1
    }
    
    private func initObservers() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.ShowRandomBand, object: nil, queue: nil) { (notification) in
            self.didSelectRandomBand()
        }
    }
}

//MARK: SlideMenuControllerDelegate
extension LeftMenuViewController: SlideMenuControllerDelegate {
    func leftWillOpen() {
        //Only show left menu's shadow when it's opened
        self.view.layer.shadowRadius = 5
    }
    
    func leftDidClose() {
        self.view.layer.shadowRadius = 0
    }
}

//MARK: UITableViewDelegate
extension LeftMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        //Section: Homepage
        if indexPath.section == 0 {
            self.didSelectHomePage()
        } else if indexPath.section == 1 {
            //Section: Bands
            switch indexPath.row {
                //Alphabetical
            case 0: self.didSelectBandsAlphabetical()
                //Country
            case 1: self.didSelectBandsCountry()
                //Genre
            case 2: self.didSelectBandsGenre()
            default: return
            }
        } else if indexPath.section == 2 {
            //Section: Labels
            switch indexPath.row {
                //Alphabetical
            case 0: self.didSelectLabelsAlphabetical()
                //Country
            case 1: self.didSelectLabelsCountry()
            default: return
            }
        } else if indexPath.section == 3 {
            //Sections: Others
            switch indexPath.row {
                //R.I.P
            case 0: self.didSelectRIP()
                //Random band
            case 1: self.didSelectRandomBand()
            default: return
            }
        } else if indexPath.section == 4 {
            //Sections: Settings
            switch indexPath.row {
                //Settings
            case 0: self.didSelectSettings()
                //About
            case 1: self.didSelectAbout()
            default: return
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //Hide 1est section's header
        if section == 0 {
            return CGFloat.leastNormalMagnitude
        }
        
        return 30
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
    
    private func didSelectHomePage() {
        self.closeLeft()
    }
    
    private func didSelectBandsAlphabetical() {
        self.closeLeft()
        if let browseBandsAlphebaticallyViewController = UIStoryboard(name: "BrowseBands", bundle: nil).instantiateViewController(withIdentifier: "BrowseBandsAlphebaticallyViewController") as? BrowseBandsAlphabeticallyViewController {
            self.homePageViewController.navigationController?.pushViewController(browseBandsAlphebaticallyViewController, animated: true)
        }
    }
    
    private func didSelectBandsCountry() {
        self.closeLeft()
        if let browseBandsByCountryViewController = UIStoryboard(name: "BrowseBands", bundle: nil).instantiateViewController(withIdentifier: "BrowseBandsByCountryViewController") as? BrowseBandsByCountryViewController {
            self.homePageViewController.navigationController?.pushViewController(browseBandsByCountryViewController, animated: true)
        }
    }
    
    private func didSelectBandsGenre() {
        self.closeLeft()
        if let browseBandsByGenreViewController = UIStoryboard(name: "BrowseBands", bundle: nil).instantiateViewController(withIdentifier: "BrowseBandsByGenreViewController") as? BrowseBandsByGenreViewController {
            self.homePageViewController.navigationController?.pushViewController(browseBandsByGenreViewController, animated: true)
        }
    }
    
    private func didSelectLabelsAlphabetical() {
        self.closeLeft()
        if let browseLabelsAlphabeticallyViewController = UIStoryboard(name: "BrowseLabels", bundle: nil).instantiateViewController(withIdentifier: "BrowseLabelsAlphabeticallyViewController") as? BrowseLabelsAlphabeticallyViewController {
            self.homePageViewController.navigationController?.pushViewController(browseLabelsAlphabeticallyViewController, animated: true)
        }
    }
    
    private func didSelectLabelsCountry() {
        self.closeLeft()
        if let browseLabelsByCountryViewController = UIStoryboard(name: "BrowseLabels", bundle: nil).instantiateViewController(withIdentifier: "BrowseLabelsByCountryViewController") as? BrowseLabelsByCountryViewController {
            self.homePageViewController.navigationController?.pushViewController(browseLabelsByCountryViewController, animated: true)
        }
    }
    
    private func didSelectRIP() {
        self.closeLeft()
        if let artistRIPViewController = UIStoryboard(name: "ArtistRIP", bundle: nil).instantiateViewController(withIdentifier: "ArtistRIPViewController") as? ArtistRIPViewController {
            self.homePageViewController.navigationController?.pushViewController(artistRIPViewController, animated: true)
        }
    }
    
    private func didSelectRandomBand() {
        self.closeLeft()
        self.homePageViewController.pushBandDetailViewController(urlString: "https://www.metal-archives.com/band/random", animated: true)
        
        Analytics.logEvent(AnalyticsEvent.RandomBand, parameters: nil)
    }
    
    private func didSelectSettings() {
        self.closeLeft()
        if let settingsTableViewController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "SettingsTableViewController") as? SettingsTableViewController {
            self.homePageViewController.navigationController?.pushViewController(settingsTableViewController, animated: true)
        }
    }
    
    private func didSelectAbout() {
        self.closeLeft()
        if let aboutTableViewController = UIStoryboard(name: "About", bundle: nil).instantiateViewController(withIdentifier: "AboutTableViewController") as? AboutTableViewController {
            self.homePageViewController.navigationController?.pushViewController(aboutTableViewController, animated: true)
        }
    }
}

//MARK: UITableViewDatasource
extension LeftMenuViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        //4 sections: Homepage, Bands, Labels, Others & Settings
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        //Section: Homepage - 1 row
        case 0: return 1
        //Section: Bands - 3 rows: Alphabetical, Country & Genre
        case 1: return 3
        //Section: Labels - 2 rows: Alphabetical & Country
        case 2: return 2
        //Section: Others - 2 rows: R.I.P & Random Band
        case 3: return 2
        //Section: Settings - 2 rows: Settings & About
        case 4: return 2
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        //Section: Homepage
        case 0: return ""
        //Section: Bands
        case 1: return "BANDS"
        //Section: Labels
        case 2: return "LABELS"
        //Section: Others
        case 3: return ""
        //Sections: Settings
        case 4: return ""
        default: return ""
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        //Section: Homepage
        case 0: return ""
        //Section: Bands
        case 1: return ""
        //Section: Labels
        case 2: return ""
        //Section: Others
        case 3: return ""
        //Sections: Settings
        case 4:
            if let `appVersion` = appVersion {
                return "Metal Archives iOS v\(appVersion)\nBy metalhead for metalheads."
            }
            return ""
        default: return ""
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        //Section: Homepage
        case 0: return cellForHomepageSection(atIndex: indexPath)
        //Section Bands
        case 1: return cellForBandsSection(atIndex: indexPath)
        //Section Labels
        case 2: return cellForLabelsSection(atIndex: indexPath)
        //Section Others
        case 3: return cellForOthersSection(atIndex: indexPath)
        //Section Settings
        case 4: return cellForSettingsSection(atIndex: indexPath)
        default:
            fatalError("Impossible case!")
        }
    }
    
    private func cellForHomepageSection(atIndex indexPath: IndexPath) -> UITableViewCell {
        let cell = LeftMenuOptionTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        
        cell.initOption(iconName: Ressources.Images.homeIcon, optionName: "Metal Archives")
        
        return cell
    }
    
    private func cellForBandsSection(atIndex indexPath: IndexPath) -> UITableViewCell {
        let cell = LeftMenuOptionTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        var cellLabelText: String
        var cellIconName: String
        
        switch indexPath.row {
        case 0:
            cellLabelText = "Alphabetical"
            cellIconName = Ressources.Images.alphabeticalIcon
        case 1:
            cellLabelText = "Country"
            cellIconName = Ressources.Images.countryIcon
        case 2:
            cellLabelText = "Genre"
            cellIconName = Ressources.Images.genreIcon
        default:
            fatalError("Impossible case!")
        }
        
        cell.initOption(iconName: cellIconName, optionName: cellLabelText)
        
        return cell
    }
    
    private func cellForLabelsSection(atIndex indexPath: IndexPath) -> UITableViewCell {
        let cell = LeftMenuOptionTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        var cellLabelText: String
        var cellIconName: String
        
        switch indexPath.row {
        case 0:
            cellLabelText = "Alphabetical"
            cellIconName = Ressources.Images.alphabeticalIcon
        case 1:
            cellLabelText = "Country"
            cellIconName = Ressources.Images.countryIcon
        default:
            fatalError("Impossible case!")
        }
        
        cell.initOption(iconName: cellIconName, optionName: cellLabelText)
        
        return cell
    }
    
    private func cellForOthersSection(atIndex indexPath: IndexPath) -> UITableViewCell {
        let cell = LeftMenuOptionTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        var cellLabelText: String
        var cellIconName: String
        
        switch indexPath.row {
        case 0:
            cellLabelText = "R.I.P"
            cellIconName = Ressources.Images.ripIcon
        case 1:
            cellLabelText = "Random Band"
            cellIconName = Ressources.Images.randomIcon
        default:
            fatalError("Impossible case!")
        }
        
        cell.initOption(iconName: cellIconName, optionName: cellLabelText)
        
        return cell
    }
    
    private func cellForSettingsSection(atIndex indexPath: IndexPath) -> UITableViewCell {
        let cell = LeftMenuOptionTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        var cellLabelText: String
        var cellIconName: String
        
        switch indexPath.row {
        case 0:
            cellLabelText = "Settings"
            cellIconName = Ressources.Images.settingsIcon
        case 1:
            cellLabelText = "About"
            cellIconName = Ressources.Images.aboutIcon
        default:
            fatalError("Impossible case!")
        }

        cell.initOption(iconName: cellIconName, optionName: cellLabelText)
        
        return cell
    }
}
