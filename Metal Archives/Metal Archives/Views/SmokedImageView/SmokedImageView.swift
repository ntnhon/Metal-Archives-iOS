//
//  SmokedImageView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/05/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class SmokedImageView: UIView {
    var imageView: UIImageView!
    private var smokedView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubviews()
    }
    
    private func initSubviews() {
        clipsToBounds = false
        backgroundColor = Settings.currentTheme.backgroundColor
        
        imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = Settings.currentTheme.backgroundColor
        addSubview(imageView)
        imageView.fillSuperview()
        
        smokedView = UIView(frame: .zero)
        addSubview(smokedView)
        smokedView.fillSuperview()

        smokedView.backgroundColor = Settings.currentTheme.backgroundColor
        smokedView.alpha = 0
    }
    
    func calculateAndApplyAlpha(withTableView tableView: UITableView) {
        
        let scaleRatio = abs(tableView.contentOffset.y) / tableView.contentInset.top
        
        guard scaleRatio >= 0 && scaleRatio <= 2 else { return }
        
        if scaleRatio > 1.0 {
            // Zoom stretchyLogoSmokedImageView
            transform = CGAffineTransform(scaleX: scaleRatio, y: scaleRatio)
        } else {
            guard tableView.contentOffset.y < 0 else { return }
            // Move stretchyLogoSmokedImageView up
            let translationY = (20 * scaleRatio)
            transform = CGAffineTransform(translationX: 0, y: translationY)
            smokedView.alpha = 1 - scaleRatio
        }
    }
}
