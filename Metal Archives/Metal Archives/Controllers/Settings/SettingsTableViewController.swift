//
//  SettingsTableViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 16/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import FirebaseAnalytics

final class SettingsTableViewController: BaseTableViewController {
    @IBOutlet private var titleLabels: [UILabel]!
    @IBOutlet private var detailLabels: [UILabel]!
    @IBOutlet private var switches: [UISwitch]!
    
    //Theme
    @IBOutlet private weak var themeLabel: UILabel!
    //Font Size
    @IBOutlet private weak var fontSizeLabel: UILabel!
    //Discography Type
    @IBOutlet private weak var discographyTypeLabel: UILabel!
    //Thumbnail
    @IBOutlet private weak var thumbnailSwitch: UISwitch!
    
    //Widget
    @IBOutlet private weak var choosenWidgetSectionsLabel: UILabel!
    private var choosenWidgetSections: [WidgetSection]! {
        didSet {
            updateChoosenWidgetSectionsLabel()
        }
    }
    
    deinit {
        print("SettingsTableViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initAppearance()
        initThumbnailSwitch()
        updateThemeTitle()
        updateFontSizeLabel()
        updateDiscographyTypeLabel()
        choosenWidgetSections = UserDefaults.choosenWidgetSections()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        simpleNavigationBarView?.setTitle("Settings")
    }
    
    private func initAppearance() {
        tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        tableView.rowHeight = UITableView.automaticDimension
        
        titleLabels.forEach({
            $0.textColor = Settings.currentTheme.bodyTextColor
            $0.font = Settings.currentFontSize.bodyTextFont
        })
        
        detailLabels.forEach({
            $0.textColor = Settings.currentTheme.bodyTextColor.withAlphaComponent(0.7)
            $0.font = Settings.currentFontSize.bodyTextFont
        })
        
        switches.forEach({
            $0.tintColor = Settings.currentTheme.secondaryTitleColor
            $0.onTintColor = Settings.currentTheme.titleColor
        })
    }

    private func initThumbnailSwitch() {
        let enabled = UserDefaults.thumbnailEnabled()
        thumbnailSwitch.isOn = enabled
        thumbnailSwitch.addTarget(self, action: #selector(thumbnailSwitchChangedValue), for: .valueChanged)
    }
    
    @objc private func thumbnailSwitchChangedValue() {
        UserDefaults.setThumbnailEnabled(thumbnailSwitch.isOn)
        displayRestartAlert()
        
        Analytics.logEvent("change_thumbnail_option", parameters: ["thumbnail_enabled": thumbnailSwitch.isOn])
    }
    
    private func updateChoosenWidgetSectionsLabel() {
        if choosenWidgetSections.count == 1 {
            choosenWidgetSectionsLabel.text = "\(choosenWidgetSections[0].description)"
        } else if choosenWidgetSections.count == 2 {
            choosenWidgetSectionsLabel.text = "\(choosenWidgetSections[0].description), \(choosenWidgetSections[1].description)"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let settingExplicationTableViewController as SettingExplicationTableViewController:
            if segue.identifier == "ShowThumbnailExplication" {
                settingExplicationTableViewController.explainThumbnail = true
                
            } else if segue.identifier == "ShowWidgetExplication" {
                settingExplicationTableViewController.explainWidget = true
            }
            settingExplicationTableViewController.simpleNavigationBarView = simpleNavigationBarView
            
        case let chooseWidgetSectionsViewController as ChooseWidgetSectionsViewController:
            chooseWidgetSectionsViewController.delegate = self
            chooseWidgetSectionsViewController.simpleNavigationBarView = simpleNavigationBarView
            
        case let themeListTableViewController as ThemeListTableViewController:
            themeListTableViewController.delegate = self
            themeListTableViewController.simpleNavigationBarView = simpleNavigationBarView
            
        case let fontSizeListTableViewController as FontSizeListTableViewController:
            fontSizeListTableViewController.delegate = self
            fontSizeListTableViewController.simpleNavigationBarView = simpleNavigationBarView
            
        case let discographyTypeListTableViewController as DiscographyTypeListTableViewController:
            discographyTypeListTableViewController.delegate = self
            discographyTypeListTableViewController.simpleNavigationBarView = simpleNavigationBarView
            
        default:
            break
        }
    }
}

//MARK: - ThemeListTableViewControllerDelegate
extension SettingsTableViewController: ThemeListTableViewControllerDelegate {
    func didChangeTheme() {
        updateThemeTitle()
    }
    
    private func updateThemeTitle() {
        themeLabel.text = UserDefaults.selectedTheme().description
    }
}

//MARK: - FontSizeListTableViewControllerDelegate
extension SettingsTableViewController: FontSizeListTableViewControllerDelegate {
    func didChangeFontSize() {
        updateFontSizeLabel()
    }
    
    private func updateFontSizeLabel() {
        fontSizeLabel.text = UserDefaults.selectedFontSize().description
    }
}

//MARK: - DiscographyTypeListTableViewControllerDelegate
extension SettingsTableViewController: DiscographyTypeListTableViewControllerDelegate {
    func didChangeDiscographyType() {
        updateDiscographyTypeLabel()
    }
    
    private func updateDiscographyTypeLabel() {
        discographyTypeLabel.text = UserDefaults.selectedDiscographyType().description
    }
}

//MARK: - ChooseWidgetSectionsViewControllerDelegate
extension SettingsTableViewController: ChooseWidgetSectionsViewControllerDelegate {
    func didChooseWidgetSections(_ widgetSections: [WidgetSection]) {
        choosenWidgetSections = widgetSections
        Analytics.logEvent("change_widget_sections", parameters: nil)
    }
}

//MARK: - UITableViewDelegate
extension SettingsTableViewController {
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
