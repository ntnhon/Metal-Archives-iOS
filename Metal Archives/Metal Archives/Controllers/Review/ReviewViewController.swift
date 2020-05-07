//
//  ReviewViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 06/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Toaster
import FirebaseAnalytics

final class ReviewViewController: DismissableOnSwipeViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var stretchyCoverSmokedImageView: SmokedImageView!
    @IBOutlet private weak var stretchyCoverSmokedImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var simpleNavigationBarView: SimpleNavigationBarView!
    private var tableViewContentOffsetObserver: NSKeyValueObservation?
    
    var urlString: String!
    private var review: Review!
    private var reviewTitleTableViewCell: ReviewTitleTableViewCell!

    override func viewDidLoad() {
        super.viewDidLoad()
        stretchyCoverSmokedImageViewHeightConstraint.constant = screenWidth
        loadReview()
        initSimpleNavigationBarViewActions()
        configureTableView()
        view.backgroundColor = Settings.currentTheme.backgroundColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingToParent {
            tableViewContentOffsetObserver?.invalidate()
            tableViewContentOffsetObserver = nil
        }
        stretchyCoverSmokedImageView.transform = .identity
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func configureTableView() {
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.contentInset = .init(top: stretchyCoverSmokedImageViewHeightConstraint.constant, left: 0, bottom: 0, right: 0)
        
        // observe when tableView is scrolled to animate alphas because scrollViewDidScroll doesn't capture enough event.
        tableViewContentOffsetObserver = tableView.observe(\UITableView.contentOffset, options: [.new]) { [weak self] (tableView, _) in
            self?.calculateAndApplyAlphaForReviewTitleAndSimpleNavBar()
            self?.stretchyCoverSmokedImageView.calculateAndApplyAlpha(withTableView: tableView, scaling: false)
        }
        
        ReviewTitleTableViewCell.register(with: tableView)
        ReviewDetailTableViewCell.register(with: tableView)
        
        // detect taps on review's cover, have to do this because review's cover is overlaid by tableView
        tableView.backgroundView = UIView()
        let backgroundViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tableViewBackgroundViewTapped))
        tableView.backgroundView?.addGestureRecognizer(backgroundViewTapGestureRecognizer)
    }
    
    @objc private func tableViewBackgroundViewTapped() {
        if let coverPhotoURLString = review.coverPhotoURLString {
            presentPhotoViewer(photoUrlString: coverPhotoURLString, description: "\(review.band.name) - \(review.release.title)", fromImageView: stretchyCoverSmokedImageView.imageView)
            
            Analytics.logEvent("view_review_release_cover", parameters: ["release_title": review.release.title, "review_title": review.title!])
        }
    }
    
    private func calculateAndApplyAlphaForReviewTitleAndSimpleNavBar() {
        // Calculate alpha base of distant between simpleNavigationBarView and the cell
        // the cell should only be dimmed only when the cell frame overlaps the simpleNavigationBarView
        
        guard let reviewTitleTableViewCell = reviewTitleTableViewCell, let reviewTitleLabel = reviewTitleTableViewCell.titleLabel else {
            return
        }

        let reviewTitleLabelFrameInThisView = reviewTitleTableViewCell.convert(reviewTitleLabel.frame, to: view)
        let distanceFromReviewTitleLabelToSimpleBarView = reviewTitleLabelFrameInThisView.origin.y - (simpleNavigationBarView.frame.origin.y + simpleNavigationBarView.frame.size.height)

        // alpha = distance / label's height (dim base on label's frame)
        reviewTitleLabel.alpha = (distanceFromReviewTitleLabelToSimpleBarView + reviewTitleLabel.frame.height) / reviewTitleLabel.frame.height
        simpleNavigationBarView.setAlphaForBackgroundAndTitleLabel(1 - reviewTitleLabel.alpha)
    }
    
    private func loadReview() {
        showHUD()
        RequestService.Review.fetch(urlString: urlString) { [weak self]  result in
            guard let self = self else { return }
            self.hideHUD()
            
            switch result {
            case .success(let review):
                self.review = review
                
                if let coverUrlString = review.coverPhotoURLString, let coverURL = URL(string: coverUrlString) {
                    self.stretchyCoverSmokedImageView.imageView.sd_setImage(with: coverURL, placeholderImage: nil, options: [.retryFailed], completed: nil)
                } else {
                    self.tableView.contentInset = .init(top: self.simpleNavigationBarView.frame.origin.y + self.simpleNavigationBarView.frame.height + 10, left: 0, bottom: 0, right: 0)
                }
                
                self.simpleNavigationBarView.setTitle("\(review.title!) - \(review.rating!)%")
                
                self.tableView.reloadData()
                Analytics.logEvent("view_review", parameters: ["release_title": review.release.title, "review_title": review.title!])
                
            case .failure(let error):
                self.showHUD()
                Toast.displayRetryMessage(error)
                DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                    self.loadReview()
                })
            }
        }
    }
    
    private func initSimpleNavigationBarViewActions() {
        simpleNavigationBarView.setLeftButtonMode(.close)
        simpleNavigationBarView.didTapLeftButton = { [unowned self] in
            self.dismissToBottom()
        }
    
        simpleNavigationBarView.didTapRightButton = { [unowned self] in
            self.presentAlertOpenURLInBrowsers(URL(string: self.urlString)!, alertTitle: "View this review in browser", alertMessage: "\(self.review.title!) - \(self.review.rating!)%", shareMessage: "Share this review URL")
            
            Analytics.logEvent("share_review", parameters: ["release_title": self.review.release.title, "review_title": self.review.title!])
        }
    }
    
    override func cancelFromHUD() {
        // don't call super because this view controller is not in navigation stack
        dismissToBottom()
    }
}

