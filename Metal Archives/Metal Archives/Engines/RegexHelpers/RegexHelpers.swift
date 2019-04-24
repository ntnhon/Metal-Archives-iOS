//
//  RegexHelpers.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 24/04/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

struct RegexHelpers {
//    func highlightMatches(for pattern: String, inString string: String) -> NSAttributedString {
//        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
//            return NSMutableAttributedString(string: string)
//        }
//
//        let range = NSRange(string.startIndex..., in: string)
//        let matches = regex.matches(in: string, options: [], range: range)
//
//        let attributedText = NSMutableAttributedString(string: string)
//
//        for match in matches {
//            attributedText.addAttribute(.backgroundColor, value: UIColor.yellow, range: match.range)
//        }
//
//        return attributedText.copy() as! NSAttributedString
//    }
    
    private init() {}
    
    static func firstMatch(for pattern: String, inString string: String, caseInsensitive: Bool = true) -> String? {
        let options = caseInsensitive ? NSRegularExpression.Options.caseInsensitive : []
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
            return nil
        }
        
        let range = NSRange(string.startIndex..., in: string)
        
        guard let firstMatch = regex.firstMatch(in: string, options: [], range: range) else {
            return nil
        }
        
        let firstMatchRange = Range(firstMatch.range, in: string)!
        
        return String(string[firstMatchRange])
    }
    
    static func listMatches(for pattern: String, inString string: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return []
        }
        
        let range = NSRange(string.startIndex..., in: string)
        let matches = regex.matches(in: string, options: [], range: range)
        
        return matches.map {
            let range = Range($0.range, in: string)!
            return String(string[range])
        }
    }
    
    static func listGroups(for pattern: String, inString string: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return []
        }
        
        let range = NSRange(string.startIndex..., in: string)
        let matches = regex.matches(in: string, options: [], range: range)
        
        var groupMatches: [String] = []
        for match in matches {
            let rangeCount = match.numberOfRanges
            
            for group in 0..<rangeCount {
                let range = Range(match.range(at: group), in: string)!
                groupMatches.append(String(string[range]))
            }
        }
        
        return groupMatches
    }
    
    static func containsMatch(of pattern: String, inString string: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return false
        }
        let range = NSRange(string.startIndex..., in: string)
        return regex.firstMatch(in: string, options: [], range: range) != nil
    }
    
    static func replaceMatches(for pattern: String, inString string: String, withString replacementString: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return string
        }
        
        let range = NSRange(string.startIndex..., in: string)
        return regex.stringByReplacingMatches(in: string, options: [], range: range, withTemplate: replacementString)
    }

}
