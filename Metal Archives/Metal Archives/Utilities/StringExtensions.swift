//
//  StringExtensions.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

extension StringProtocol where Index == String.Index {
    func subSequence(after: String,
                     before: String? = nil,
                     options: String.CompareOptions = []) -> SubSequence? {
        guard let lowerBound = range(of: after, options: options)?.upperBound else { return nil }
        guard let before = before,
            let upperbound = self[lowerBound..<endIndex].range(of: before, options: options)?.lowerBound else {
                return self[lowerBound...]
        }
        return self[lowerBound..<upperbound]
    }

    func subString(after: String,
                   before: String? = nil,
                   options: String.CompareOptions = .caseInsensitive) -> String? {
        guard let subSequence = subSequence(after: after, before: before, options: options) else {
            return nil
        }
        return String(subSequence)
    }

    func toInt() -> Int? { Int(self) }
}
