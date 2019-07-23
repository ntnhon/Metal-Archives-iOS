//
//  BrowseLabelsByCountryResultViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 20/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Toaster
import FirebaseAnalytics

final class BrowseLabelsByCountryResultViewController: RefreshableViewController {
     @IBOutlet private weak var simpleNavigationBarView: SimpleNavigationBarView!
    var country: Country?
    
    private var browseLabelsByCountryPagableManager: PagableManager<LabelBrowseByCountry>!
    override func viewDidLoad() {
        super.viewDidLoad()
        initPagableManager()
        initSimpleNavigationBarView()
        browseLabelsByCountryPagableManager.fetch()
    }

    override func initAppearance() {
        super.initAppearance()
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        tableView.contentInset = UIEdgeInsets(top: baseNavigationBarViewHeightWithoutTopInset, left: 0, bottom: UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0, right: 0)

        LoadingTableViewCell.register(with: tableView)
        BrowseLabelsByCountryResultTableViewCell.register(with: tableView)
    }
    
    private func initSimpleNavigationBarView() {
        simpleNavigationBarView.setAlphaForBackgroundAndTitleLabel(1)
        simpleNavigationBarView.setRightButtonIcon(nil)
        
        simpleNavigationBarView.didTapLeftButton = { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func initPagableManager() {
        if let country = country {
            browseLabelsByCountryPagableManager = PagableManager<LabelBrowseByCountry>(options: ["<COUNTRY>": country.iso])
        } else {
            browseLabelsByCountryPagableManager = PagableManager<LabelBrowseByCountry>(options: ["<COUNTRY>": "0"])
        }
        
        browseLabelsByCountryPagableManager.delegate = self
    }
    
    private func updateTitle() {
        guard let totalRecords = browseLabelsByCountryPagableManager.totalRecords else {
            simpleNavigationBarView.setTitle("No result found")
            return
        }
        
        simpleNavigationBarView.setTitle("Labels from \(country?.nameAndEmoji ?? "") (\(browseLabelsByCountryPagableManager.objects.count)/\(totalRecords))")
    }
    
    override func refresh() {
        browseLabelsByCountryPagableManager.reset()
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.browseLabelsByCountryPagableManager.fetch()
        }
        
        Analytics.logEvent("refresh_browse_labels_by_country_results", parameters: nil)
    }
}

// MARK: - UIScrollViewDelegate
extension BrowseLabelsByCountryResultViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        simpleNavigationBarView.transformWith(scrollView)
    }
}

//MARK: - PagableManagerDelegate
extension BrowseLabelsByCountryResultViewController: PagableManagerDelegate {
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
}

//MARK: - UITableViewDelegate
extension BrowseLabelsByCountryResultViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard browseLabelsByCountryPagableManager.objects.indices.contains(indexPath.row) else {
            return
            
        }
        
        let label = browseLabelsByCountryPagableManager.objects[indexPath.row]
        
        if let _ = label.websiteURLString {
            takeActionFor(actionableObject: label)
        } else {
            pushLabelDetailViewController(urlString: label.urlString, animated: true)
        }
        
        Analytics.logEvent("select_a_browse_labels_result", parameters: ["label_name": label.name, "label_id": label.id])
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if browseLabelsByCountryPagableManager.moreToLoad && indexPath.row == browseLabelsByCountryPagableManager.objects.count {
            browseLabelsByCountryPagableManager.fetch()
            
        } else if !browseLabelsByCountryPagableManager.moreToLoad && indexPath.row == browseLabelsByCountryPagableManager.objects.count - 1 {
            Toast.displayMessageShortly(endOfListMessage)
        }
    }
}

//MARK: - UITableViewDataSource
extension BrowseLabelsByCountryResultViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let manager = browseLabelsByCountryPagableManager else {
            return 0
        }
        
        if manager.moreToLoad {
            if manager.objects.count == 0 {
                return 0
            }
            
            return manager.objects.count + 1
        }
        
        return manager.objects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if browseLabelsByCountryPagableManager.moreToLoad && indexPath.row == browseLabelsByCountryPagableManager.objects.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        let cell = BrowseLabelsByCountryResultTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        let label = browseLabelsByCountryPagableManager.objects[indexPath.row]
        cell.fill(with: label)
        cell.tappedThumbnailImageView = { [unowned self] in
            self.presentPhotoViewerWithCacheChecking(photoUrlString: label.imageURLString, description: label.name, fromImageView: cell.thumbnailImageView)
            
            Analytics.logEvent("view_browse_labels_result_thumbnail", parameters: ["label_name": label.name, "label_id": label.id])
        }
        return cell
    }
}
