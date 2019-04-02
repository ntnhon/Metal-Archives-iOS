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
                
                var temp = td.text
                temp = temp?.replacingOccurrences(of: "\n", with: "")
                temp = temp?.replacingOccurrences(of: "\t", with: "")
                //temp = temp!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                temp = temp?.trimmingCharacters(in: .whitespaces)
                self.releaseTitle = temp
            }
            else if (i == 2) {
                var temp = td.text
                temp = temp?.replacingOccurrences(of: "\n", with: "")
                temp = temp?.replacingOccurrences(of: "\t", with: "")
                //temp = temp!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                temp = temp?.trimmingCharacters(in: .whitespaces)
                self.roles = temp
            }
            
            i = i + 1
        }
    }
}
