//
//  AdvancedSearchViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class AdvancedSearchViewController: UITableViewController {
    @IBOutlet private var advancedSearchTypeLabels: [UILabel]!
    var isBeingSelected: Bool = false {
        didSet {
            if isBeingSelected {
                //print("Advanced Search")
            }
        }
    }    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initAppearance()
    }
    
    private func initAppearance() {
        view.backgroundColor = Settings.currentTheme.backgroundColor
        tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        tableView.rowHeight = UITableView.automaticDimension
        tableView.contentInset = .init(top: -2, left: 0, bottom: 0, right: 0)
        
        advancedSearchTypeLabels.forEach({
            $0.textColor = Settings.currentTheme.bodyTextColor
            $0.font = Settings.currentFontSize.bodyTextFont
        })
    }
}

extension AdvancedSearchViewController {
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return """
        Tip #1: to search for part of a word, use * as wildcards (e.g. searching "hel*" will return results containing "hell" or "helm").
        
        Tip #2: to exclude terms, use the - symbol (e.g. searching "death -melodic" will return results that do not contain the word "melodic").
        
        Click "💡 Tips" for more tips on searching possibilities.
        """
    }
    
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
