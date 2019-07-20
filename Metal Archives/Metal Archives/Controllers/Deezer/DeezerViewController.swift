//
//  DeezerViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 20/07/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class DeezerResultViewController: BaseViewController {
    @IBOutlet private weak var simpleNavigationBarView: SimpleNavigationBarView!
    @IBOutlet private weak var tableView: UITableView!
    
    var deezerableType: DeezerableType!
    var deezerableSearchTerm: String!
    
    deinit {
        print("DeezerResultViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSimpleNavigationBarView()
    }
    
    private func initSimpleNavigationBarView() {
        simpleNavigationBarView.setRightButtonIcon(nil)
        simpleNavigationBarView.setTitle("Deezer for \"\(deezerableSearchTerm!)\"")
        
        simpleNavigationBarView.didTapLeftButton = { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - UITableViewDelegate
extension DeezerResultViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension DeezerResultViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
