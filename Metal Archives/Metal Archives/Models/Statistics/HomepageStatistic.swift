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
    
    init(fromRawStatString string: String) throws {
        guard
            let numOfBandsString = RegexHelpers.firstMatch(for: Category.bands.regex, inString: string),
            let numOfUsersString = RegexHelpers.firstMatch(for: Category.registeredUsers.regex, inString: string),
            let numOfReviewsString = RegexHelpers.firstMatch(for: Category.reviews.regex, inString: string) else {
                throw MAParsingError.badSyntax(string: string, expectedSyntax: "546483 bands")
        }
        
        guard
            let numOfBands = Int(numOfBandsString),
            let numOfUsers = Int(numOfUsersString),
            let numOfReviews = Int(numOfReviewsString) else {
                throw MAParsingError.badType(string: numOfBandsString, expectedType: "Int")
        }
        
        self.numOfBands = numOfBands
        self.numOfUsers = numOfUsers
        self.numOfReviews = numOfReviews
    }
    
    func generateAttrSummary() -> NSAttributedString {
        let bodyTextAttributes = Attributes {
            return $0.foreground(color: Settings.currentTheme.bodyTextColor)
                .font(Settings.currentFontSize.bodyTextFont)
                .alignment(.justified)
        }
        
        let hilightedBodyTextAttributes = Attributes {
            return $0.foreground(color: Settings.currentTheme.secondaryTitleColor)
                .font(Settings.currentFontSize.bodyTextFont)
                .alignment(.justified)
        }
        let attrString = NSMutableAttributedString()

        attrString.append("There are currently:\n- ".at.attributed(with: bodyTextAttributes))
        
        attrString.append("\(self.numOfBands.formattedWithSeparator) ".at.attributed(with: hilightedBodyTextAttributes))
        attrString.append("bands.\n- ".at.attributed(with: bodyTextAttributes))
        
        attrString.append("\(self.numOfUsers.formattedWithSeparator) ".at.attributed(with: hilightedBodyTextAttributes))
        attrString.append(" registerd users.\n- ".at.attributed(with: bodyTextAttributes))
        
        attrString.append("\(self.numOfReviews.formattedWithSeparator) ".at.attributed(with: hilightedBodyTextAttributes))
        attrString.append(" reviews.".at.attributed(with: bodyTextAttributes))
        
        return attrString
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
