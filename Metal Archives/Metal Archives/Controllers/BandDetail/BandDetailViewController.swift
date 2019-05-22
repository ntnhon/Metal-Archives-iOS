//
//  BandDetailViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import SDWebImage
import Toaster
import FirebaseAnalytics
import Crashlytics

final class BandDetailViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var stretchyLogoSmokedImageView: SmokedImageView!
    @IBOutlet private weak var stretchyLogoSmokedImageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var stretchyLogoSmokedImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var utileBarView: UtileBarView!
    
    var bandURLString: String!
    private var band: Band?
    
    private let headerHeight = screenHeight / 6
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCellsAndViews()
        configureStretchyImageView()
        navigationController?.isNavigationBarHidden = true
        reloadBand()
    }

    private func reloadBand() {
        
        MetalArchivesAPI.reloadBand(bandURLString: self.bandURLString) { [weak self] (band, error) in
            if let _ = error {
                self?.reloadBand()
            } else if let `band` = band {
                self?.band = band
                
                if let logoURLString = band.logoURLString, let logoURL = URL(string: logoURLString) {
                    self?.stretchyLogoSmokedImageView.imageView.sd_setImage(with: logoURL)
                }
                
                if let photoURLString = band.photoURLString, let photoURL = URL(string: photoURLString) {

                }
                
                self?.utileBarView.titleLabel.text = band.name
                
                self?.title = band.name
                self?.tableView.reloadData()
                
                Crashlytics.sharedInstance().setObjectValue(self?.band, forKey: CrashlyticsKey.Band)
            }
        }
    }
    
    private func registerCellsAndViews() {
        tableView.register(BandHeaderView.self, forHeaderFooterViewReuseIdentifier: "\(BandHeaderView.self)")
        tableView.register(UINib(nibName: "BandHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "BandHeaderView")
        
    }
}

// MARK: - UI Configurations
extension BandDetailViewController {
    private func configureStretchyImageView() {
        stretchyLogoSmokedImageView.clipsToBounds = false
        stretchyLogoSmokedImageView.contentMode = .scaleAspectFill
        stretchyLogoSmokedImageViewHeightConstraint.constant = Settings.strechyImageViewHeight

        tableView.backgroundColor = .clear
        tableView.contentInset = .init(top: Settings.strechyImageViewHeight - (headerHeight / 2), left: 0, bottom: 0, right: 0)
    }
}
// MARK: - UITableViewDelegate
extension BandDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let band = self.band else { return nil }
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "\(BandHeaderView.self)") as! BandHeaderView
        headerView.fill(with: band)
        return headerView
    }
}

// MARK: - UITableViewDataSource
extension BandDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let band = self.band else {
            return 0
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let band = self.band else {
            return 0
        }
        
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
}

// MARK: - UIScrollViewDelegate
extension BandDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scaleRatio = abs(scrollView.contentOffset.y) / scrollView.contentInset.top
        
        guard scaleRatio >= 0 && scaleRatio <= 2 else { return }
        
        if scaleRatio > 1.0 {
            stretchyLogoSmokedImageView.transform = CGAffineTransform(scaleX: scaleRatio, y: scaleRatio)
        } else {
            stretchyLogoSmokedImageViewTopConstraint.constant = (20 * scaleRatio)
            
            // Prevent bar from becoming transparent when scrolling up too much
            if scrollView.contentOffset.y < 0 {
                utileBarView.backgroundAlpha(1 - scaleRatio)
                stretchyLogoSmokedImageView.smokeDegree(1 - scaleRatio)
            }
        }
    }
}
