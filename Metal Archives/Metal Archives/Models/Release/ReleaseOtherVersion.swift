//
//  ReleaseOtherVersion.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 25/05/2021.
//

import Foundation
import Kanna

struct ReleaseOtherVersion {
    let urlString: String
    let date: String
    let labelName: String
    let catalogId: String
    let additionalDetail: String? // Ex: "title "Human / Symolic""
    let isUnofficial: Bool
    let format: String
    let description: String
}

extension ReleaseOtherVersion {
    final class Builder {
        var urlString: String?
        var date: String?
        var labelName: String?
        var catalogId: String?
        var additionalDetail: String?
        var isUnofficial = false
        var format: String?
        var description: String?

        func build() -> ReleaseOtherVersion? {
            guard let urlString = urlString else {
                Logger.log("[Building ReleaseOtherVersion] urlString can not be nil.")
                return nil
            }

            guard let date = date else {
                Logger.log("[Building ReleaseOtherVersion] date can not be nil.")
                return nil
            }

            guard let labelName = labelName else {
                Logger.log("[Building ReleaseOtherVersion] labelName can not be nil.")
                return nil
            }

            guard let catalogId = catalogId else {
                Logger.log("[Building ReleaseOtherVersion] catalogId can not be nil.")
                return nil
            }

            guard let format = format else {
                Logger.log("[Building ReleaseOtherVersion] format can not be nil.")
                return nil
            }

            guard let description = description else {
                Logger.log("[Building ReleaseOtherVersion] description can not be nil.")
                return nil
            }

            return ReleaseOtherVersion(urlString: urlString,
                                       date: date,
                                       labelName: labelName,
                                       catalogId: catalogId,
                                       additionalDetail: additionalDetail,
                                       isUnofficial: isUnofficial,
                                       format: format,
                                       description: description)
        }
    }
}

extension Array where Element == ReleaseOtherVersion {
    // Sample: https://www.metal-archives.com/release/ajax-versions/current/433097/parent/606
    init(data: Data) {
        guard let htmlString = String(data: data, encoding: String.Encoding.utf8),
              let html = try? Kanna.HTML(html: htmlString, encoding: String.Encoding.utf8),
              let tbody = html.at_css("tbody") else {
            Logger.log("Error parsing html for list of release other version")
            self = []
            return
        }

        let isLoggedIn = htmlString.contains("toolsCol-1icon")

        let dateAndLinkColumn = isLoggedIn ? 1 : 0
        let labelColumn = isLoggedIn ? 2 : 1
        let catalogIdColumn = isLoggedIn ? 3 : 2
        let formatColumn = isLoggedIn ? 4 : 3
        let descriptionColumn = isLoggedIn ? 5 : 4

        var releases = [ReleaseOtherVersion]()
        for tr in tbody.css("tr") {
            let builder = ReleaseOtherVersion.Builder()
            for (column, td) in tr.css("td").enumerated() {
                guard let tdText = td.text?.trimmingCharacters(in: .whitespaces) else { continue }
                switch column {
                case dateAndLinkColumn:
                    // swiftlint:disable:next identifier_name
                    guard let a = td.at_css("a") else { continue }
                    builder.urlString = a["href"]
                    builder.date = a.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                    builder.isUnofficial = tdText.contains("Unofficial")
                    builder.additionalDetail = tdText.removeAll(string: "\(builder.date ?? "")")
                        .removeAll(string: "(\n                    Unofficial)")
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                case labelColumn: builder.labelName = tdText
                case catalogIdColumn: builder.catalogId = tdText
                case formatColumn: builder.format = tdText
                case descriptionColumn: builder.description = tdText
                default: break
                }
            }

            if let release = builder.build() {
                releases.append(release)
            }
        }
        self = releases
    }
}
