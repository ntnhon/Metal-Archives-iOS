//
//  Actionable.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 15/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

struct ActionableElement {
    let name: String
    let urlString: String
    let type: ActionableElementType
    
    init(name: String, urlString: String, type: ActionableElementType) {
        self.name = name
        self.urlString = urlString
        self.type = type
    }
}

enum ActionableElementType {
    case band, artist, release, label, website, review
}

protocol Actionable {
    var actionableElements: [ActionableElement] { get }
}
