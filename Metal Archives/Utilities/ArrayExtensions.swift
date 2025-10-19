//
//  ArrayExtensions.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 20/06/2021.
//

import Foundation

// https://stackoverflow.com/a/65598711/2034535
extension Array: @retroactive RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}

// https://www.hackingwithswift.com/example-code/language/how-to-split-an-array-into-chunks
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
