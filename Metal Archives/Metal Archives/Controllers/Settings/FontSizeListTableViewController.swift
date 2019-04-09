//
//  FontSizeListTableViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 09/04/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import FirebaseAnalytics

protocol FontSizeListTableViewControllerDelegate {
    func didChangeFontSize()
}

final class FontSizeListTableViewController: UITableViewController {
    @IBOutlet private weak var defaultFontSizeTableViewCell: BaseTableViewCell!
    @IBOutlet private weak var defaultFontSizeLabel: UILabel!
    @IBOutlet private weak var mediumFontSizeTableViewCell: BaseTableViewCell!
    @IBOutlet private weak var mediumFontSizeLabel: UILabel!
    @IBOutlet private weak var largeFontSizeTableViewCell: BaseTableViewCell!
    @IBOutlet private weak var largeFontSizeLabel: UILabel!
    @IBOutlet private var fontSizeTableViewCells: [BaseTableViewCell]!
    
    var delegate: FontSizeListTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initAppearance()
    }
    
    private func initAppearance() {
        self.tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        self.tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        self.tableView.rowHeight = UITableView.automaticDimension
        
        self.defaultFontSizeLabel.textColor = Settings.currentTheme.bodyTextColor
        self.defaultFontSizeLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        self.mediumFontSizeLabel.textColor = Settings.currentTheme.bodyTextColor
        self.mediumFontSizeLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        self.largeFontSizeLabel.textColor = Settings.currentTheme.bodyTextColor
        self.largeFontSizeLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        
        self.title = "Font Size"
    }
    
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
        self.delegate?.didChangeFontSize()
        
        self.displayRestartAlert()
        
        Analytics.logEvent(AnalyticsEvent.ChangeTheme, parameters: nil)
    }
}

//MARK: - UITableViewDelegate
extension FontSizeListTableViewController {
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

//MARK: - UITableViewDatasource
extension FontSizeListTableViewController {
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
