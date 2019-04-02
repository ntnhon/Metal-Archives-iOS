//
//  Error+Code&Domain.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 23/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
extension Error {
    var code: Int { return (self as NSError).code }
    var domain: String { return (self as NSError).domain }
}
