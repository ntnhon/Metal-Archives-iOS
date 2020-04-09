//
//  LeftMenuViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 12/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import FirebaseAnalytics

final class LeftMenuViewController: UIViewController {
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    private lazy var homePageViewController: UIViewController = {
        let rootNavigationController = self.slideMenuController()?.mainViewController as! UINavigationController
        return rootNavigationController.viewControllers[0]
    }()
    
    private let options: [[LeftMenuOption]] = [[.homepage], [.bandByAphabetical, .bandByCountry, .bandByGenre], [.labelByAlphabetical, .labelByCountry], [.rip, .randomBand], [.settings, .about]]
    
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
        NotificationCenter.default.addObserver(forName: NSNotification.Name.ShowRandomBand, object: nil, queue: nil) { [unowned self] (notification) in
            self.randomBand()
        }
    }
    
    private func randomBand() {
        homePageViewController.pushBandDetailViewController(urlString: "https://www.metal-archives.com/band/random", animated: true)
        
        Analytics.logEvent("random_band", parameters: nil)
    }
}

//MARK: UITableViewDelegate
extension LeftMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        closeLeft()
        
        let viewControllerToPush: UIViewController
        let option = options[indexPath.section][indexPath.row]
        switch option {
        case .homepage: return
        
        case .bandByAphabetical:
            viewControllerToPush = UIStoryboard(name: "BrowseBands", bundle: nil).instantiateViewController(withIdentifier: "BrowseBandsAlphebaticallyViewController")
        
        case .bandByCountry:
            viewControllerToPush = UIStoryboard(name: "BrowseBands", bundle: nil).instantiateViewController(withIdentifier: "BrowseBandsByCountryViewController")
        
        case .bandByGenre:
            viewControllerToPush = UIStoryboard(name: "BrowseBands", bundle: nil).instantiateViewController(withIdentifier: "BrowseBandsByGenreViewController")
        
        case .labelByAlphabetical:
            viewControllerToPush = UIStoryboard(name: "BrowseLabels", bundle: nil).instantiateViewController(withIdentifier: "BrowseLabelsAlphabeticallyViewController")
            
        case .labelByCountry:
            viewControllerToPush = UIStoryboard(name: "BrowseLabels", bundle: nil).instantiateViewController(withIdentifier: "BrowseLabelsByCountryViewController")
            
        case .rip:
            viewControllerToPush = UIStoryboard(name: "ArtistRIP", bundle: nil).instantiateViewController(withIdentifier: "ArtistRIPViewController")
            
        case .randomBand:
            randomBand()
            return
            
        case .settings:
            viewControllerToPush = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "SettingsTableViewController")
            
        case .about:
            viewControllerToPush = UIStoryboard(name: "About", bundle: nil).instantiateViewController(withIdentifier: "AboutTableViewController")
        }
        
        homePageViewController.navigationController?.pushViewController(viewControllerToPush, animated: true)
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
}

//MARK: UITableViewDatasource
extension LeftMenuViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1: return "BANDS"
        case 2: return "LABELS"
        default: return ""
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        //Sections: Settings
        case 4:
            if let `appVersion` = appVersion {
                return "Metal Archives iOS v\(appVersion)\nMade with 🤘 by metalhead for metalheads."
            }
        default: return nil
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = LeftMenuOptionTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        let option = options[indexPath.section][indexPath.row]
        cell.bind(with: option)
        return cell
    }
}
