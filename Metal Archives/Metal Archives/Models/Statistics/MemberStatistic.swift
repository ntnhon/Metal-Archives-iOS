//
//  MemberStatistic.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class MemberStatistic {
    let total: Int
    let active: Int
    let inactive: Int
    
    init(total: Int, active: Int, inactive: Int) {
        self.total = total
        self.active = active
        self.inactive = inactive
    }
}
