//
//  ChooseWidgetSectionsViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 21/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

protocol ChooseWidgetSectionsViewControllerDelegate {
    func didChooseWidgetSections(_ widgetSections: [WidgetSection])
}

final class ChooseWidgetSectionsViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    private var choosenWidgetSections: [WidgetSection]! {
        didSet {
            updateTitle()
            delegate?.didChooseWidgetSections(choosenWidgetSections)
            UserDefaults.setWidgetSections(choosenWidgetSections)
        }
    }
    
    // SimpleNavigationBarView
    weak var simpleNavigationBarView: SimpleNavigationBarView?
    
    var delegate: ChooseWidgetSectionsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        choosenWidgetSections = UserDefaults.choosenWidgetSections()
    }
    
    override func initAppearance() {
        super.initAppearance()
        tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        
        SimpleTableViewCell.register(with: tableView)
        
        tableView.contentInset = UIEdgeInsets(top: baseNavigationBarViewHeightWithoutTopInset - 1, left: 0, bottom: 0, right: 0)
    }
    
    private func updateTitle() {
        if choosenWidgetSections.count == 1 {
            simpleNavigationBarView?.setTitle("\(choosenWidgetSections[0].description)")
        } else if choosenWidgetSections.count == 2 {
            simpleNavigationBarView?.setTitle("\(choosenWidgetSections[0].description), \(choosenWidgetSections[1].description)")
        }
    }
    
    private func alertMaximumError() {
        let alert = UIAlertController(title: "Oops!!!", message: "You can only choose up to 2 sections at a time.", preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        alert.addAction(okayAction)
        present(alert, animated: true, completion: nil)
    }
}

//MARK: - UITableViewDelegate
extension ChooseWidgetSectionsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedWidgetSection = WidgetSection.allCases[indexPath.row]
        
        if choosenWidgetSections.contains(selectedWidgetSection) && choosenWidgetSections.count == 2 {
            choosenWidgetSections.removeAll { (widgetSection) -> Bool in
                widgetSection == selectedWidgetSection
            }
            tableView.reloadData()
        } else if !choosenWidgetSections.contains(selectedWidgetSection) && choosenWidgetSections.count == 1 {
            choosenWidgetSections.append(selectedWidgetSection)
            tableView.reloadData()
        } else if !choosenWidgetSections.contains(selectedWidgetSection) && choosenWidgetSections.count == 2 {
            alertMaximumError()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Widget Sections"
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "You can pick up to 2 sections.\nIf you pick only 1 section, the widget will display 5 results.\nIf you pick 2 sections, the widget will display 3 results for each section.\nOrders matter."
    }
}

//MARK: - UITableViewDataSource
extension ChooseWidgetSectionsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WidgetSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SimpleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.displayAsSecondaryTitle()
        let widgetSection = WidgetSection.allCases[indexPath.row]
        cell.fill(with: widgetSection.description)
        
        if choosenWidgetSections.contains(widgetSection) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
}
