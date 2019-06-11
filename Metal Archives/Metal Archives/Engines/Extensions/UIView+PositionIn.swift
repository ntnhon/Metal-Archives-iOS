//
//  UIView+PositionIn.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 09/06/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

extension UIView {
    func positionIn(view: UIView) -> CGRect {
        if let superview = superview {
            return superview.convert(frame, to: view)
        }
        return frame
    }
}
