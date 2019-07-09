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
    
    // SimpleNavigationBarView
    weak var simpleNavigationBarView: SimpleNavigationBarView?
    
    var delegate: ThemeListTableViewControllerDelegate?
    
    deinit {
        print("ThemeListTableViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initAppearance()
    }
    
    private func initAppearance() {
        tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        tableView.rowHeight = UITableView.automaticDimension
        
        titleLabels.forEach({
            $0.textColor = Settings.currentTheme.bodyTextColor
            $0.font = Settings.currentFontSize.bodyTextFont
        })

        simpleNavigationBarView?.setTitle("Theme")
        tableView.contentInset = UIEdgeInsets(top: baseNavigationBarViewHeightWithoutTopInset - 1, left: 0, bottom: 0, right: 0)
    }

    private func didTapDefaultThemeTableViewCell() {
        setCurrentTheme(.default)
    }
    
    private func didTapLightThemeTableViewCell() {
        setCurrentTheme(.light)
    }
    
    private func didTapVintageThemeTableViewCell() {
        setCurrentTheme(.vintage)
    }
    
    private func didTapUnicornThemeTableViewCell() {
        setCurrentTheme(.unicorn)
    }
    
    private func setCurrentTheme(_ selectedTheme: Theme) {
        var selectedThemeTableViewCell: BaseTableViewCell?
        
        switch selectedTheme {
        case .default: selectedThemeTableViewCell = defaultThemeTableViewCell
        case .light: selectedThemeTableViewCell = lightThemeTableViewCell
        case .vintage: selectedThemeTableViewCell = vintageThemeTableViewCell
        case .unicorn: selectedThemeTableViewCell = unicornThemeTableViewCell
        }
        
        themeTableViewCells.forEach { (eachThemeTableViewCell) in
            if eachThemeTableViewCell == selectedThemeTableViewCell {
                eachThemeTableViewCell.accessoryType = .checkmark
            } else {
                eachThemeTableViewCell.accessoryType = .none
            }
        }
        
        UserDefaults.setTheme(selectedTheme)
        delegate?.didChangeTheme()
        
        displayRestartAlert()
        
        Analytics.logEvent("change_theme", parameters: nil)
    }
}

//MARK: - UITableViewDelegate
extension ThemeListTableViewController {
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedCell = tableView.cellForRow(at: indexPath)
        if selectedCell == defaultThemeTableViewCell {
            didTapDefaultThemeTableViewCell()
        } else if selectedCell == lightThemeTableViewCell {
            didTapLightThemeTableViewCell()
        } else if selectedCell == vintageThemeTableViewCell {
            didTapVintageThemeTableViewCell()
        } else if selectedCell == unicornThemeTableViewCell {
            didTapUnicornThemeTableViewCell()
        }
    }
}

//MARK: - UITableViewDatasource
extension ThemeListTableViewController {
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        switch UserDefaults.selectedTheme() {
        case .default:
            if cell == defaultThemeTableViewCell {
                cell.accessoryType = .checkmark
            }
        case .light:
            if cell == lightThemeTableViewCell {
                cell.accessoryType = .checkmark
            }
        case .vintage:
            if cell == vintageThemeTableViewCell {
                cell.accessoryType = .checkmark
            }
        case .unicorn:
            if cell == unicornThemeTableViewCell {
                cell.accessoryType = .checkmark
            }
        }
    }
}
