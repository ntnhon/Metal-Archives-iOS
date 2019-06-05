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

fileprivate let duration = 0.35

final class ReviewViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    var urlString: String!
    private var review: Review!
    private var isDismissing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadReview()
        
        view.backgroundColor = Settings.currentTheme.backgroundColor
        tableView.backgroundColor = Settings.currentTheme.backgroundColor
        ReviewDetailTableViewCell.register(with: tableView)
    }

    deinit {
        print("ReviewViewController is deallocated")
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
                    
                    Analytics.logEvent(AnalyticsEvent.ViewReview, parameters: [AnalyticsParameter.ReleaseTitle: review.release.name, AnalyticsParameter.ReviewTitle: review.title!])
                }
            }
        }
    }
    
    func presentFromBottom(in viewController: UIViewController) {
        if let navigationController = viewController.navigationController {
            navigationController.addChild(self)
            navigationController.view.addSubview(view)
            self.didMove(toParent: navigationController)
        } else {
            viewController.addChild(self)
            viewController.view.addSubview(view)
            self.didMove(toParent: viewController)
        }
        
        view.transform = CGAffineTransform(translationX: 0, y: view.bounds.height)
        
        UIView.animate(withDuration: duration) { [unowned self] in
            self.view.transform = .identity
        }
    }
    
    func dismissToBottom(completion: (() -> Void)? = nil) {
        isDismissing = true
        
        UIView.animate(withDuration: duration, animations: { [unowned self] in
            self.view.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
        }) { [unowned self] (finished) in
            completion?()
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
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
            presentPhotoViewer(photoURLString: coverPhotoURLString, description: "\(review.band.name) - \(review.release.name)")
            Analytics.logEvent(AnalyticsEvent.ViewReviewReleaseCover, parameters: [AnalyticsParameter.ReleaseTitle: review.release.name, AnalyticsParameter.ReviewTitle: review.title!])
        }
    }
    
    func didTapBandNameLabel() {
        dismissToBottom { [unowned self] in
            if let parentViewController = self.parent, parentViewController is UINavigationController {
                (parentViewController as! UINavigationController).viewControllers.last?.pushBandDetailViewController(urlString: self.review.band.urlString, animated: true)
            }
        }
    }
    
    func didTapReleaseTitleLabel() {
        dismissToBottom { [unowned self] in
            if let parentViewController = self.parent, parentViewController is UINavigationController {
                (parentViewController as! UINavigationController).viewControllers.last?.pushReleaseDetailViewController(urlString: self.review.release.urlString, animated: true)
            }
        }
    }
    
    func didTapBaseVersionLabel() {
        dismissToBottom { [unowned self] in
            guard let baseVersionUrlString = self.review.baseVersion?.urlString else {
                return
            }
            if let parentViewController = self.parent, parentViewController is UINavigationController {
                (parentViewController as! UINavigationController).viewControllers.last?.pushReleaseDetailViewController(urlString: baseVersionUrlString, animated: true)
            }
        }
    }
    
    func didTapCloseButton() {
        dismissToBottom()
    }
    
    func didTapShareButton() {
        presentAlertOpenURLInBrowsers(URL(string: urlString)!, alertTitle: "View this review in browser", alertMessage: "\(review.title!) - \(review.rating!)%", shareMessage: "Share this review URL")
        
        Analytics.logEvent(AnalyticsEvent.ShareReview, parameters: [AnalyticsParameter.ReleaseTitle: review.release.name, AnalyticsParameter.ReviewTitle: review.title!])
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
            dismissToBottom()
        } else {
            view.transform = .identity
        }
    }
}
