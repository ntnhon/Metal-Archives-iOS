//
//  Logger.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 24/05/2021.
//

import Foundation

enum Logger {
    private static let isTest = UserDefaults.standard.bool(forKey: "isTest")

    static func log(_ message: String) {
        if isTest {
            print(message)
        } else {
            assertionFailure(message)
        }
    }
}
