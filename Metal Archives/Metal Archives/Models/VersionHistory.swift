//
//  VersionHistory.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 02/04/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

struct VersionHistory {
    let number: String
    let date: String
    let features: String
    
    init(number: String, date: String, features: String) {
        self.number = number
        self.date = date
        self.features = features
    }
}
