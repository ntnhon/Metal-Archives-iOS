//
//  SearchViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class SearchViewController: UIViewController {
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    @IBOutlet private weak var simpleSearchView: UIView!
    @IBOutlet private weak var advancedSearchView: UIView!
    
    private var simpleSearchViewController: SimpleSearchViewController!
    private var advancedSearchViewController: AdvancedSearchViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Settings.currentTheme.backgroundColor
        self.view.bringSubviewToFront(self.simpleSearchView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateSearchView()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    @IBAction private func segmentedControlValueChanged() {
        self.updateSearchView()
    }
    
    private func updateSearchView() {
        if self.segmentedControl.selectedSegmentIndex == 0 {
            self.simpleSearchView.isHidden = false
            self.advancedSearchView.isHidden = true
            self.view.bringSubviewToFront(self.simpleSearchView)
        } else {
            self.simpleSearchView.isHidden = true
            self.advancedSearchView.isHidden = false
            self.view.bringSubviewToFront(self.advancedSearchView)
        }
        self.simpleSearchViewController.isBeingSelected = !self.simpleSearchView.isHidden
        self.advancedSearchViewController.isBeingSelected = !self.advancedSearchView.isHidden
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let simpleSearchVC as SimpleSearchViewController :
            self.simpleSearchViewController = simpleSearchVC
            
        case let advancedSearchVC as AdvancedSearchViewController:
            self.advancedSearchViewController = advancedSearchVC
            
        default:
            break
        }
    }
}
