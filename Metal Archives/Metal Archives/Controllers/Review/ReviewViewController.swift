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

final class ReviewViewController: RefreshableViewController {
    @IBOutlet private weak var closeButton: UIButton!
    
    var urlString: String!
    
    private var review: Review!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reloadReview()
    }
    
    override func initAppearance() {
        super.initAppearance()
        self.closeButton.setTitleColor(Settings.currentTheme.titleColor, for: .normal)
        self.closeButton.titleLabel?.font = Settings.currentFontSize.titleFont
    
        //Hide 1st header
        self.tableView.contentInset = UIEdgeInsets(top: -CGFloat.leastNormalMagnitude, left: 0, bottom: 0, right: 0)
        
        ReviewDetailTableViewCell.register(with: self.tableView)
    }
    
    override func refresh() {
        self.numberOfTries = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.reloadReview()
        }
        
        Analytics.logEvent(AnalyticsEvent.RefreshReview, parameters: nil)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func reloadReview() {

        if self.numberOfTries == Settings.numberOfRetries {
            self.endRefreshing()
            Toast.displayMessageShortly("Error loading review. Please retry.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.navigationController?.popViewController(animated: true)
            }
            return
        }

        self.numberOfTries += 1

        MetalArchivesAPI.fetchReviewDetail(urlString: urlString) { [weak self] (review, error) in
            if let _ = error {
                self?.reloadReview()
            } else {
                if let `review` = review {
                    DispatchQueue.main.async {
                        self?.review = review
                        self?.refreshSuccessfully()
                        self?.tableView.reloadData()
                    }
                    
                    Analytics.logEvent(AnalyticsEvent.ViewReview, parameters: [AnalyticsParameter.ReleaseTitle: review.releaseTitle, AnalyticsParameter.ReviewTitle: review.title])
                }
            }
        }
    }
    
    @IBAction private func didTapCloseButton() {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - UITableViewDelegate
extension ReviewViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //Hide 1st section header
        if section == 0 {
            return CGFloat.leastNormalMagnitude
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.presentAlertOpenURLInBrowsers(URL(string: self.urlString)!, alertTitle: "View this review in browser", alertMessage: "\(self.review.title!) - \(self.review.rating!)%", shareMessage: "Share this review URL")
        
        Analytics.logEvent(AnalyticsEvent.ShareReview, parameters: [AnalyticsParameter.ReleaseTitle: review.releaseTitle, AnalyticsParameter.ReviewTitle: review.title])
    }
}

//MARK: - UITableViewDataSource
extension ReviewViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if let _ = self.review {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ReviewDetailTableViewCell.dequeueFrom(self.tableView, forIndexPath: indexPath)
        cell.bind(review: self.review)
        cell.delegate = self
        return cell
    }
}

//MARK: - ReviewCoverHeaderViewDelegate
extension ReviewViewController: ReviewDetailTableViewCellDelegate {
    func didTapCoverImageView() {
        if let coverPhotoURLString = self.review.coverPhotoURLString {
            self.presentPhotoViewer(photoURLString: coverPhotoURLString, description: "\(self.review.bandName!) - \(self.review.releaseTitle!)")
            
            Analytics.logEvent(AnalyticsEvent.ViewReviewReleaseCover, parameters: [AnalyticsParameter.ReleaseTitle: review.releaseTitle, AnalyticsParameter.ReviewTitle: review.title])
        }
    }
}
