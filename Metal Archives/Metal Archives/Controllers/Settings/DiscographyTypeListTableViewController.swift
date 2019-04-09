//
//  DiscographyTypeListTableViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 09/04/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import FirebaseAnalytics

protocol DiscographyTypeListTableViewControllerDelegate {
    func didChangeDiscographyType()
}

final class DiscographyTypeListTableViewController: UITableViewController {
    @IBOutlet private weak var completeTableViewCell: BaseTableViewCell!
    @IBOutlet private weak var mainTableViewCell: BaseTableViewCell!
    @IBOutlet private weak var livesTableViewCell: BaseTableViewCell!
    @IBOutlet private weak var demosTableViewCell: BaseTableViewCell!
    @IBOutlet private weak var miscTableViewCell: BaseTableViewCell!
    
    @IBOutlet private var discographyTypeTableViewCells: [BaseTableViewCell]!
    @IBOutlet private var titleLabels: [UILabel]!
    
    var delegate: DiscographyTypeListTableViewControllerDelegate?
    
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
        
        self.title = "Default Discography Mode"
    }
    
    private func didTapCompleteTableViewCell() {
        self.setCurrentDiscographyType(.complete)
    }
    
    private func didTapMainTableViewCell() {
        self.setCurrentDiscographyType(.main)
    }
    
    private func didTapLivesTableViewCell() {
        self.setCurrentDiscographyType(.lives)
    }
    
    private func didTapDemosTableViewCell() {
        self.setCurrentDiscographyType(.demos)
    }
    
    private func didTapMiscTableViewCell() {
        self.setCurrentDiscographyType(.misc)
    }
    
    private func setCurrentDiscographyType(_ selectedDiscographyType: DiscographyType) {
        var selectedDiscographyTypeTableViewCell: BaseTableViewCell?
        
        switch selectedDiscographyType {
        case .complete: selectedDiscographyTypeTableViewCell = self.completeTableViewCell
        case .main: selectedDiscographyTypeTableViewCell = self.mainTableViewCell
        case .lives: selectedDiscographyTypeTableViewCell = self.livesTableViewCell
        case .demos: selectedDiscographyTypeTableViewCell = self.demosTableViewCell
        case .misc: selectedDiscographyTypeTableViewCell = self.miscTableViewCell
        }
        
        self.discographyTypeTableViewCells.forEach { (eachDiscographyTypeTableViewCells) in
            if eachDiscographyTypeTableViewCells == selectedDiscographyTypeTableViewCell {
                eachDiscographyTypeTableViewCells.accessoryType = .checkmark
            } else {
                eachDiscographyTypeTableViewCells.accessoryType = .none
            }
        }
        
        UserDefaults.setDiscographyType(selectedDiscographyType)
        self.delegate?.didChangeDiscographyType()
        
        Analytics.logEvent(AnalyticsEvent.ChangeDefaultDiscographyType, parameters: nil)
    }
}

//MARK: - UITableViewDelegate
extension DiscographyTypeListTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedCell = tableView.cellForRow(at: indexPath)
        if selectedCell == self.completeTableViewCell {
            self.didTapCompleteTableViewCell()
        } else if selectedCell == self.mainTableViewCell {
            self.didTapMainTableViewCell()
        } else if selectedCell == self.livesTableViewCell {
            self.didTapLivesTableViewCell()
        } else if selectedCell == self.demosTableViewCell {
            self.didTapDemosTableViewCell()
        } else if selectedCell == self.miscTableViewCell {
            self.didTapMiscTableViewCell()
        }
    }
}

//MARK: - UITableViewDatasource
extension DiscographyTypeListTableViewController {
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        switch UserDefaults.selectedDiscographyType() {
        case .complete:
            if cell == self.completeTableViewCell {
                cell.accessoryType = .checkmark
            }
        case .main:
            if cell == self.mainTableViewCell {
                cell.accessoryType = .checkmark
            }
        case .lives:
            if cell == self.livesTableViewCell {
                cell.accessoryType = .checkmark
            }
        case .demos:
            if cell == self.demosTableViewCell {
                cell.accessoryType = .checkmark
            }
        case .misc:
            if cell == self.miscTableViewCell {
                cell.accessoryType = .checkmark
            }
        }

    }
}
