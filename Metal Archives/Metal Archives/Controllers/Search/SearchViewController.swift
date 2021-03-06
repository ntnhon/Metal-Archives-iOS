//
//  SearchViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class SearchViewController: BaseViewController {
    @IBOutlet private weak var searchModeNavigationBarView: SearchModeNavigationBarView!
    @IBOutlet private weak var simpleSearchView: UIView!
    @IBOutlet private weak var advancedSearchView: UIView!
    
    private var simpleSearchViewController: SimpleSearchViewController!
    private var advancedSearchViewController: AdvancedSearchViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Settings.currentTheme.backgroundColor
        view.bringSubviewToFront(simpleSearchView)
        handleSearchModeNavigationBarViewActions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateSearchView()
    }
    
    private func handleSearchModeNavigationBarViewActions() {
        searchModeNavigationBarView.didTapBackButton = { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
        
        searchModeNavigationBarView.didTapTipsButton = { [unowned self] in
            let searchExplanationViewController = UIStoryboard(name: "Explanation", bundle: nil).instantiateViewController(withIdentifier: "ExplanationViewController") as! ExplanationViewController
            self.simpleSearchViewController.isBeingSelected = false
            searchExplanationViewController.type = .searchTips
            searchExplanationViewController.presentFromBottom(in: self)
        }

        searchModeNavigationBarView.didChangeSearchMode = { [unowned self] in
            self.updateSearchView()
        }
    }
    
    private func updateSearchView() {
        if searchModeNavigationBarView.selectedMode == .simple {
            simpleSearchView.isHidden = false
            advancedSearchView.isHidden = true
            view.bringSubviewToFront(simpleSearchView)
        } else {
            simpleSearchView.isHidden = true
            advancedSearchView.isHidden = false
            view.bringSubviewToFront(advancedSearchView)
        }
        simpleSearchViewController.isBeingSelected = !simpleSearchView.isHidden
        advancedSearchViewController.isBeingSelected = !advancedSearchView.isHidden
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let simpleSearchVC as SimpleSearchViewController :
            simpleSearchViewController = simpleSearchVC
            
        case let advancedSearchVC as AdvancedSearchViewController:
            advancedSearchViewController = advancedSearchVC
            
        default:
            break
        }
    }
}
