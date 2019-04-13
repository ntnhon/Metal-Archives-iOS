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

final class AboutTableViewController: UITableViewController {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initAppearance()
        self.title = "About"
    }

    private func initAppearance() {
        self.view.backgroundColor = Settings.currentTheme.backgroundColor
        self.tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        self.tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.tableFooterView = UIView(frame: .zero)
       
        self.textViews.forEach({
            $0.textColor = Settings.currentTheme.bodyTextColor
            $0.font = Settings.currentFontSize.bodyTextFont
            $0.backgroundColor = Settings.currentTheme.backgroundColor
        })
        
        self.titleLabels.forEach({
            $0.textColor = Settings.currentTheme.secondaryTitleColor
            $0.font = Settings.currentFontSize.secondaryTitleFont
        })
        
        self.detailLabels.forEach({
            $0.textColor = Settings.currentTheme.bodyTextColor
            $0.font = Settings.currentFontSize.bodyTextFont
        })
    }
}

//MARK: - Actions
extension AboutTableViewController {
    private func didTapGithub() {
        let urlString = "https://github.com/ntnhon/Metal-Archives-iOS"
        self.presentAlertOpenURLInBrowsers(URL(string: urlString)!, alertMessage: urlString)
        
        Analytics.logEvent(AnalyticsEvent.SelectAnAboutOption, parameters: [AnalyticsParameter.Option: "Github"])
    }
    
    private func didTapContactAuthor() {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.view.tintColor = Settings.currentTheme.titleColor
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setSubject("[Metal Archives iOS] Contact author")
        mailComposerVC.setToRecipients(["contact@nguyenthanhnhon.info", "ntnhon.cs@gmail.com"])
        
        self.present(mailComposerVC, animated: true, completion: nil)
        
        Analytics.logEvent(AnalyticsEvent.SelectAnAboutOption, parameters: [AnalyticsParameter.Option: "Contact author"])
    }
    
    private func didTapOfficialSite() {
        let urlString = "https://www.metal-archives.com/"
        self.presentAlertOpenURLInBrowsers(URL(string: urlString)!, alertMessage: urlString)
        
        Analytics.logEvent(AnalyticsEvent.SelectAnAboutOption, parameters: [AnalyticsParameter.Option: "Official site"])
    }
    
    private func didTapOfficialFacebook() {
        let urlString = "https://www.facebook.com/metal.archives/"
        self.presentAlertOpenURLInBrowsers(URL(string: urlString)!, alertMessage: urlString)
        
        Analytics.logEvent(AnalyticsEvent.SelectAnAboutOption, parameters: [AnalyticsParameter.Option: "Official facebook"])
    }
    
    private func didTapUnofficialFacebook() {
        let urlString = "https://www.facebook.com/MetalArchivesIOSApp/"
        self.presentAlertOpenURLInBrowsers(URL(string: urlString)!, alertMessage: urlString)
        
        Analytics.logEvent(AnalyticsEvent.SelectAnAboutOption, parameters: [AnalyticsParameter.Option: "Unofficial facebook"])
    }
    
    private func didTapShowAllOpenSourceLibraries() {
        self.performSegue(withIdentifier: "ShowLibraries", sender: nil)
        
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
        
        if selectedCell == self.gitHubTableViewCell {
            self.didTapGithub()
        } else if selectedCell == self.contactAuthorTableViewCell {
            self.didTapContactAuthor()
        } else if selectedCell == self.officialSiteTableViewCell {
            self.didTapOfficialSite()
        } else if selectedCell == self.officialFacebookTableViewCell {
            self.didTapOfficialFacebook()
        } else if selectedCell == self.unofficialFacebookTableViewCell {
            self.didTapUnofficialFacebook()
        } else if selectedCell == self.allOpenSourceLibrariesTableViewCell {
            self.didTapShowAllOpenSourceLibraries()
        } else if selectedCell == self.takeMeToAppStoreTableViewCell {
            self.didTapTakeMeToAppStore()
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
