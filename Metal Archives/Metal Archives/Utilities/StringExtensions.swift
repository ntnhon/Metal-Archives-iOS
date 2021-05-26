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
}

extension String {
    func toInt() -> Int? { Int(self) }

    func removeAll(string: String) -> String { replacingOccurrences(of: string, with: "") }

    func removeHtmlTagsAndNoisySpaces() -> String {
        // From
        /*
         // swiftlint:disable:next line_length
        1983-1984                               (as <a href="https://www.metal-archives.com/bands/Mantas/35328">Mantas</a>),
        1984-2001
        */
       // To:
       /*
       1983-1984 (as Mantas), 1984-2001
        */
        var newString = ""
        var isInATag = false

        for character in self {
            if character == "\n" || character == "\t" {
                continue
            }

            if character == "<" {
                isInATag = true
                continue
            }

            if character != ">" && isInATag {
                continue
            }

            if character == ">" {
                isInATag = false
                continue
            }

            if character == " " {
                guard let lastCharacter = newString.last, lastCharacter != " " else {
                    continue
                }
            }

            // Add a space after a ) or : if the next character is not a , and not a space
            if let lastCharacter = newString.last, lastCharacter == ")" ||
                lastCharacter == ":", character != "," && character != " " {
                newString.append(" ")
            }

            newString.append(character)
        }

        // Remove last space
        guard let lastCharacter = newString.last, lastCharacter == " " else {
            return newString
        }

        return String(newString.dropLast())
    }
}
