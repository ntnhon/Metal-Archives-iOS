//
//  ThemeListTableViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 09/04/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import FirebaseAnalytics

protocol ThemeListTableViewControllerDelegate {
    func didChangeTheme()
}
final class ThemeListTableViewController: UITableViewController {
    @IBOutlet private weak var defaultThemeTableViewCell: BaseTableViewCell!
    @IBOutlet private weak var lightThemeTableViewCell: BaseTableViewCell!
    @IBOutlet private weak var vintageThemeTableViewCell: BaseTableViewCell!
    @IBOutlet private weak var unicornThemeTableViewCell: BaseTableViewCell!
    
    @IBOutlet private var themeTableViewCells: [BaseTableViewCell]!
    @IBOutlet private var titleLabels: [UILabel]!
    
    var delegate: ThemeListTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initAppearance()
    }
    
    private func initAppearance() {
        self.tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        self.tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        self.tableView.rowHeight = UITableView.automaticDimension
        
        self.titleLabels.forEach({
            $0.textColor = Settings.currentTheme.bodyTextColor
            $0.font = Settings.currentFontSize.bodyTextFont
        })
        
        self.title = "Theme"
    }

    
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
        self.delegate?.didChangeTheme()
        
        self.displayRestartAlert()
        
        Analytics.logEvent(AnalyticsEvent.ChangeTheme, parameters: nil)
    }
}

//MARK: - UITableViewDelegate
extension ThemeListTableViewController {
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
        }
    }
}

//MARK: - UITableViewDatasource
extension ThemeListTableViewController {
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
    }
}
