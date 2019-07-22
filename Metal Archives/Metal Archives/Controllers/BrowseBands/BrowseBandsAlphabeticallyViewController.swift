//
//  BrowseBandsAlphabeticallyViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 13/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import FirebaseAnalytics

final class BrowseBandsAlphabeticallyViewController: BaseViewController {
    @IBOutlet private weak var simpleNavigationBarView: SimpleNavigationBarView!
    @IBOutlet private weak var tableView: UITableView!
    
    deinit {
        print("BrowseBandsAlphabeticallyViewController is deallocated")
    }
    
    override func initAppearance() {
        super.initAppearance()
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        tableView.contentInset = UIEdgeInsets(top: baseNavigationBarViewHeightWithoutTopInset - 1, left: 0, bottom: UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0, right: 0)

        tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        
        ViewMoreTableViewCell.register(with: tableView)
        initSimpleNavigationBarView()
    }
    
    private func initSimpleNavigationBarView() {
        simpleNavigationBarView.setAlphaForBackgroundAndTitleLabel(1)
        simpleNavigationBarView.setTitle("Browse Bands - Alphabetically")
        simpleNavigationBarView.setRightButtonIcon(nil)
        
        simpleNavigationBarView.didTapLeftButton = { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let bandAphabeticallyResultViewController as BrowseBandsResultViewController:
            if let letter = sender as? Letter {
                bandAphabeticallyResultViewController.parameter = "ajax-letter/l/" + letter.parameterString
                bandAphabeticallyResultViewController.context = "Bands by \"\(letter.description)\""
                
                Analytics.logEvent("perform_browse_band_alphabetically", parameters: ["letter": letter.description])
            }
        default:
            break
        }
    }
}

//MARK: - UITableViewDelegate
extension BrowseBandsAlphabeticallyViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let letter = Letter.allCases[indexPath.row]
        performSegue(withIdentifier: "ShowResults", sender: letter)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return """
        For numbers, select #.
        For non-Latin alphabets or for symbols, select ~.
        
        Note: leading \"The __\" are ignored (e.g. \"The Chasm\" appears under C, not T)
        """
    }
}

//MARK: - UITableViewDataSource
extension BrowseBandsAlphabeticallyViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Letter.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ViewMoreTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.displayAsSecondaryTitle()
        
        let letter = Letter.allCases[indexPath.row]
        cell.fill(message: letter.description)
        
        return cell
    }
}
