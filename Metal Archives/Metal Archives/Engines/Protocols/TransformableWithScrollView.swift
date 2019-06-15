//
//  TransformableWithScrollView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 15/06/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

protocol TransformableWithScrollView {
    func transformWith(_ scrollView: UIScrollView)
}

extension TransformableWithScrollView where Self: UIView {
    func transformWith(_ scrollView: UIScrollView) {
        let transform: CGAffineTransform
        if scrollView.panGestureRecognizer.translation(in: scrollView.superview).y < 0 && scrollView.contentOffset.y > 0 {
            // scrolled up
            transform = CGAffineTransform(translationX: 0, y: -bounds.height)
        } else {
            // scrolled down
            transform = .identity
        }
        
        guard self.transform != transform else { return }
        
        UIView.animate(withDuration: 0.35) { [unowned self] in
            self.transform = transform
        }
    }
}
