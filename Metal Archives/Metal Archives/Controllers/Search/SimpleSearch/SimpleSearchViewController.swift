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
    var isBeingSelected: Bool = true {
        didSet {
            if isBeingSelected {
                self.searchTermTextField.becomeFirstResponder()
            } else {
                self.searchTermTextField.resignFirstResponder()
            }
        }
    }
    
    private let imFeelingLuckyView: ImFeelingLuckyView = .initFromNib()
    private var currentSimpleSearchType: SimpleSearchType = .bandName {
        didSet {
            self.updateSimpleSearchTypeDetailLabel()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imFeelingLuckyView.delegate = self
        self.searchTermTextField.delegate = self
        self.initAppearance()
        self.updateSimpleSearchTypeDetailLabel()
    }
    
    private func initAppearance() {
        self.view.backgroundColor = Settings.currentTheme.backgroundColor
        self.tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        self.tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        self.tableView.rowHeight = UITableView.automaticDimension
        
        self.searchTermTextField.returnKeyType = .search
        self.searchTermTextField.inputAccessoryView = self.imFeelingLuckyView
        
        self.searchTypeTableViewCell.textLabel?.textColor = Settings.currentTheme.secondaryTitleColor
        self.searchTypeTableViewCell.textLabel?.font = Settings.currentFontSize.secondaryTitleFont
        self.searchTypeTableViewCell.textLabel?.text = "Search for"
        
        self.searchTypeTableViewCell.detailTextLabel?.textColor = Settings.currentTheme.bodyTextColor
        self.searchTypeTableViewCell.detailTextLabel?.font = Settings.currentFontSize.bodyTextFont
    }
    
    private func updateSimpleSearchTypeDetailLabel() {
        self.searchTypeTableViewCell.detailTextLabel?.text = self.currentSimpleSearchType.description
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let simpleSearchTypeListVC as SimpleSearchTypeListViewController:
            simpleSearchTypeListVC.currentSimpleSearchType = self.currentSimpleSearchType
            simpleSearchTypeListVC.delegate = self
        case let simpleSearchResultVC as SimpleSearchResultViewController:
            simpleSearchResultVC.searchTerm = self.searchTermTextField.text
            simpleSearchResultVC.simpleSearchType = self.currentSimpleSearchType
            
            if let _ = sender as? ImFeelingLuckyView {
                simpleSearchResultVC.isFeelingLucky = true
                
                Analytics.logEvent(AnalyticsEvent.FeelingLucky, parameters: nil)
            } else {
                simpleSearchResultVC.isFeelingLucky = false
            }
            
            Analytics.logEvent(AnalyticsEvent.PerformSimpleSearch, parameters: [AnalyticsParameter.SearchType: self.currentSimpleSearchType.description, AnalyticsParameter.SearchTerm: self.searchTermTextField.text!])
            
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
}

//MARK: - ImFeelingLuckyViewDelegate
extension SimpleSearchViewController: ImFeelingLuckyViewDelegate {
    func didTapImFeelingLuckyButton() {
        self.performSegue(withIdentifier: "ShowSearchResult", sender: self.imFeelingLuckyView)
    }
}

//MARK: - SimpleSearchTypeListViewControllerDelegate
extension SimpleSearchViewController: SimpleSearchTypeListViewControllerDelegate {
    func didChangeSimpleSearchType(_ simpleSearchType: SimpleSearchType) {
        self.currentSimpleSearchType = simpleSearchType
        
        Analytics.logEvent(AnalyticsEvent.ChangeSimpleSearchType, parameters: [AnalyticsParameter.SearchType: self.currentSimpleSearchType.description])
    }
}

extension SimpleSearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.performSegue(withIdentifier: "ShowSearchResult", sender: self.searchTermTextField)
        return true
    }
}
