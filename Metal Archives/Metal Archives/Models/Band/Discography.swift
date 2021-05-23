//
//  Discography.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

import Foundation
import Kanna

struct Discography {
    let releases: [ReleaseLite]

    // Sample: https://www.metal-archives.com/band/discography/id/141/tab/all
    init(data: Data) {
        guard let htmlString = String(data: data, encoding: String.Encoding.utf8),
              let html = try? Kanna.HTML(html: htmlString, encoding: String.Encoding.utf8) else {
            self.releases = []
            return
        }

        // Check if user is logged in, because in this case the html structure is different
        // there is 1 more column at the beginning (for editing)
        let isLoggedIn = htmlString.contains("title=\"Tools\"")

        let nameColumn = isLoggedIn ? 1 : 0
        let typeColumn = isLoggedIn ? 2 : 1
        let yearColumn = isLoggedIn ? 3 : 2
        let reviewColumn = isLoggedIn ? 4 : 3

        var releases = [ReleaseLite]()
        for tbody in html.css("tbody") {
            for tr in tbody.css("tr") {
                // This band has no release yet
                if tr.css("td").count == 1 {
                    self.releases = []
                    return
                }

                let builder = ReleaseLite.Builder()
                for (column, td) in tr.css("td").enumerated() {
                    switch column {
                    case nameColumn:
                        builder.title = td.text
                        builder.urlString = td.css("a").first?["href"]
                    case typeColumn:
                        builder.type = ReleaseType(typeString: td.text ?? "")
                    case yearColumn:
                        builder.year = td.text?.toInt()
                    case reviewColumn:
                        let reviewString = td.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                        builder.reviewCount = reviewString?.components(separatedBy: " ").first?.toInt()
                        builder.rating = reviewString?.subString(after: "(", before: "%)")?.toInt()
                        builder.reviewsUrlString = td.css("a").first?["href"]
                    default: break
                    }
                }

                if let releaseLite = builder.build() {
                    releases.append(releaseLite)
                }
            }
        }
        self.releases = releases
    }
}
