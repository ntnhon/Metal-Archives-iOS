//
//  AdvancedSearchCountryListViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 11/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

protocol AdvancedSearchCountryListViewControllerDelegate: class {
    func didUpdateSelectedCountries(_ selectedCountries: [Country])
}

final class AdvancedSearchCountryListViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!

    private var countrySectionsDictionary: [Character: [Country]]!
    private var countrySectionsDictionarySortedKeys: [Character]!

    var selectedCountries: [Country] = [] {
        didSet {
            delegate?.didUpdateSelectedCountries(selectedCountries)
        }
    }

    weak var delegate: AdvancedSearchCountryListViewControllerDelegate?
    weak var navigationBar: SimpleNavigationBarView?

    override func viewDidLoad() {
        super.viewDidLoad()
        updateTitle()
        initCountrySectionsDictionary()
        updateDeselectAllBarButtonVisibility()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBar?.setRightButtonIcon(nil)
    }

    private func initCountrySectionsDictionary() {
        countrySectionsDictionary = [:]
        sortedCountryList.forEach {
            let firstChar = $0.name[0]
            if countrySectionsDictionary[firstChar] == nil {
                countrySectionsDictionary[firstChar] = []
            }
            
            countrySectionsDictionary[firstChar]?.append($0)
        }
        countrySectionsDictionarySortedKeys = countrySectionsDictionary.keys.sorted()
    }

    override func initAppearance() {
        super.initAppearance()
        tableView.contentInset = .init(top: baseNavigationBarViewHeightWithoutTopInset,
                                       left: 0,
                                       bottom: 0,
                                       right: 0)
        tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        tableView.rowHeight = UITableView.automaticDimension
        SimpleTableViewCell.register(with: tableView)
    }

    private func updateTitle() {
        switch selectedCountries.count {
        case 0: navigationBar?.setTitle("Any country")
        case 1: navigationBar?.setTitle("1 country selected")
        default: navigationBar?.setTitle("\(selectedCountries.count) countries selected")
        }
    }

    private func updateDeselectAllBarButtonVisibility() {
        if selectedCountries.isEmpty {
            navigationBar?.setRightButtonIcon(nil)
        } else {
            navigationBar?.setRightButtonIcon(UIImage(named: ""))
        }
    }

    @objc
    private func didTapDeselectAllBarButtonItem() {
        selectedCountries.removeAll()
        tableView.reloadData()
        updateTitle()
    }
}

// MARK: - UITableViewDelegate
extension AdvancedSearchCountryListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let char = countrySectionsDictionarySortedKeys[indexPath.section]
        guard let selectedCountry = countrySectionsDictionary[char]?[indexPath.row] else { return }
        let selectedCell = tableView.cellForRow(at: indexPath)
        if selectedCountries.contains(selectedCountry) {
            selectedCountries.removeAll { $0 == selectedCountry }
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
        countrySectionsDictionarySortedKeys.map { "\($0)" }
    }

    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        index
    }
}

// MARK: - UITableViewDataSource
extension AdvancedSearchCountryListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        countrySectionsDictionarySortedKeys.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let char = countrySectionsDictionarySortedKeys[section]
        return countrySectionsDictionary[char]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let char = countrySectionsDictionarySortedKeys[indexPath.section]
        guard let country = countrySectionsDictionary[char]?[indexPath.row] else {
            return UITableViewCell()
        }
        let cell = SimpleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.displayAsSecondaryTitle()
        cell.accessoryType = selectedCountries.contains(country) ? .checkmark : .none
        cell.fill(with: "\(country.nameAndEmoji)")
        return cell
    }
}
