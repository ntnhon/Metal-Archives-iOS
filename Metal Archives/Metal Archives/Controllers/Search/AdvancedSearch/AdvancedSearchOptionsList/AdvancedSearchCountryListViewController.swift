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
            updateDeselectAllBarButtonVisibility()
            delegate?.didUpdateSelectedCountries(selectedCountries)
        }
    }
    
    var delegate: AdvancedSearchCountryListViewControllerDelegate?
    
    weak var simpleNavigationBarView: SimpleNavigationBarView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTitle()
        initCountrySectionsDictionary()
        initDeselectAllBarButtonItem()
        updateDeselectAllBarButtonVisibility()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        simpleNavigationBarView?.setRightButtonIcon(nil)
    }
    
    private func initCountrySectionsDictionary() {
        countrySectionsDictionary = [:]
        sortedCountryList.forEach({
            let firstChar = $0.name[0]
            if countrySectionsDictionary[firstChar] == nil {
                countrySectionsDictionary[firstChar] = []
            }
            
            countrySectionsDictionary[firstChar]?.append($0)
        })
        
        countrySectionsDictionarySortedKeys = countrySectionsDictionary.keys.sorted()
    }
    
    override func initAppearance() {
        super.initAppearance()
        tableView.contentInset = UIEdgeInsets(top: baseNavigationBarViewHeightWithoutTopInset, left: 0, bottom: 0, right: 0)
        tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        tableView.rowHeight = UITableView.automaticDimension
        
        SimpleTableViewCell.register(with: tableView)
    }
    
    private func updateTitle() {
        if selectedCountries.count == 0 {
            simpleNavigationBarView?.setTitle("Any country")
        } else if selectedCountries.count == 1 {
            simpleNavigationBarView?.setTitle("1 country selected")
        } else {
            simpleNavigationBarView?.setTitle("\(selectedCountries.count) countries selected")
        }
    }
    
    private func updateDeselectAllBarButtonVisibility() {
        if selectedCountries.count > 0 {
            navigationItem.rightBarButtonItem = deselectAllBarButtonItem
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    private func initDeselectAllBarButtonItem() {
        deselectAllBarButtonItem = UIBarButtonItem(title: "Deselect All", style: .plain, target: self, action: #selector(didTapDeselectAllBarButtonItem))
    }
    
    @objc private func didTapDeselectAllBarButtonItem() {
        selectedCountries.removeAll()
        tableView.reloadData()
        updateTitle()
    }
}

//MARK: - UITableViewDelegate
extension AdvancedSearchCountryListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let char = countrySectionsDictionarySortedKeys[indexPath.section]
        let selectedCountry = countrySectionsDictionary[char]![indexPath.row]
        
        let selectedCell = tableView.cellForRow(at: indexPath)
        
        if selectedCountries.contains(selectedCountry) {
            selectedCountries.removeAll(where: {$0 == selectedCountry})
            selectedCell?.accessoryType = .none
        } else {
            selectedCountries.append(selectedCountry)
            selectedCell?.accessoryType = .checkmark
        }
        
        updateTitle()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let char = countrySectionsDictionarySortedKeys[section]
        return "\(char)"
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return countrySectionsDictionarySortedKeys.map({return "\($0)"})
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
}

//MARK: - UITableViewDataSource
extension AdvancedSearchCountryListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return countrySectionsDictionarySortedKeys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let char = countrySectionsDictionarySortedKeys[section]
        return countrySectionsDictionary[char]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SimpleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.displayAsSecondaryTitle()
        
        let char = countrySectionsDictionarySortedKeys[indexPath.section]
        let country = countrySectionsDictionary[char]![indexPath.row]
        
        if selectedCountries.contains(country) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        cell.fill(with: "\(country.nameAndEmoji)")
        return cell
    }
}
