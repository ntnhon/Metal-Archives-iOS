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
            self.updateTitle()
            self.delegate?.didChooseWidgetSections(self.choosenWidgetSections)
            UserDefaults.setWidgetSections(self.choosenWidgetSections)
        }
    }
    
    var delegate: ChooseWidgetSectionsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.choosenWidgetSections = UserDefaults.choosenWidgetSections()
    }
    
    override func initAppearance() {
        super.initAppearance()
        self.tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        self.tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.tableFooterView = UIView(frame: .zero)
        
        SimpleTableViewCell.register(with: self.tableView)
    }
    
    private func updateTitle() {
        if self.choosenWidgetSections.count == 1 {
            self.title = "\(self.choosenWidgetSections[0].description)"
        } else if self.choosenWidgetSections.count == 2 {
            self.title = "\(self.choosenWidgetSections[0].description), \(self.choosenWidgetSections[1].description)"
        }
    }
    
    private func alertMaximumError() {
        let alert = UIAlertController(title: "Oops!!!", message: "You can only choose up to 2 sections at a time.", preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        alert.addAction(okayAction)
        self.present(alert, animated: true, completion: nil)
    }
}

//MARK: - UITableViewDelegate
extension ChooseWidgetSectionsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedWidgetSection = WidgetSection.allCases[indexPath.row]
        
        if self.choosenWidgetSections.contains(selectedWidgetSection) && self.choosenWidgetSections.count == 2 {
            self.choosenWidgetSections.removeAll { (widgetSection) -> Bool in
                widgetSection == selectedWidgetSection
            }
            tableView.reloadData()
        } else if !self.choosenWidgetSections.contains(selectedWidgetSection) && self.choosenWidgetSections.count == 1 {
            self.choosenWidgetSections.append(selectedWidgetSection)
            tableView.reloadData()
        } else if !self.choosenWidgetSections.contains(selectedWidgetSection) && self.choosenWidgetSections.count == 2 {
            self.alertMaximumError()
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
        
        if self.choosenWidgetSections.contains(widgetSection) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
}
