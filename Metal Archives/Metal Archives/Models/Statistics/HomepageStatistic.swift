//
//  HomepageStatistic.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 23/04/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//
import Foundation
import AttributedLib

final class HomepageStatistic {
    let numOfBands: Int
    let numOfUsers: Int
    let numOfReviews: Int
    
    lazy var summaryAttributedText: NSAttributedString = {
        let attrString = NSMutableAttributedString()
        
        attrString.append("\(self.numOfBands.formattedWithSeparator)".at.attributed(with: hilightedBodyTextAttributes))
        attrString.append(" bands, ".at.attributed(with: bodyTextAttributes))
        
        attrString.append("\(self.numOfUsers.formattedWithSeparator)".at.attributed(with: hilightedBodyTextAttributes))
        attrString.append(" registered users\n& ".at.attributed(with: bodyTextAttributes))
        
        attrString.append("\(self.numOfReviews.formattedWithSeparator)".at.attributed(with: hilightedBodyTextAttributes))
        attrString.append(" reviews.".at.attributed(with: bodyTextAttributes))
        
        return attrString
    }()
    
    init?(fromRawStatString string: String) {
        guard
            let numOfBandsString = RegexHelpers.firstMatch(for: Category.bands.regex, inString: string),
            let numOfUsersString = RegexHelpers.firstMatch(for: Category.registeredUsers.regex, inString: string),
            let numOfReviewsString = RegexHelpers.firstMatch(for: Category.reviews.regex, inString: string) else {
                return nil
        }
        
        guard
            let numOfBands = Int(numOfBandsString),
            let numOfUsers = Int(numOfUsersString),
            let numOfReviews = Int(numOfReviewsString) else {
                return nil
        }
        
        self.numOfBands = numOfBands
        self.numOfUsers = numOfUsers
        self.numOfReviews = numOfReviews
    }
}

//Sample response
/*
 There are currently 128161 bands, 412748 registered users and 102460 reviews in Encyclopaedia Metallum.
 [<a href="https://www.metal-archives.com/stats">More stats</a>]
 */

extension HomepageStatistic {
    enum Category {
        case bands, registeredUsers, reviews
        
        var regex: String {
            let rawRegex = #"\b[0-9]*(?=\s(category))"#
            
            switch self {
            case .bands: return rawRegex.replacingOccurrences(of: "category", with: "bands")
            case .registeredUsers: return rawRegex.replacingOccurrences(of: "category", with: "registered users")
            case .reviews: return rawRegex.replacingOccurrences(of: "category", with: "reviews")
            }
        }
    }
}
