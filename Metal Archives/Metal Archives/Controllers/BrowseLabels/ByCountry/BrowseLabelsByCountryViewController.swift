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
    @IBOutlet private weak var simpleNavigationBarView: SimpleNavigationBarView!
    @IBOutlet private weak var tableView: UITableView!
    
    private var countrySectionsDictionary: [Character: [Country?]]!
    private var countrySectionsDictionarySortedKeys: [Character]!
    override func viewDidLoad() {
        initCountrySectionsDictionary()
        super.viewDidLoad()
    }
    
    override func initAppearance() {
        super.initAppearance()
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.contentInset = UIEdgeInsets(top: baseNavigationBarViewHeightWithoutTopInset, left: 0, bottom: UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0, right: 0)
        
        tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        
        ViewMoreTableViewCell.register(with: tableView)
        initSimpleNavigationBarView()
    }
    
    private func initSimpleNavigationBarView() {
        simpleNavigationBarView.setAlphaForBackgroundAndTitleLabel(1)
        simpleNavigationBarView.setTitle("Browse Labels - By Country")
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
        
        //Add "No country"
        countrySectionsDictionarySortedKeys.insert("#", at: 0)
        countrySectionsDictionary["#"]?.append(nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let browseLabelsByCountryResultViewController as BrowseLabelsByCountryResultViewController:
            guard let country = sender as? Country? else {
                break
            }
            browseLabelsByCountryResultViewController.country = country
            
            if let `country` = country {
                navigationItem.backBarButtonItem = UIBarButtonItem(title: country.nameAndEmoji, style: .plain, target: nil, action: nil)
                
                Analytics.logEvent("perform_browse_labels_by_country", parameters: ["Module": "By country", "country": country.iso])
            } else {
                navigationItem.backBarButtonItem = UIBarButtonItem(title: "(No country)", style: .plain, target: nil, action: nil)
                
                Analytics.logEvent("perform_browse_labels_by_country", parameters: ["Module": "By country", "country": "No country"])
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
        
        let char = countrySectionsDictionarySortedKeys[indexPath.section]
        
        var selectedCountry: Country? = nil
        if let countries = countrySectionsDictionary[char], let country = countries[indexPath.row] {
            selectedCountry = country
        }
        
        performSegue(withIdentifier: "ShowResults", sender: selectedCountry)
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
extension BrowseLabelsByCountryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return countrySectionsDictionarySortedKeys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let char = countrySectionsDictionarySortedKeys[section]
        if let countries = countrySectionsDictionary[char] {
            return countries.count
        }
        
        //"No country" row
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ViewMoreTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.displayAsSecondaryTitle()
        
        let char = countrySectionsDictionarySortedKeys[indexPath.section]
        if let countries = countrySectionsDictionary[char], let country = countries[indexPath.row] {
            cell.fill(message: country.nameAndEmoji)
        } else {
            cell.fill(message: "(No country)")
        }
    
        return cell
    }
}
