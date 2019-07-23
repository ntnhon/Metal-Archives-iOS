//
//  BrowseLabelsAlphabeticallyResultViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Toaster
import FirebaseAnalytics

final class BrowseLabelsAlphabeticallyResultViewController: RefreshableViewController {
    @IBOutlet private weak var simpleNavigationBarView: SimpleNavigationBarView!
    var letter: Letter!
    
    private var browseLabelsAlphabeticallyPagableManager: PagableManager<LabelBrowseAlphabetically>!
    override func viewDidLoad() {
        super.viewDidLoad()
        initPagableManager()
        initSimpleNavigationBarView()
        browseLabelsAlphabeticallyPagableManager.fetch()
    }
    
    override func initAppearance() {
        super.initAppearance()
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        tableView.contentInset = UIEdgeInsets(top: baseNavigationBarViewHeightWithoutTopInset, left: 0, bottom: UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0, right: 0)
        
        LoadingTableViewCell.register(with: tableView)
        BrowseLabelsAlphabeticallyResultTableViewCell.register(with: tableView)
    }
    
    private func initSimpleNavigationBarView() {
        simpleNavigationBarView.setAlphaForBackgroundAndTitleLabel(1)
        simpleNavigationBarView.setTitle("")
        simpleNavigationBarView.setRightButtonIcon(nil)
        
        simpleNavigationBarView.didTapLeftButton = { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func initPagableManager() {
        browseLabelsAlphabeticallyPagableManager = PagableManager<LabelBrowseAlphabetically>(options: ["<LETTER>": letter.parameterString])
        browseLabelsAlphabeticallyPagableManager.delegate = self
    }
    
    private func updateTitle() {
        guard let totalRecords = browseLabelsAlphabeticallyPagableManager.totalRecords else {
            simpleNavigationBarView.setTitle("No result found")
            return
        }
        simpleNavigationBarView.setTitle("Loaded \(browseLabelsAlphabeticallyPagableManager.objects.count) of \(totalRecords)")
    }
    
    override func refresh() {
        browseLabelsAlphabeticallyPagableManager.reset()
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.browseLabelsAlphabeticallyPagableManager.fetch()
        }
        
        Analytics.logEvent("refresh_browse_labels_alphabetically_results", parameters: nil)
    }
}

//MARK: - PagableManagerDelegate
extension BrowseLabelsAlphabeticallyResultViewController: PagableManagerDelegate {
    func pagableManagerDidBeginFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        simpleNavigationBarView.setTitle("Loading...")
        showHUD()
    }
    
    func pagableManagerDidFailFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        hideHUD()
        Toast.displayMessageShortly(errorLoadingMessage)
    }
    
    func pagableManagerDidFinishFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        hideHUD()
        endRefreshing()
        updateTitle()
        tableView.reloadData()
    }
    
    func pagableManagerIsBeingBlocked<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        hideHUD()
    }
}

//MARK: - UITableViewDelegate
extension BrowseLabelsAlphabeticallyResultViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard browseLabelsAlphabeticallyPagableManager.objects.indices.contains(indexPath.row) else {
            return
            
        }
        
        let label = browseLabelsAlphabeticallyPagableManager.objects[indexPath.row]
        
        if let _ = label.websiteURLString {
            takeActionFor(actionableObject: label)
        } else {
            pushLabelDetailViewController(urlString: label.urlString, animated: true)
        }
        
        Analytics.logEvent("select_a_browse_labels_result", parameters: ["label_name": label.name, "label_id": label.id])
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if browseLabelsAlphabeticallyPagableManager.moreToLoad && indexPath.row == browseLabelsAlphabeticallyPagableManager.objects.count {
            browseLabelsAlphabeticallyPagableManager.fetch()
            
        } else if !browseLabelsAlphabeticallyPagableManager.moreToLoad && indexPath.row == browseLabelsAlphabeticallyPagableManager.objects.count - 1 {
            Toast.displayMessageShortly(endOfListMessage)
        }
    }
}

//MARK: - UITableViewDataSource
extension BrowseLabelsAlphabeticallyResultViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let manager = browseLabelsAlphabeticallyPagableManager else {
            return 0
        }
        
        if refreshControl.isRefreshing {
            return 0
        }
        
        if manager.moreToLoad {
            return manager.objects.count + 1
        }
        
        return manager.objects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if browseLabelsAlphabeticallyPagableManager.moreToLoad && indexPath.row == browseLabelsAlphabeticallyPagableManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let cell = BrowseLabelsAlphabeticallyResultTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let label = browseLabelsAlphabeticallyPagableManager.objects[indexPath.row]
        cell.fill(with: label)
        cell.tappedThumbnailImageView = { [unowned self] in
            self.presentPhotoViewerWithCacheChecking(photoUrlString: label.imageURLString, description: label.name, fromImageView: cell.thumbnailImageView)
            
            Analytics.logEvent("view_browse_labels_result_thumbnail", parameters: ["label_name": label.name, "label_id": label.id])
        }
        return cell
    }
}
