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
    
    //Themes
    @IBOutlet private weak var defaultThemeTableViewCell: BaseTableViewCell!
    @IBOutlet private weak var lightThemeTableViewCell: BaseTableViewCell!
    @IBOutlet private weak var vintageThemeTableViewCell: BaseTableViewCell!
    @IBOutlet private weak var unicornThemeTableViewCell: BaseTableViewCell!
    @IBOutlet private var themeTableViewCells: [BaseTableViewCell]!
    
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
    
    private func displayRestartAlert() {
        let alert = UIAlertController(title: "Restart required", message: "Restart application for changes to take effect.", preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        alert.addAction(okayAction)
        self.present(alert, animated: true, completion: nil)
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
            
        default:
            break
        }
    }
}

//MARK: - Theme customization
extension SettingsTableViewController {
    private func didTapDefaultThemeTableViewCell() {
        self.setCurrentTheme(.default)
    }
    
    private func didTapLightThemeTableViewCell() {
        self.setCurrentTheme(.light)
    }
    
    private func didTapVintageThemeTableViewCell() {
        self.setCurrentTheme(.vintage)
    }
    
    private func didTapUnicornThemeTableViewCell() {
        self.setCurrentTheme(.unicorn)
    }
    
    private func setCurrentTheme(_ selectedTheme: Theme) {
        var selectedThemeTableViewCell: BaseTableViewCell?
        
        switch selectedTheme {
        case .default: selectedThemeTableViewCell = self.defaultThemeTableViewCell
        case .light: selectedThemeTableViewCell = self.lightThemeTableViewCell
        case .vintage: selectedThemeTableViewCell = self.vintageThemeTableViewCell
        case .unicorn: selectedThemeTableViewCell = self.unicornThemeTableViewCell
        }
        
        self.themeTableViewCells.forEach { (eachThemeTableViewCell) in
            if eachThemeTableViewCell == selectedThemeTableViewCell {
                eachThemeTableViewCell.accessoryType = .checkmark
            } else {
                eachThemeTableViewCell.accessoryType = .none
            }
        }
        
        UserDefaults.setTheme(selectedTheme)
        
        self.displayRestartAlert()
        
        Analytics.logEvent(AnalyticsEvent.ChangeTheme, parameters: nil)
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
        if selectedCell == self.defaultThemeTableViewCell {
            self.didTapDefaultThemeTableViewCell()
        } else if selectedCell == self.lightThemeTableViewCell {
            self.didTapLightThemeTableViewCell()
        } else if selectedCell == self.vintageThemeTableViewCell {
            self.didTapVintageThemeTableViewCell()
        } else if selectedCell == self.unicornThemeTableViewCell {
            self.didTapUnicornThemeTableViewCell()
        } else if selectedCell == self.defaultFontSizeTableViewCell {
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

        switch UserDefaults.selectedTheme() {
        case .default:
            if cell == self.defaultThemeTableViewCell {
                cell.accessoryType = .checkmark
            }
        case .light:
            if cell == self.lightThemeTableViewCell {
                cell.accessoryType = .checkmark
            }
        case .vintage:
            if cell == self.vintageThemeTableViewCell {
                cell.accessoryType = .checkmark
            }
        case .unicorn:
            if cell == self.unicornThemeTableViewCell {
                cell.accessoryType = .checkmark
            }
        }
        
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
