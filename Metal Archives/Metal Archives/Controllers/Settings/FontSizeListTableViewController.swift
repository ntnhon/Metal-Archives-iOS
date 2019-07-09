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
    
    // SimpleNavigationBarView
    weak var simpleNavigationBarView: SimpleNavigationBarView?
    
    var delegate: FontSizeListTableViewControllerDelegate?
    
    deinit {
        print("FontSizeListTableViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initAppearance()
    }
    
    private func initAppearance() {
        tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        tableView.rowHeight = UITableView.automaticDimension
        
        defaultFontSizeLabel.textColor = Settings.currentTheme.bodyTextColor
        defaultFontSizeLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        mediumFontSizeLabel.textColor = Settings.currentTheme.bodyTextColor
        mediumFontSizeLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        largeFontSizeLabel.textColor = Settings.currentTheme.bodyTextColor
        largeFontSizeLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        
        simpleNavigationBarView?.setTitle("Font Size")
        tableView.contentInset = UIEdgeInsets(top: baseNavigationBarViewHeightWithoutTopInset - 1, left: 0, bottom: 0, right: 0)
    }
    
    private func didTapDefaultFontSizeTableViewCell() {
        setCurrentFontSize(.default)
    }
    
    private func didTapMediumFontSizeTableViewCell() {
        setCurrentFontSize(.medium)
    }
    
    private func didTapLargeFontSizeTableViewCell() {
        setCurrentFontSize(.large)
    }
    
    private func setCurrentFontSize(_ selectedFontSize: FontSize) {
        var selectedFontSizeTableViewCell: BaseTableViewCell?
        
        switch selectedFontSize {
        case .default: selectedFontSizeTableViewCell = defaultFontSizeTableViewCell
        case .medium: selectedFontSizeTableViewCell = mediumFontSizeTableViewCell
        case .large: selectedFontSizeTableViewCell = largeFontSizeTableViewCell
        }
        
        fontSizeTableViewCells.forEach { (eachThemeTableViewCell) in
            if eachThemeTableViewCell == selectedFontSizeTableViewCell {
                eachThemeTableViewCell.accessoryType = .checkmark
            } else {
                eachThemeTableViewCell.accessoryType = .none
            }
        }
        
        UserDefaults.setFontSize(selectedFontSize)
        delegate?.didChangeFontSize()
        
        displayRestartAlert()
        
        Analytics.logEvent("change_font_size", parameters: nil)
    }
}

//MARK: - UITableViewDelegate
extension FontSizeListTableViewController {
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedCell = tableView.cellForRow(at: indexPath)
        if selectedCell == defaultFontSizeTableViewCell {
            didTapDefaultFontSizeTableViewCell()
        } else if selectedCell == mediumFontSizeTableViewCell {
            didTapMediumFontSizeTableViewCell()
        } else if selectedCell == largeFontSizeTableViewCell {
            didTapLargeFontSizeTableViewCell()
        }
    }
}

//MARK: - UITableViewDatasource
extension FontSizeListTableViewController {
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        switch UserDefaults.selectedFontSize() {
        case .default:
            if cell == defaultFontSizeTableViewCell {
                cell.accessoryType = .checkmark
            }
        case .medium:
            if cell == mediumFontSizeTableViewCell {
                cell.accessoryType = .checkmark
            }
        case .large:
            if cell == largeFontSizeTableViewCell {
                cell.accessoryType = .checkmark
            }
        }
    }
}
