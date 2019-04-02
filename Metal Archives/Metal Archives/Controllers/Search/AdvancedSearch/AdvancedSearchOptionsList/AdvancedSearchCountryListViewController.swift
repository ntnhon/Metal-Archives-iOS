//
//  AdvancedSearchCountryListViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 11/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

protocol AdvancedSearchCountryListViewControllerDelegate {
    func didUpdateSelectedCountries(_ selectedCountries: [Country])
}

final class AdvancedSearchCountryListViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    private var deselectAllBarButtonItem: UIBarButtonItem!
    
    private var countrySectionsDictionary: [Character: [Country]]!
    private var countrySectionsDictionarySortedKeys: [Character]!
    
    var selectedCountries: [Country] = [] {
        didSet {
            self.updateDeselectAllBarButtonVisibility()
            self.delegate?.didUpdateSelectedCountries(self.selectedCountries)
        }
    }
    
    var delegate: AdvancedSearchCountryListViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateTitle()
        self.initCountrySectionsDictionary()
        self.initDeselectAllBarButtonItem()
        self.updateDeselectAllBarButtonVisibility()
    }
    
    private func initCountrySectionsDictionary() {
        self.countrySectionsDictionary = [:]
        sortedCountryList.forEach({
            let firstChar = $0.name[0]
            if self.countrySectionsDictionary[firstChar] == nil {
                self.countrySectionsDictionary[firstChar] = []
            }
            
            self.countrySectionsDictionary[firstChar]?.append($0)
        })
        
        self.countrySectionsDictionarySortedKeys = self.countrySectionsDictionary.keys.sorted()
    }
    
    override func initAppearance() {
        super.initAppearance()
        self.tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        self.tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        self.tableView.rowHeight = UITableView.automaticDimension
        
        SimpleTableViewCell.register(with: self.tableView)
    }
    
    private func updateTitle() {
        if self.selectedCountries.count == 0 {
            self.title = "Any country"
        } else if self.selectedCountries.count == 1 {
            self.title = "1 country selected"
        } else {
            self.title = "\(self.selectedCountries.count) countries selected"
        }
    }
    
    private func updateDeselectAllBarButtonVisibility() {
        if self.selectedCountries.count > 0 {
            self.navigationItem.rightBarButtonItem = self.deselectAllBarButtonItem
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    private func initDeselectAllBarButtonItem() {
        self.deselectAllBarButtonItem = UIBarButtonItem(title: "Deselect All", style: .plain, target: self, action: #selector(didTapDeselectAllBarButtonItem))
    }
    
    @objc private func didTapDeselectAllBarButtonItem() {
        self.selectedCountries.removeAll()
        self.tableView.reloadData()
        self.updateTitle()
    }
}

//MARK: - UITableViewDelegate
extension AdvancedSearchCountryListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let char = self.countrySectionsDictionarySortedKeys[indexPath.section]
        let selectedCountry = self.countrySectionsDictionary[char]![indexPath.row]
        
        let selectedCell = self.tableView.cellForRow(at: indexPath)
        
        if self.selectedCountries.contains(selectedCountry) {
            self.selectedCountries.removeAll(where: {$0 == selectedCountry})
            selectedCell?.accessoryType = .none
        } else {
            self.selectedCountries.append(selectedCountry)
            selectedCell?.accessoryType = .checkmark
        }
        
        self.updateTitle()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let char = self.countrySectionsDictionarySortedKeys[section]
        return "\(char)"
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.countrySectionsDictionarySortedKeys.map({return "\($0)"})
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
}

//MARK: - UITableViewDataSource
extension AdvancedSearchCountryListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.countrySectionsDictionarySortedKeys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let char = self.countrySectionsDictionarySortedKeys[section]
        return self.countrySectionsDictionary[char]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SimpleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.displayAsSecondaryTitle()
        
        let char = self.countrySectionsDictionarySortedKeys[indexPath.section]
        let country = self.countrySectionsDictionary[char]![indexPath.row]
        
        if self.selectedCountries.contains(country) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        cell.fill(with: "\(country.nameAndEmoji)")
        return cell
    }
}
