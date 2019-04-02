//
//  Month.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 20/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

struct MonthInYear: Equatable {
    let date: Date
    let shortDisplayString: String
    let longDisplayString: String
    let requestParameterString: String
    
    init(date: Date, shortDisplayString: String, longDisplayString: String, requestParameterString: String) {
        self.date = date
        self.shortDisplayString = shortDisplayString
        self.longDisplayString = longDisplayString
        self.requestParameterString = requestParameterString
    }
    
    static func == (lhs: MonthInYear, rhs: MonthInYear) -> Bool {
        return lhs.requestParameterString == rhs.requestParameterString
    }
}

