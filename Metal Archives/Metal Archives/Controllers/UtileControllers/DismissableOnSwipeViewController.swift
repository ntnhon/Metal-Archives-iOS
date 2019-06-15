//
//  DismissableOnSwipeViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 15/06/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

fileprivate let MAX_Y_OFFSET: CGFloat = 100

class DismissableOnSwipeViewController: BaseViewController {
    private let smokedBackgroundView: UIView = {
        let view = UIView(frame: CGRect(origin: .zero, size: .init(width: screenWidth, height: screenHeight)))
        view.backgroundColor = Settings.currentTheme.backgroundColor
        return view
    }()
    private var isDismissing = false
    
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

// MARK: - UIScrollViewDelegate
extension DismissableOnSwipeViewController: UIScrollViewDelegate {
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
