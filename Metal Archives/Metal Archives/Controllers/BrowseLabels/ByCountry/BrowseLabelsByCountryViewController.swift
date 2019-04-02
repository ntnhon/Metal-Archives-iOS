//
//  BrowseLabelsByCountryViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 20/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import FirebaseAnalytics

final class BrowseLabelsByCountryViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    private var countrySectionsDictionary: [Character: [Country?]]!
    private var countrySectionsDictionarySortedKeys: [Character]!
    override func viewDidLoad() {
        self.initCountrySectionsDictionary()
        super.viewDidLoad()
        self.title = "Browse Labels - By Country"
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
        
        //Add "No country"
        self.countrySectionsDictionarySortedKeys.insert("#", at: 0)
        self.countrySectionsDictionary["#"]?.append(nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let browseLabelsByCountryResultViewController as BrowseLabelsByCountryResultViewController:
            guard let country = sender as? Country? else {
                break
            }
            browseLabelsByCountryResultViewController.country = country
            
            if let `country` = country {
                self.navigationItem.backBarButtonItem = UIBarButtonItem(title: country.nameAndEmoji, style: .plain, target: nil, action: nil)
                
                Analytics.logEvent(AnalyticsEvent.PerformBrowseLabels, parameters: ["Module": "By country", AnalyticsParameter.Country: country.iso])
            } else {
                self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "(No country)", style: .plain, target: nil, action: nil)
                
                Analytics.logEvent(AnalyticsEvent.PerformBrowseLabels, parameters: ["Module": "By country", AnalyticsParameter.Country: "No country"])
            }
            
        default:
            break
        }
    }
}

//MARK: - UITableViewDelegate
extension BrowseLabelsByCountryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let char = self.countrySectionsDictionarySortedKeys[indexPath.section]
        
        var selectedCountry: Country? = nil
        if let countries = self.countrySectionsDictionary[char], let country = countries[indexPath.row] {
            selectedCountry = country
        }
        
        self.performSegue(withIdentifier: "ShowResults", sender: selectedCountry)
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
extension BrowseLabelsByCountryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.countrySectionsDictionarySortedKeys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let char = self.countrySectionsDictionarySortedKeys[section]
        if let countries = self.countrySectionsDictionary[char] {
            return countries.count
        }
        
        //"No country" row
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ViewMoreTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.displayAsSecondaryTitle()
        
        let char = self.countrySectionsDictionarySortedKeys[indexPath.section]
        if let countries = self.countrySectionsDictionary[char], let country = countries[indexPath.row] {
            cell.fill(message: country.nameAndEmoji)
        } else {
            cell.fill(message: "(No country)")
        }
    
        return cell
    }
}
