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

final class ReviewViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    var urlString: String!
    private var review: Review!
    private weak var containingViewController: UIViewController!
    private var initialCenter = CGPoint()
    
    private var isDismissing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadReview()
        
        view.backgroundColor = Settings.currentTheme.backgroundColor
        tableView.backgroundColor = Settings.currentTheme.backgroundColor
        ReviewDetailTableViewCell.register(with: tableView)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func loadReview() {
        MetalArchivesAPI.fetchReviewDetail(urlString: urlString) { [weak self] (review, error) in
            guard let self = self else { return }
            if let _ = error {
                self.loadReview()
            } else {
                if let `review` = review {
                    DispatchQueue.main.async {
                        self.review = review
                        self.tableView.reloadData()
                    }
                    
                    Analytics.logEvent(AnalyticsEvent.ViewReview, parameters: [AnalyticsParameter.ReleaseTitle: review.releaseTitle!, AnalyticsParameter.ReviewTitle: review.title!])
                }
            }
        }
    }
    
    func present(in viewController: UIViewController) {
        containingViewController = viewController
        containingViewController.navigationController!.addChild(self)
        
        view.transform = CGAffineTransform(translationX: 0, y: view.bounds.height)
        containingViewController.navigationController!.view.addSubview(view)
        
        UIView.animate(withDuration: 0.35) { [unowned self] in
            self.view.transform = .identity
        }
    }
    
    private func dismiss() {
        isDismissing = true
        UIView.animate(withDuration: 0.35, animations: { [unowned self] in
            self.view.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
        }) { [unowned self] (finished) in
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
}

//MARK: - UITableViewDelegate
extension ReviewViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presentAlertOpenURLInBrowsers(URL(string: urlString)!, alertTitle: "View this review in browser", alertMessage: "\(review.title!) - \(review.rating!)%", shareMessage: "Share this review URL")
        
        Analytics.logEvent(AnalyticsEvent.ShareReview, parameters: [AnalyticsParameter.ReleaseTitle: review.releaseTitle!, AnalyticsParameter.ReviewTitle: review.title!])
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ReviewDetailTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.fill(with: review)
        cell.delegate = self
        return cell
    }
}

//MARK: - ReviewCoverHeaderViewDelegate
extension ReviewViewController: ReviewDetailTableViewCellDelegate {
    func didTapCoverImageView() {
        if let coverPhotoURLString = review.coverPhotoURLString {
            presentPhotoViewer(photoURLString: coverPhotoURLString, description: "\(review.bandName!) - \(review.releaseTitle!)")
            
            Analytics.logEvent(AnalyticsEvent.ViewReviewReleaseCover, parameters: [AnalyticsParameter.ReleaseTitle: review.releaseTitle!, AnalyticsParameter.ReviewTitle: review.title!])
        }
    }
}

// MARK: - UIScrollViewDelegate
extension ReviewViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.contentOffset.y < 0 && !isDismissing else {return}
        
        view.transform = CGAffineTransform(translationX: view.frame.origin.x, y: -scrollView.contentOffset.y)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y < 0 && abs(scrollView.contentOffset.y) > 100 {
            dismiss()
        } else {
            view.transform = .identity
        }
    }
}
