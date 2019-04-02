//
//  StringProtocol.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 15/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

extension StringProtocol where Index == String.Index {
    func subString(after: String, before: String? = nil, options: String.CompareOptions = []) -> SubSequence? {
        guard let lowerBound = range(of: after, options: options)?.upperBound else { return nil }
        guard let before = before,
            let upperbound = self[lowerBound..<endIndex].range(of: before, options: options)?.lowerBound else {
                return self[lowerBound...]
        }
        return self[lowerBound..<upperbound]
    }
}
