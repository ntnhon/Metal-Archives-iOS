//
//  IntExtensions.swift
//  Metal ArchivesTests
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

import Foundation

extension Int {
    func toString() -> String { "\(self)" }

    static func randomId() -> Int {
        Int.random(in: 10000 ..< 20000)
    }
}