//MARK: - UITableViewDataSource
extension ReviewViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if let _ = review {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = ReviewTitleTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            reviewTitleTableViewCell = cell
            cell.fill(with: review.title)
            return cell
        }
        
        let cell = ReviewDetailTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.fill(with: review)
        cell.delegate = self
        return cell
    }
}

//MARK: - ReviewCoverHeaderViewDelegate
extension ReviewViewController: ReviewDetailTableViewCellDelegate {
    func didTapBandNameLabel() {
        dismissToBottom { [unowned self] in
            if let parentViewController = self.parent, parentViewController is UINavigationController {
                (parentViewController as! UINavigationController).viewControllers.first?.pushBandDetailViewController(urlString: self.review.band.urlString, animated: true)
            }
        }
        
        Analytics.logEvent("view_review_band", parameters: ["release_title": self.review.release.title, "review_title": self.review.title!])
    }
    
    func didTapReleaseTitleLabel() {
        dismissToBottom { [unowned self] in
            if let parentViewController = self.parent, parentViewController is UINavigationController {
                (parentViewController as! UINavigationController).viewControllers.first?.pushReleaseDetailViewController(urlString: self.review.release.urlString, animated: true)
            }
        }
        
        Analytics.logEvent("view_review_release", parameters: ["release_title": self.review.release.title, "review_title": self.review.title!])
    }
    
    func didTapAuthorLabel() {
        dismissToBottom { [unowned self] in
            if let parentViewController = self.parent, parentViewController is UINavigationController {
                (parentViewController as! UINavigationController).viewControllers.first?.pushUserDetailViewController(urlString: self.review.user.urlString, animated: true)
            }
        }
        
        Analytics.logEvent("view_review_author", parameters: ["release_title": self.review.release.title, "review_title": self.review.title!])
    }
    
    func didTapBaseVersionLabel() {
        dismissToBottom { [unowned self] in
            guard let baseVersionUrlString = self.review.baseVersion?.urlString else {
                return
            }
            if let parentViewController = self.parent, parentViewController is UINavigationController {
                (parentViewController as! UINavigationController).viewControllers.first?.pushReleaseDetailViewController(urlString: baseVersionUrlString, animated: true)
            }
        }
        
        Analytics.logEvent("view_review_base_version", parameters: ["release_title": self.review.release.title, "review_title": self.review.title!])
    }
}
