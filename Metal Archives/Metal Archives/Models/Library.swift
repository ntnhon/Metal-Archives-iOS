//
//  Library.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 16/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

struct Library {
    let name: String
    let copyright: String
    let copyrightDetail: String
    
    init(name: String, copyright: String, copyrightDetail: String) {
        self.name = name
        self.copyright = copyright
        self.copyrightDetail = copyrightDetail
    }
}
