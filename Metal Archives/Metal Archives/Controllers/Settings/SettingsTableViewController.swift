//
//  SettingsTableViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 16/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import FirebaseAnalytics

final class SettingsTableViewController: UITableViewController {
    @IBOutlet private var titleLabels: [UILabel]!
    @IBOutlet private var detailLabels: [UILabel]!
    @IBOutlet private var switches: [UISwitch]!
    
    //Theme
    @IBOutlet private weak var themeLabel: UILabel!
    
    //Font Size
    @IBOutlet private weak var defaultFontSizeTableViewCell: BaseTableViewCell!
    @IBOutlet private weak var defaultFontSizeLabel: UILabel!
    @IBOutlet private weak var mediumFontSizeTableViewCell: BaseTableViewCell!
    @IBOutlet private weak var mediumFontSizeLabel: UILabel!
    @IBOutlet private weak var largeFontSizeTableViewCell: BaseTableViewCell!
    @IBOutlet private weak var largeFontSizeLabel: UILabel!
    @IBOutlet private var fontSizeTableViewCells: [BaseTableViewCell]!
    
    //Thumbnail
    @IBOutlet private weak var thumbnailSwitch: UISwitch!
    
    //Widget
    @IBOutlet private weak var choosenWidgetSectionsLabel: UILabel!
    private var choosenWidgetSections: [WidgetSection]! {
        didSet {
            self.updateChoosenWidgetSectionsLabel()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initAppearance()
        self.initThumbnailSwitch()
        self.updateThemeTitle()
        self.choosenWidgetSections = UserDefaults.choosenWidgetSections()
        self.title = "Settings"
    }
    
    private func initAppearance() {
        self.tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        self.tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        self.tableView.rowHeight = UITableView.automaticDimension
        
        self.titleLabels.forEach({
            $0.textColor = Settings.currentTheme.bodyTextColor
            $0.font = Settings.currentFontSize.bodyTextFont
        })
        
        self.detailLabels.forEach({
            $0.textColor = Settings.currentTheme.bodyTextColor.withAlphaComponent(0.7)
            $0.font = Settings.currentFontSize.bodyTextFont
        })
        
        self.switches.forEach({
            $0.tintColor = Settings.currentTheme.secondaryTitleColor
            $0.onTintColor = Settings.currentTheme.titleColor
        })
        
        self.defaultFontSizeLabel.textColor = Settings.currentTheme.bodyTextColor
        self.defaultFontSizeLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        self.mediumFontSizeLabel.textColor = Settings.currentTheme.bodyTextColor
        self.mediumFontSizeLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        self.largeFontSizeLabel.textColor = Settings.currentTheme.bodyTextColor
        self.largeFontSizeLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
    }

    private func initThumbnailSwitch() {
        let enabled = UserDefaults.thumbnailEnabled()
        self.thumbnailSwitch.isOn = enabled
        self.thumbnailSwitch.addTarget(self, action: #selector(thumbnailSwitchChangedValue), for: .valueChanged)
    }
    
    @objc private func thumbnailSwitchChangedValue() {
        UserDefaults.setThumbnailEnabled(self.thumbnailSwitch.isOn)
        self.displayRestartAlert()
        
        Analytics.logEvent(AnalyticsEvent.ChangeThumbnailEnabled, parameters: ["thumbnail_enabled": self.thumbnailSwitch.isOn])
    }
    
    private func updateChoosenWidgetSectionsLabel() {
        if self.choosenWidgetSections.count == 1 {
            self.choosenWidgetSectionsLabel.text = "\(self.choosenWidgetSections[0].description)"
        } else if self.choosenWidgetSections.count == 2 {
            self.choosenWidgetSectionsLabel.text = "\(self.choosenWidgetSections[0].description), \(self.choosenWidgetSections[1].description)"
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
        case let chooseWidgetSectionsViewController as ChooseWidgetSectionsViewController:
            chooseWidgetSectionsViewController.delegate = self
        case let themeListTableViewController as ThemeListTableViewController:
            themeListTableViewController.delegate = self
            
        default:
            break
        }
    }
}

//MARK: - Theme customization
extension SettingsTableViewController: ThemeListTableViewControllerDelegate {
    func didChangeTheme() {
        self.updateThemeTitle()
    }
    
    private func updateThemeTitle() {
        self.themeLabel.text = UserDefaults.selectedTheme().description
    }
}

//MARK: - Font size customization
extension SettingsTableViewController {
    private func didTapDefaultFontSizeTableViewCell() {
        self.setCurrentFontSize(.default)
    }
    
    private func didTapMediumFontSizeTableViewCell() {
        self.setCurrentFontSize(.medium)
    }
    
    private func didTapLargeFontSizeTableViewCell() {
        self.setCurrentFontSize(.large)
    }
    
    private func setCurrentFontSize(_ selectedFontSize: FontSize) {
        var selectedFontSizeTableViewCell: BaseTableViewCell?
        
        switch selectedFontSize {
        case .default: selectedFontSizeTableViewCell = self.defaultFontSizeTableViewCell
        case .medium: selectedFontSizeTableViewCell = self.mediumFontSizeTableViewCell
        case .large: selectedFontSizeTableViewCell = self.largeFontSizeTableViewCell
        }
        
        self.fontSizeTableViewCells.forEach { (eachThemeTableViewCell) in
            if eachThemeTableViewCell == selectedFontSizeTableViewCell {
                eachThemeTableViewCell.accessoryType = .checkmark
            } else {
                eachThemeTableViewCell.accessoryType = .none
            }
        }
        
        UserDefaults.setFontSize(selectedFontSize)
        
        self.displayRestartAlert()
        
        Analytics.logEvent(AnalyticsEvent.ChangeTheme, parameters: nil)
    }
}

//MARK: - ChooseWidgetSectionsViewControllerDelegate
extension SettingsTableViewController: ChooseWidgetSectionsViewControllerDelegate {
    func didChooseWidgetSections(_ widgetSections: [WidgetSection]) {
        self.choosenWidgetSections = widgetSections
        Analytics.logEvent(AnalyticsEvent.ChangeWidgetSections, parameters: nil)
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
        
        let selectedCell = tableView.cellForRow(at: indexPath)
        if selectedCell == self.defaultFontSizeTableViewCell {
            self.didTapDefaultFontSizeTableViewCell()
        } else if selectedCell == self.mediumFontSizeTableViewCell {
            self.didTapMediumFontSizeTableViewCell()
        } else if selectedCell == self.largeFontSizeTableViewCell {
            self.didTapLargeFontSizeTableViewCell()
        }
    }
}

extension SettingsTableViewController {
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        switch UserDefaults.selectedFontSize() {
        case .default:
            if cell == self.defaultFontSizeTableViewCell {
                cell.accessoryType = .checkmark
            }
        case .medium:
            if cell == self.mediumFontSizeTableViewCell {
                cell.accessoryType = .checkmark
            }
        case .large:
            if cell == self.largeFontSizeTableViewCell {
                cell.accessoryType = .checkmark
            }
        }
    }
}
