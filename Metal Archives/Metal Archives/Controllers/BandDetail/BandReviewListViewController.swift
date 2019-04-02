//
//  BandReviewListViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class BandReviewListViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!

    var band: Band!
    private var errorFetchingMoreReview = false
    private var isFetching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshTitle()
    }
    
    override func initAppearance() {
        super.initAppearance()
        self.tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        self.tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.tableFooterView = UIView(frame: .zero)
        
        ReviewTableViewCell.register(with: self.tableView)
        LoadingTableViewCell.register(with: self.tableView)
    }
    
    private func fetchMoreReviews() {
        self.errorFetchingMoreReview = false
        
        if self.isFetching { return }
        self.isFetching = true
        
        self.band.fetchMoreReviews(onSuccess: { [weak self] in
            self?.errorFetchingMoreReview = false
            self?.refreshTitle()
            self?.tableView.reloadData()
            self?.isFetching = false
        }) { [weak self] (error) in
            self?.errorFetchingMoreReview = true
            self?.isFetching = false
        }
    }
    
    private func refreshTitle() {
        self.title = "Loaded \(self.band.reviews!.count) of \(self.band.totalReviews!) reviews"
    }
}

//MARK: - UITableViewDelegate
extension BandReviewListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let review = self.band.reviews![indexPath.row]
        self.presentReviewController(urlString: review.urlString, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if band.moreToLoad && indexPath.row == self.band.reviews!.count {
            self.fetchMoreReviews()
        }
    }
}

//MARK: - UITableViewDataSource
extension BandReviewListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if let _ = self.band.reviews {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.band.moreToLoad {
            return self.band.reviews!.count + 1
        }
        
        return self.band.reviews!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if band.moreToLoad && indexPath.row == self.band.reviews!.count {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            
            //Fetch is on the way
            if !self.errorFetchingMoreReview {
                loadingCell.displayIsLoading()
                return loadingCell
            }
            
            //Fetch failed
            loadingCell.didsplayError("Error loading more reviews.\n Tap to reload.")
            return loadingCell
        }
        
        let review = self.band.reviews![indexPath.row]
        let reviewCell = ReviewTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        reviewCell.fill(with: review)
        
        return reviewCell
    }
}


