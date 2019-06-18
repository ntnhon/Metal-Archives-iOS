//
//  AboutTableViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 16/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import MessageUI
import FirebaseAnalytics

final class AboutTableViewController: BaseTableViewController {
    @IBOutlet private var textViews: [UITextView]!
    @IBOutlet private var titleLabels: [UILabel]!
    @IBOutlet private var detailLabels: [UILabel]!
    
    @IBOutlet private weak var gitHubTableViewCell: BaseTableViewCell!
    @IBOutlet private weak var contactAuthorTableViewCell: BaseTableViewCell!
    @IBOutlet private weak var officialSiteTableViewCell: BaseTableViewCell!
    @IBOutlet private weak var officialFacebookTableViewCell: BaseTableViewCell!
    @IBOutlet private weak var unofficialFacebookTableViewCell: BaseTableViewCell!
    @IBOutlet private weak var allOpenSourceLibrariesTableViewCell: BaseTableViewCell!
    @IBOutlet private weak var takeMeToAppStoreTableViewCell: BaseTableViewCell!
    
    deinit {
        print("AboutTableViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initAppearance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        simpleNavigationBarView?.setTitle("About")
    }

    private func initAppearance() {
        view.backgroundColor = Settings.currentTheme.backgroundColor
        tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
       
        textViews.forEach({
            $0.textColor = Settings.currentTheme.bodyTextColor
            $0.font = Settings.currentFontSize.bodyTextFont
            $0.backgroundColor = Settings.currentTheme.backgroundColor
        })
        
        titleLabels.forEach({
            $0.textColor = Settings.currentTheme.secondaryTitleColor
            $0.font = Settings.currentFontSize.secondaryTitleFont
        })
        
        detailLabels.forEach({
            $0.textColor = Settings.currentTheme.bodyTextColor
            $0.font = Settings.currentFontSize.bodyTextFont
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let openSourceLibrariesViewController as OpenSourceLibrariesViewController:
            openSourceLibrariesViewController.simpleNavigationBarView = simpleNavigationBarView
            
        case let versionHistoryViewController as VersionHistoryViewController:
            versionHistoryViewController.simpleNavigationBarView = simpleNavigationBarView
            
        default:
            break
        }
    }
}

//MARK: - Actions
extension AboutTableViewController {
    private func didTapGithub() {
        let urlString = "https://github.com/ntnhon/Metal-Archives-iOS"
        presentAlertOpenURLInBrowsers(URL(string: urlString)!, alertMessage: urlString)
        
        Analytics.logEvent(AnalyticsEvent.SelectAnAboutOption, parameters: [AnalyticsParameter.Option: "Github"])
    }
    
    private func didTapContactAuthor() {
        let mailComposerVC = MFMailComposeViewController()
        
        guard let _ = mailComposerVC.view else {
            return
        }
        
        mailComposerVC.view.tintColor = Settings.currentTheme.titleColor
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setSubject("[Metal Archives iOS] Contact author")
        mailComposerVC.setToRecipients(["contact@nguyenthanhnhon.info", "ntnhon.cs@gmail.com"])
        
        present(mailComposerVC, animated: true, completion: nil)
        
        Analytics.logEvent(AnalyticsEvent.SelectAnAboutOption, parameters: [AnalyticsParameter.Option: "Contact author"])
    }
    
    private func didTapOfficialSite() {
        let urlString = "https://www.metal-archives.com/"
        presentAlertOpenURLInBrowsers(URL(string: urlString)!, alertMessage: urlString)
        
        Analytics.logEvent(AnalyticsEvent.SelectAnAboutOption, parameters: [AnalyticsParameter.Option: "Official site"])
    }
    
    private func didTapOfficialFacebook() {
        let urlString = "https://www.facebook.com/metal.archives/"
        presentAlertOpenURLInBrowsers(URL(string: urlString)!, alertMessage: urlString)
        
        Analytics.logEvent(AnalyticsEvent.SelectAnAboutOption, parameters: [AnalyticsParameter.Option: "Official facebook"])
    }
    
    private func didTapUnofficialFacebook() {
        let urlString = "https://www.facebook.com/MetalArchivesIOSApp/"
        presentAlertOpenURLInBrowsers(URL(string: urlString)!, alertMessage: urlString)
        
        Analytics.logEvent(AnalyticsEvent.SelectAnAboutOption, parameters: [AnalyticsParameter.Option: "Unofficial facebook"])
    }
    
    private func didTapShowAllOpenSourceLibraries() {
        performSegue(withIdentifier: "ShowLibraries", sender: nil)
        
        Analytics.logEvent(AnalyticsEvent.SelectAnAboutOption, parameters: [AnalyticsParameter.Option: "Show libraries"])
    }
    
    private func didTapTakeMeToAppStore() {
        openReviewOnAppStore()
        
        Analytics.logEvent(AnalyticsEvent.SelectAnAboutOption, parameters: [AnalyticsParameter.Option: "Open review on App Store"])
    }
}

//MARK: - UITableViewDelegate
extension AboutTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedCell = tableView.cellForRow(at: indexPath)
        
        if selectedCell == gitHubTableViewCell {
            didTapGithub()
        } else if selectedCell == contactAuthorTableViewCell {
            didTapContactAuthor()
        } else if selectedCell == officialSiteTableViewCell {
            didTapOfficialSite()
        } else if selectedCell == officialFacebookTableViewCell {
            didTapOfficialFacebook()
        } else if selectedCell == unofficialFacebookTableViewCell {
            didTapUnofficialFacebook()
        } else if selectedCell == allOpenSourceLibrariesTableViewCell {
            didTapShowAllOpenSourceLibraries()
        } else if selectedCell == takeMeToAppStoreTableViewCell {
            didTapTakeMeToAppStore()
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = Settings.currentTheme.titleColor
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let footerView = view as? UITableViewHeaderFooterView {
            footerView.textLabel?.textColor = Settings.currentTheme.titleColor
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            if let `appVersion` = appVersion {
                return "Metal Archives iOS v\(appVersion)"
            }
        } else if section == 1 {
            return "Links"
        } else if section == 2 {
            return "Open source libraries"
        } else if section == 3 {
            return "Version history"
        } else if section == 4 {
            return "Review on App Store"
        }
        return nil
    }
}

//MARK: - MFMailComposeViewControllerDelegate
extension AboutTableViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
