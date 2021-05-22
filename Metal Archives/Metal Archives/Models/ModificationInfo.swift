//
//  ModificationInfo.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

import Foundation

// Details page for bands, labels, releases, artists all holds an "auditTrail" tag
// which contains information about the auditor and timestamps
struct ModificationInfo {
    let addedOnDate: Date?
    let modifiedOnDate: Date?
    let addedByUser: UserLite?
    let modifiedByUser: UserLite?

    // swiftlint:disable line_length
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
    // swiftlint:enable line_length
    init(from string: String) {
        let dateFormatter = DateFormatter.default
        if let addedOnString = string.subString(after: "Added on: ", before: "</td>") {
            self.addedOnDate = dateFormatter.date(from: addedOnString)
        } else {
            self.addedOnDate = nil
        }

        if let modifiedOnString = string.subString(after: "Last modified on: ", before: "</td>") {
            self.modifiedOnDate = dateFormatter.date(from: modifiedOnString)
        } else {
            self.modifiedOnDate = nil
        }

        if let addedByString = string.subString(after: "Added by", before: "</td>") {
            self.addedByUser = UserLite(from: addedByString)
        } else {
            self.addedByUser = nil
        }

        if let modifiedByString = string.subString(after: "Modified by", before: "</td>") {
            self.modifiedByUser = UserLite(from: modifiedByString)
        } else {
            self.modifiedByUser = nil
        }
    }
}
