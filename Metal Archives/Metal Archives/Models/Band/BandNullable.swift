//
//  BandNullable.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 05/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class BandNullable {
    let name: String
    let urlString: String?
    let id: String?
    
    init(name: String, urlString: String?) {
        self.name = name
        self.urlString = urlString
        if let `urlString` = urlString {
            self.id = urlString.components(separatedBy: "/").last
        } else {
            self.id = nil
        }
    }
}
