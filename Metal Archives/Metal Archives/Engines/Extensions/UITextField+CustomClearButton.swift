//
//  UITextField+CustomClearButton.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 06/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

extension UITextField {
    func setCustomClearButton(withImage image: UIImage, tintColor: UIColor) {
        let clearButton = UIButton(type: .custom)
        clearButton.setImage(image, for: .normal)
        clearButton.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
        clearButton.contentMode = .scaleAspectFit
        clearButton.addTarget(self, action: #selector(UITextField.clear(sender:)), for: .touchUpInside)
        clearButton.tintColor = tintColor
        self.rightView = clearButton
        self.rightViewMode = .whileEditing
    }
    
    @objc func clear(sender : AnyObject) {
        self.text = ""
    }
}
