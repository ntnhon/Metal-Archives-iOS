//
//  ExpandedButton.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 29/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class ExpandedButton: UIButton {
//    override func contentRect(forBounds bounds: CGRect) -> CGRect {
//        return bounds.insetBy(dx: 10, dy: 10)
//    }
//
//    override func backgroundRect(forBounds bounds: CGRect) -> CGRect {
//        return bounds.insetBy(dx: 10, dy: 10)
//    }
    @IBInspectable var margin: CGFloat = 10
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let area = CGRect(x: self.bounds.origin.x - margin, y: self.bounds.origin.y - margin, width: self.bounds.size.width + 2 * margin, height: self.bounds.size.height + 2 * margin)
        return area.contains(point)
    }
}
