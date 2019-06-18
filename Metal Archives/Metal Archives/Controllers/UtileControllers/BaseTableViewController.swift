//
//  BaseTableViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 18/06/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

class BaseTableViewController: UITableViewController {
    // SimpleNavigationBarView
    var simpleNavigationBarView: SimpleNavigationBarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSimpleNavigationBarView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            // Manually remove here because simpleNavigationBarView is added to navigationController.view
            simpleNavigationBarView.removeFromSuperview()
        }
    }
    
    private func initSimpleNavigationBarView() {
        guard let navigationController = navigationController else { return }
        simpleNavigationBarView = SimpleNavigationBarView(frame: .zero)
        navigationController.view.addSubview(simpleNavigationBarView)
        simpleNavigationBarView.anchor(top: navigationController.view.topAnchor, leading: navigationController.view.leadingAnchor, bottom: nil, trailing: navigationController.view.trailingAnchor)
        
        simpleNavigationBarView.setAlphaForBackgroundAndTitleLabel(1)
        simpleNavigationBarView.setRightButtonIcon(nil)
        
        simpleNavigationBarView.didTapLeftButton = { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
        
        tableView.contentInset = UIEdgeInsets(top: baseNavigationBarViewHeightWithoutTopInset, left: 0, bottom: 0, right: 0)
    }
}
