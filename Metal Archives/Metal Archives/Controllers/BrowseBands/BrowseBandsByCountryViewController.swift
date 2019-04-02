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
    @IBOutlet private weak var tableView: UITableView!
    
    private var countrySectionsDictionary: [Character: [Country]]!
    private var countrySectionsDictionarySortedKeys: [Character]!
    
    override func viewDidLoad() {
        
        self.initCountrySectionsDictionary()//I don't why this should be put before viewDidLoad, cause put it after makes tableView datasource being called and crash the app.
        super.viewDidLoad()
        self.title = "Browse Bands - By Country"
        
    }
    
    override func initAppearance() {
        super.initAppearance()
        self.tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        self.tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.tableFooterView = UIView(frame: .zero)
        
        ViewMoreTableViewCell.register(with: self.tableView)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let bandAphabeticallyResultViewController as BrowseBandsResultViewController:
            if let country = sender as? Country {
                bandAphabeticallyResultViewController.parameter = "ajax-country/c/" + country.iso
                bandAphabeticallyResultViewController.context = "Bands from \(country.nameAndEmoji)"
                
                Analytics.logEvent(AnalyticsEvent.PerformBrowseBands, parameters: [AnalyticsParameter.Country: country.iso])
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
        
        let char = self.countrySectionsDictionarySortedKeys[indexPath.section]
        let selectedCountry = self.countrySectionsDictionary[char]![indexPath.row]
        
        self.performSegue(withIdentifier: "ShowResults", sender: selectedCountry)
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
extension BrowseBandsByCountryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.countrySectionsDictionarySortedKeys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let char = self.countrySectionsDictionarySortedKeys[section]
        return self.countrySectionsDictionary[char]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ViewMoreTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.displayAsSecondaryTitle()
        
        let char = self.countrySectionsDictionarySortedKeys[indexPath.section]
        let country = self.countrySectionsDictionary[char]![indexPath.row]
        
        cell.fill(message: country.nameAndEmoji)
        return cell
    }
}
