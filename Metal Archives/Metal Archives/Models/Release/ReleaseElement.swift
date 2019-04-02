//
//  ReleaseElement.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 08/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

class ReleaseElement {
    let title: String
    let type: ReleaseElementType
    
    init(title: String, type: ReleaseElementType) {
        self.title = title
        self.type = type
    }
}
