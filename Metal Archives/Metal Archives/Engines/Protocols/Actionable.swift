//
//  Actionable.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 15/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import EventKit

enum ActionableElement {
    case band(name: String, urlString: String)
    case artist(name: String, urlString: String)
    case release(name: String, urlString: String)
    case label(name: String, urlString: String)
    case website(name: String, urlString: String)
    case review(name: String, urlString: String)
    case event(event: EKEvent)
}

protocol Actionable {
    var actionableElements: [ActionableElement] { get }
}
