//
//  BrowseBandsAlphabeticallyViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 13/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import FirebaseAnalytics

final class BrowseBandsByCountryViewController: BaseViewController {
    @IBOutlet private weak var simpleNavigationBarView: SimpleNavigationBarView!
    @IBOutlet private weak var tableView: UITableView!
    
    private var countrySectionsDictionary: [Character: [Country]]!
    private var countrySectionsDictionarySortedKeys: [Character]!
    
    override func viewDidLoad() {
        
        initCountrySectionsDictionary()//I don't why this should be put before viewDidLoad, cause put it after makes tableView datasource being called and crash the app.
        super.viewDidLoad()
    }

    override func initAppearance() {
        super.initAppearance()
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.contentInset = UIEdgeInsets(top: baseNavigationBarViewHeightWithoutTopInset, left: 0, bottom: 0, right: 0)
        
        tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        
        ViewMoreTableViewCell.register(with: tableView)
        initSimpleNavigationBarView()
    }
    
    private func initSimpleNavigationBarView() {
        simpleNavigationBarView.setAlphaForBackgroundAndTitleLabel(1)
        simpleNavigationBarView.setTitle("Browse Bands - By Country")
        simpleNavigationBarView.setRightButtonIcon(nil)
        
        simpleNavigationBarView.didTapLeftButton = { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let bandAphabeticallyResultViewController as BrowseBandsResultViewController:
            if let country = sender as? Country {
                bandAphabeticallyResultViewController.parameter = "ajax-country/c/" + country.iso
                bandAphabeticallyResultViewController.context = "Bands from \(country.nameAndEmoji)"
                
                Analytics.logEvent("perform_browse_bands_by_country", parameters: ["country": country.iso])
            }
        default:
            break
        }
    }
}

//MARK: - UITableViewDelegate
extension BrowseBandsByCountryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let char = countrySectionsDictionarySortedKeys[indexPath.section]
        let selectedCountry = countrySectionsDictionary[char]![indexPath.row]
        
        performSegue(withIdentifier: "ShowResults", sender: selectedCountry)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = Settings.currentTheme.titleColor
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let footerView = view as? UITableViewHeaderFooterView {
            footerView.textLabel?.textColor = Settings.currentTheme.titleColor
        }
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
extension BrowseBandsByCountryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return countrySectionsDictionarySortedKeys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let char = countrySectionsDictionarySortedKeys[section]
        return countrySectionsDictionary[char]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ViewMoreTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.displayAsSecondaryTitle()
        
        let char = countrySectionsDictionarySortedKeys[indexPath.section]
        let country = countrySectionsDictionary[char]![indexPath.row]
        
        cell.fill(message: country.nameAndEmoji)
        return cell
    }
}
