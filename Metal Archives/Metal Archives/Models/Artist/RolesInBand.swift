//
//  RoleInBand.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 18/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import Kanna

final class RolesInBand {
    private(set) var bandName: String!
    private(set) var bandURLString: String?
    private(set) var roleAndYearsActive: String!
    private(set) var rolesInReleases: [RolesInRelease]?
    
    lazy var roleAndYearsActiveAttributedString: NSAttributedString = {
       let mutableAttributedString = NSMutableAttributedString(string: roleAndYearsActive)
        mutableAttributedString.addAttributes([.foregroundColor: Settings.currentTheme.bodyTextColor, .font: Settings.currentFontSize.titleFont], range: NSRange(roleAndYearsActive.startIndex..., in: roleAndYearsActive))
        
        let additionalDetails = RegexHelpers.listMatches(for: #"\(.+\)"#, inString: roleAndYearsActive)
        additionalDetails.forEach({
            if let range = roleAndYearsActive.range(of: $0) {
                mutableAttributedString.addAttributes([.font: Settings.currentFontSize.bodyTextFont], range: NSRange(range, in: roleAndYearsActive))
            }
        })
        
        return mutableAttributedString
    }()
    
    init?(div_member_in_band: XMLElement) {
        if let h3 = div_member_in_band.at_css("h3") {
            if let a = h3.at_css("a") {
                if let bandName = a.text {
                    self.bandName = bandName
                }
                if let bandURLString = a["href"] {
                    self.bandURLString = bandURLString
                }
            }
            else {
                if let bandName = h3.text {
                    self.bandName = bandName
                }
            }
        }
        
        if let p = div_member_in_band.at_css("p") {
            self.roleAndYearsActive = p.text?.removeHTMLTagsAndNoisySpaces().replacingOccurrences(of: "(", with: " (")
        }
        
        if let table = div_member_in_band.at_css("table") {
            self.rolesInReleases = [RolesInRelease]()
            for tr in table.css("tr") {
                if let rolesInRelease = RolesInRelease(tr: tr) {
                    self.rolesInReleases?.append(rolesInRelease)
                }
            }
        }
    }
}
