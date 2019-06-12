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

fileprivate let MAX_Y_OFFSET: CGFloat = 100

final class ReviewViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    var urlString: String!
    private var review: Review!
    private var reviewDetailTableViewCell: ReviewDetailTableViewCell!
    
    private let smokedBackgroundView: UIView = {
        let view = UIView(frame: CGRect(origin: .zero, size: .init(width: screenWidth, height: screenHeight)))
        view.backgroundColor = Settings.currentTheme.backgroundColor
        return view
    }()
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
        let containerController = viewController.navigationController ?? viewController
        
        containerController.addChild(self)
        containerController.view.addSubview(smokedBackgroundView)
        containerController.view.addSubview(view)
        self.didMove(toParent: containerController)
        
        view.transform = CGAffineTransform(translationX: 0, y: view.bounds.height)
        smokedBackgroundView.transform = view.transform
        
        UIView.animate(withDuration: Settings.animationDuration) { [unowned self] in
            self.view.transform = .identity
            self.smokedBackgroundView.transform = .identity
        }
    }
    
    func dismissToBottom(completion: (() -> Void)? = nil) {
        isDismissing = true
        
        UIView.animate(withDuration: Settings.animationDuration, animations: { [unowned self] in
            self.view.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
            self.smokedBackgroundView.alpha = 0
        }) { [unowned self] (finished) in
            completion?()
            self.willMove(toParent: nil)
            self.smokedBackgroundView.removeFromSuperview()
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
        reviewDetailTableViewCell = cell
        cell.fill(with: review)
        cell.delegate = self
        return cell
    }
}

//MARK: - ReviewCoverHeaderViewDelegate
extension ReviewViewController: ReviewDetailTableViewCellDelegate {
    func didTapCoverImageView() {
        if let coverPhotoURLString = review.coverPhotoURLString {
            presentPhotoViewer(photoUrlString: coverPhotoURLString, description: "\(review.band.name) - \(review.release.name)", fromImageView: reviewDetailTableViewCell.coverPhotoImageView)
            Analytics.logEvent(AnalyticsEvent.ViewReviewReleaseCover, parameters: [AnalyticsParameter.ReleaseTitle: review.release.name, AnalyticsParameter.ReviewTitle: review.title!])
        }
    }
    
    func didTapBandNameLabel() {
        dismissToBottom { [unowned self] in
            if let parentViewController = self.parent, parentViewController is UINavigationController {
                (parentViewController as! UINavigationController).viewControllers.first?.pushBandDetailViewController(urlString: self.review.band.urlString, animated: true)
            }
        }
    }
    
    func didTapReleaseTitleLabel() {
        dismissToBottom { [unowned self] in
            if let parentViewController = self.parent, parentViewController is UINavigationController {
                (parentViewController as! UINavigationController).viewControllers.first?.pushReleaseDetailViewController(urlString: self.review.release.urlString, animated: true)
            }
        }
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
        smokedBackgroundView.alpha = 1 - (abs(scrollView.contentOffset.y) / MAX_Y_OFFSET)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y < 0 && abs(scrollView.contentOffset.y) > MAX_Y_OFFSET {
            dismissToBottom()
        } else {
            view.transform = .identity
        }
    }
}
