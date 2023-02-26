//
//  StringExtensions.swift
//  Metal ArchivesTests
//
//  Created by Thanh-Nhon Nguyen on 21/05/2021.
//

import Foundation

extension String {
    static func random(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        // swiftlint:disable:next force_unwrapping
        return String((0..<length).map { _ in letters.randomElement()! })
    }
}
