//
//  BaseNavigationBarView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 16/06/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

class BaseNavigationBarView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        adjustHeightBaseOnDevice()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        adjustHeightBaseOnDevice()
    }
    
    func adjustHeightBaseOnDevice() {
        constrainHeight(constant: UIApplication.shared.keyWindow!.safeAreaInsets.top + baseNavigationBarViewHeightWithoutTopInset)
    }
}
