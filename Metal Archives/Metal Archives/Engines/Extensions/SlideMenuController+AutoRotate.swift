//
//  SlideMenuViewController+AutoRotate.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 28/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import UIKit
import SlideMenuControllerSwift

extension SlideMenuController {
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }
    
    override open var shouldAutorotate: Bool {
        return false
    }
}
