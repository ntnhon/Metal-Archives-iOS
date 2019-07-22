//
//  DeezerableViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 20/07/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import FirebaseAnalytics

enum DeezerableType {
    case album, artist
    
    var requestParameterName: String {
        switch self {
        case .album: return "album"
        case .artist: return "artist"
        }
    }
}

protocol Deezerable {
    var deezerableType: DeezerableType { get }
    var deezerSearchTerm: String { get }
}

class DeezerableViewController: BaseViewController {
    @IBOutlet weak var deezerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initDeezerButton()
    }
    
    private func initDeezerButton() {
        deezerButton.layer.cornerRadius = deezerButton.bounds.width/2
        deezerButton.backgroundColor = Settings.currentTheme.iconTintColor
        deezerButton.layer.masksToBounds = false
        deezerButton.layer.shouldRasterize = true
        deezerButton.layer.rasterizationScale = UIScreen.main.scale
        deezerButton.layer.shadowRadius = 10
        deezerButton.layer.shadowOpacity = 0.9
        deezerButton.layer.shadowOffset = .zero
        deezerButton.layer.shadowColor = Settings.currentTheme.bodyTextColor.cgColor
    }
    
    @IBAction private func deezerButtonTapped() {
        guard let deezerableSelf = self as? Deezerable else { return }
        let deezerResultViewController = UIStoryboard(name: "Deezer", bundle: nil).instantiateViewController(withIdentifier: "DeezerResultViewController") as! DeezerResultViewController
        
        deezerResultViewController.deezerableType = deezerableSelf.deezerableType
        deezerResultViewController.deezerableSearchTerm = deezerableSelf.deezerSearchTerm
        
        if let _ = self as? BandDetailViewController {
            Analytics.logEvent("deezer_band", parameters: nil)
        } else if let _ = self as? ReleaseDetailViewController {
            Analytics.logEvent("deezer_release", parameters: nil)
        }
        
        navigationController?.pushViewController(deezerResultViewController, animated: true)
    }
}

// MARK: - UIScrollViewDelegate
extension DeezerableViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.panGestureRecognizer.translation(in: scrollView.superview).y < 0 {
            // scroll down
            UIView.animate(withDuration: 0.35) { [unowned self] in
                self.deezerButton.transform = CGAffineTransform(translationX: 0, y: 300)
            }
            
        } else {
            // scroll up
            UIView.animate(withDuration: 0.35) { [unowned self] in
                self.deezerButton.transform = .identity
            }
            
        }
    }
}
