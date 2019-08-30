//
//  DiscographyTypeListTableViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 09/04/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

protocol DiscographyTypeListTableViewControllerDelegate {
    func didChangeDiscographyType()
}

final class DiscographyTypeListTableViewController: BaseSubSettingsTableViewController {
    @IBOutlet private weak var completeTableViewCell: BaseTableViewCell!
    @IBOutlet private weak var mainTableViewCell: BaseTableViewCell!
    @IBOutlet private weak var livesTableViewCell: BaseTableViewCell!
    @IBOutlet private weak var demosTableViewCell: BaseTableViewCell!
    @IBOutlet private weak var miscTableViewCell: BaseTableViewCell!
    
    @IBOutlet private var discographyTypeTableViewCells: [BaseTableViewCell]!
    @IBOutlet private var titleLabels: [UILabel]!
    
    var delegate: DiscographyTypeListTableViewControllerDelegate?
    
    deinit {
        print("DiscographyTypeListTableViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initAppearance()
    }
    
    override func initAppearance() {
        super.initAppearance()
        
        titleLabels.forEach({
            $0.textColor = Settings.currentTheme.bodyTextColor
            $0.font = Settings.currentFontSize.bodyTextFont
        })
        
        simpleNavigationBarView?.setTitle("Default Discography Mode")
    }
    
    private func didTapCompleteTableViewCell() {
        setCurrentDiscographyType(.complete)
    }
    
    private func didTapMainTableViewCell() {
        setCurrentDiscographyType(.main)
    }
    
    private func didTapLivesTableViewCell() {
        setCurrentDiscographyType(.lives)
    }
    
    private func didTapDemosTableViewCell() {
        setCurrentDiscographyType(.demos)
    }
    
    private func didTapMiscTableViewCell() {
        setCurrentDiscographyType(.misc)
    }
    
    private func setCurrentDiscographyType(_ selectedDiscographyType: DiscographyType) {
        var selectedDiscographyTypeTableViewCell: BaseTableViewCell?
        
        switch selectedDiscographyType {
        case .complete: selectedDiscographyTypeTableViewCell = completeTableViewCell
        case .main: selectedDiscographyTypeTableViewCell = mainTableViewCell
        case .lives: selectedDiscographyTypeTableViewCell = livesTableViewCell
        case .demos: selectedDiscographyTypeTableViewCell = demosTableViewCell
        case .misc: selectedDiscographyTypeTableViewCell = miscTableViewCell
        }
        
        discographyTypeTableViewCells.forEach { (eachDiscographyTypeTableViewCells) in
            if eachDiscographyTypeTableViewCells == selectedDiscographyTypeTableViewCell {
                eachDiscographyTypeTableViewCells.accessoryType = .checkmark
            } else {
                eachDiscographyTypeTableViewCells.accessoryType = .none
            }
        }
        
        UserDefaults.setDiscographyType(selectedDiscographyType)
        delegate?.didChangeDiscographyType()
    }
}

//MARK: - UITableViewDelegate
extension DiscographyTypeListTableViewController {
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedCell = tableView.cellForRow(at: indexPath)
        if selectedCell == completeTableViewCell {
            didTapCompleteTableViewCell()
        } else if selectedCell == mainTableViewCell {
            didTapMainTableViewCell()
        } else if selectedCell == livesTableViewCell {
            didTapLivesTableViewCell()
        } else if selectedCell == demosTableViewCell {
            didTapDemosTableViewCell()
        } else if selectedCell == miscTableViewCell {
            didTapMiscTableViewCell()
        }
    }
}

//MARK: - UITableViewDatasource
extension DiscographyTypeListTableViewController {
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        switch UserDefaults.selectedDiscographyType() {
        case .complete:
            if cell == completeTableViewCell {
                cell.accessoryType = .checkmark
            }
        case .main:
            if cell == mainTableViewCell {
                cell.accessoryType = .checkmark
            }
        case .lives:
            if cell == livesTableViewCell {
                cell.accessoryType = .checkmark
            }
        case .demos:
            if cell == demosTableViewCell {
                cell.accessoryType = .checkmark
            }
        case .misc:
            if cell == miscTableViewCell {
                cell.accessoryType = .checkmark
            }
        }

    }
}
