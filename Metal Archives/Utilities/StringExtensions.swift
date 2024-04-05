//
//  StringExtensions.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

import Kanna

extension StringProtocol where Index == String.Index {
    func subSequence(after: String,
                     before: String? = nil,
                     options: String.CompareOptions = []) -> SubSequence?
    {
        guard let lowerBound = range(of: after, options: options)?.upperBound else { return nil }
        guard let before,
              let upperbound = self[lowerBound ..< endIndex].range(of: before, options: options)?.lowerBound
        else {
            return self[lowerBound...]
        }
        return self[lowerBound ..< upperbound]
    }

    func subString(after: String,
                   before: String? = nil,
                   options: String.CompareOptions = .caseInsensitive) -> String?
    {
        guard let subSequence = subSequence(after: after, before: before, options: options) else {
            return nil
        }
        return String(subSequence)
    }
}

extension String {
    func toInt() -> Int? { Int(self) }

    func removeAll(string: String) -> String { replacingOccurrences(of: string, with: "") }

    // swiftlint:disable:next identifier_name
    subscript(i: Int) -> Character {
        self[index(startIndex, offsetBy: i)]
    }

    func strippedHtmlString() -> String? {
        let htmlDoc = try? Kanna.HTML(html: self, encoding: .utf8)
        return htmlDoc?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
