//
//  RoleInRelease.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 18/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import Kanna

final class RolesInRelease {
    private(set) var year: Int!
    private(set) var releaseTitle: String!
    private(set) var releaseURLString: String!
    private(set) var roles: String!
    
    lazy var releaseTitleAttributedString: NSAttributedString = {
        let attributedString = NSMutableAttributedString(string: releaseTitle)
        attributedString.addAttributes([.foregroundColor: Settings.currentTheme.secondaryTitleColor, .font: Settings.currentFontSize.secondaryTitleFont], range: NSRange(releaseTitle.startIndex..., in: releaseTitle))
        
        let additionalDetails = RegexHelpers.listMatches(for: #"\(.+\)"#, inString: releaseTitle)
        
        additionalDetails.forEach({
            if let range = releaseTitle.range(of: $0) {
                attributedString.addAttributes([.foregroundColor: Settings.currentTheme.bodyTextColor], range: NSRange(range, in: releaseTitle))
            }
        })
        
        return attributedString
    }()
    
    init?(tr: XMLElement) {
        var i = 0
        
        for td in tr.css("td") {
            
            if (i == 0) {
                if let yearString = td.text, let yearInt = Int(yearString) {
                    self.year = yearInt
                } else {
                    return nil
                }
            }
                
            else if (i == 1) {
                if let a = td.at_css("a"), let releaseURLString = a["href"] {
                    self.releaseURLString = releaseURLString
                }
                
                self.releaseTitle = td.text?.removeHTMLTagsAndNoisySpaces()
            }
            else if (i == 2) {
                self.roles = td.text?.removeHTMLTagsAndNoisySpaces()
            }
            
            i = i + 1
        }
    }
}
