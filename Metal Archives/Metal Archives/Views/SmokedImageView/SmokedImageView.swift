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
    
    private let minSmokeDegree: CGFloat = 0.1
    
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
        backgroundColor = .clear
        
        imageView = UIImageView(frame: .zero)
        imageView.backgroundColor = .clear
        addSubview(imageView)
        imageView.fillSuperview()
        
        smokedView = UIView(frame: .zero)
        addSubview(smokedView)
        smokedView.fillSuperview()

        smokedView.backgroundColor = .black
        smokedView.alpha = minSmokeDegree
    }
    
    func smokeDegree(_ degree: CGFloat) {
        smokedView.alpha = max(minSmokeDegree, degree)
    }
}
