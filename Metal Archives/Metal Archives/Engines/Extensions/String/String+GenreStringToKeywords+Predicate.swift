//
//  String+GenreStringToKeywords+Predicate.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 28/08/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

extension String {
    func genreStringToKeywords() -> [String] {
        return RegexHelpers.listMatches(for: #"\b[a-z|A-Z|-]*\b"#, inString: self).filter({$0 != ""})
    }
}

extension Array where Iterator.Element == String {
    func toPredicateString(byAndOperator: Bool) -> String {
        let eachPredicateString = self.map({"genre CONTAINS[cd] '\($0)'"})
        if byAndOperator {
            return eachPredicateString.joined(separator: " && ")
        }
        return eachPredicateString.joined(separator: " || ")
    }
}
