//
//  AuditTrail.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 15/05/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

// Details page for bands, labels, releases, artists all holds an "auditTrail" tag which contains information about the auditor and timestamps

struct AuditTrail {
    let addedOnDate: Date?
    let modifiedOnDate: Date?
    let addedByUser: User?
    let modifiedByUser: User?
    
    
    /*
     Sample data:
     <table>
     <tr>
     <td>Added by: <a href="https://www.metal-archives.com/users/Krister%20Jensen" class="profileMenu">Krister Jensen</a></td>
     <td align="right">Modified by: <a href="https://www.metal-archives.com/users/Krister%20Jensen" class="profileMenu">Krister Jensen</a></td>
     </tr>
     <tr>
     <td>Added on: 2019-05-15 05:37:16</td>
     <td align="right">Last modified on: 2019-05-15 05:37:16</td>
     </tr>
     <tr>
     <td valign="top">
     &nbsp;
     </td>
     <td align="right" valign="top">
     </td>
     </tr>
     </table>
     */
    init(from string: String) {
        if let addedOnSubstring = string.subString(after: "Added on: ", before: "</td>", options: .caseInsensitive),
            let addedOnDate = defaultDateFormatter.date(from: String(addedOnSubstring)) {
            self.addedOnDate = addedOnDate
        } else {
            self.addedOnDate = nil
        }
        
        if let modifiedOnSubstring = string.subString(after: "Last modified on: ", before: "</td>", options: .caseInsensitive), let modifiedOnDate = defaultDateFormatter.date(from: String(modifiedOnSubstring)) {
            self.modifiedOnDate = modifiedOnDate
        } else {
            self.modifiedOnDate = nil
        }
        
        if let addedBySustring = string.subString(after: "Added by", before: "</td>", options: .caseInsensitive),
            let addedByUser = User(from: String(addedBySustring)) {
            self.addedByUser = addedByUser
        } else {
            self.addedByUser = nil
        }
        
        if let modifiedBySubstring = string.subString(after: "Modified by", before: "</td>", options: .caseInsensitive), let modifiedByUser = User(from: String(modifiedBySubstring)){
            self.modifiedByUser = modifiedByUser
        } else {
            self.modifiedByUser = nil
        }
        
    }
}
