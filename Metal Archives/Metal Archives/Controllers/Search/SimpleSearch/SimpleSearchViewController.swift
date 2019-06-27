//
//  SimpleSearchViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import FirebaseAnalytics

final class SimpleSearchViewController: UITableViewController {
    @IBOutlet private weak var searchTermTextField: BaseTextField!
    @IBOutlet private weak var searchTypeTableViewCell: BaseTableViewCell!
    private var horizontalOptionsView: HorizontalOptionsView!
    var isBeingSelected: Bool = true {
        didSet {
            if isBeingSelected {
                searchTermTextField.becomeFirstResponder()
            } else {
                searchTermTextField.resignFirstResponder()
            }
        }
    }
    
    private let imFeelingLuckyView: ImFeelingLuckyView = .initFromNib()
    private var currentSimpleSearchType: SimpleSearchType = .bandName {
        didSet {
            searchTermTextField.placeholder = currentSimpleSearchType.description
            searchTermTextField.title = "Search by \(currentSimpleSearchType.description)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imFeelingLuckyView.delegate = self
        searchTermTextField.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        currentSimpleSearchType = .bandName //trigger didSet
        initHorizontalOptionsView()
        initAppearance()
    }
    
    private func initAppearance() {
        view.backgroundColor = Settings.currentTheme.backgroundColor
        tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        tableView.rowHeight = UITableView.automaticDimension
        
        searchTermTextField.returnKeyType = .search
        searchTermTextField.inputAccessoryView = imFeelingLuckyView
    }
    
    private func initHorizontalOptionsView() {
        let options = SimpleSearchType.allCases.map({$0.description})
        horizontalOptionsView = HorizontalOptionsView(options: options, font: Settings.currentFontSize.bodyTextFont, textColor: Settings.currentTheme.bodyTextColor, normalColor: Settings.currentTheme.backgroundColor, highlightColor: Settings.currentTheme.secondaryTitleColor)
        horizontalOptionsView.delegate = self
        horizontalOptionsView.selectedIndex = currentSimpleSearchType.rawValue
        
        searchTypeTableViewCell.contentView.addSubview(horizontalOptionsView)
        horizontalOptionsView.fillSuperview(padding: .init(top: -10, left: 10, bottom: -10, right:    10))
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let simpleSearchResultVC as SimpleSearchResultViewController:
            simpleSearchResultVC.searchTerm = searchTermTextField.text
            simpleSearchResultVC.simpleSearchType = currentSimpleSearchType

            if let _ = sender as? ImFeelingLuckyView {
                simpleSearchResultVC.isFeelingLucky = true
                
                Analytics.logEvent(AnalyticsEvent.FeelingLucky, parameters: nil)
            } else {
                simpleSearchResultVC.isFeelingLucky = false
            }
            
            Analytics.logEvent(AnalyticsEvent.PerformSimpleSearch, parameters: [AnalyticsParameter.SearchType: currentSimpleSearchType.description, AnalyticsParameter.SearchTerm: searchTermTextField.text!])
            
        default:
            break
        }
    }
}

extension SimpleSearchViewController {
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = Settings.currentTheme.titleColor
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let footerView = view as? UITableViewHeaderFooterView {
            footerView.textLabel?.textColor = Settings.currentTheme.titleColor
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

//MARK: - ImFeelingLuckyViewDelegate
extension SimpleSearchViewController: ImFeelingLuckyViewDelegate {
    func didTapImFeelingLuckyButton() {
        performSegue(withIdentifier: "ShowSearchResult", sender: imFeelingLuckyView)
    }
}

//MARK: - HorizontalOptionsViewDelegate
extension SimpleSearchViewController: HorizontalOptionsViewDelegate {
    func horizontalOptionsView(_ horizontalOptionsView: HorizontalOptionsView, didSelectItemAt index: Int) {
        currentSimpleSearchType = SimpleSearchType(rawValue: index) ?? .bandName
        
        Analytics.logEvent(AnalyticsEvent.ChangeSimpleSearchType, parameters: [AnalyticsParameter.SearchType: currentSimpleSearchType.description])
    }
}

// MARK: - UITextFieldDelegate
extension SimpleSearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        performSegue(withIdentifier: "ShowSearchResult", sender: searchTermTextField)
        return true
    }
}
