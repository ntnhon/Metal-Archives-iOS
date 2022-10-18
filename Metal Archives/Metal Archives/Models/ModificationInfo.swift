//
//  ModificationInfo.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

import Foundation
import Kanna

// Details page for bands, labels, releases, artists all holds an "auditTrail" tag
// which contains information about the auditor and timestamps
struct ModificationInfo {
    let addedOnDate: Date?
    let modifiedOnDate: Date?
    let addedByUser: UserLite?
    let modifiedByUser: UserLite?
}

extension ModificationInfo {
    var summary: String {
        var summary = ""
        if let addedOnDateString, let addedOnRelativeDateString {
            summary += "Added on \(addedOnDateString) (\(addedOnRelativeDateString))"
        }

        if let modifiedOnDateString, let modifiedOnRelativeDateString {
            if !summary.isEmpty {
                summary += "\n"
            }
            summary += "Modified on \(modifiedOnDateString) (\(modifiedOnRelativeDateString))"
        }
        return summary
    }
}

private extension ModificationInfo {
    var addedOnDateString: String? {
        guard let addedOnDate else { return nil }
        return DateFormatter.dateOnly.string(for: addedOnDate)
    }

    var addedOnRelativeDateString: String? {
        guard let addedOnDate else { return nil }
        return RelativeDateTimeFormatter.default.string(for: addedOnDate)
    }

    var modifiedOnDateString: String? {
        guard let modifiedOnDate else { return nil }
        return DateFormatter.dateOnly.string(for: modifiedOnDate)
    }

    var modifiedOnRelativeDateString: String? {
        guard let modifiedOnDate else { return nil }
        return RelativeDateTimeFormatter.default.string(for: modifiedOnDate)
    }
}

extension ModificationInfo {
    final class Builder {
        var addedOnDate: Date?
        var modifiedOnDate: Date?
        var addedByUser: UserLite?
        var modifiedByUser: UserLite?

        func build() -> ModificationInfo {
            .init(addedOnDate: addedOnDate,
                  modifiedOnDate: modifiedOnDate,
                  addedByUser: addedByUser,
                  modifiedByUser: modifiedByUser)
        }
    }
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
    init(element: XMLElement) {
        let builder = Builder()
        let extractTextAndUrlString: (XMLElement) -> (String, String)? = { element in
            if let aTag = element.at_css("a"),
               let text = aTag.text,
               let urlString = aTag["href"] {
                return (text, urlString)
            }
            return nil
        }
        for td in element.css("td") {
            guard let htmlText = td.innerHTML else { continue }
            if htmlText.contains("Added by"),
               let (username, urlString) = extractTextAndUrlString(td) {
                builder.addedByUser = .init(name: username, urlString: urlString)
            } else if htmlText.contains("Modified by"),
                      let (username, urlString) = extractTextAndUrlString(td) {
                builder.modifiedByUser = .init(name: username, urlString: urlString)
            } else if htmlText.contains("Added on"),
                      let addedOnString = htmlText.subString(after: "Added on: ", before: "</td>") {
                builder.addedOnDate = DateFormatter.default.date(from: addedOnString)
            } else if htmlText.contains("Last modified on"),
                      let modifiedOnString = htmlText.subString(after: "Last modified on: ", before: "</td>") {
                builder.modifiedOnDate = DateFormatter.default.date(from: modifiedOnString)
            }
        }
        self = builder.build()
    }
}
