//
//  LatestReview.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 08/12/2022.
//

import Foundation
import Kanna

struct LatestReview {
    let urlString: String
    let bands: [BandLite]
    let release: ReleaseLite
    let rating: Int
    let author: UserLite
    let date: String
    let time: String

    var bandsName: String {
        bands.map(\.name).joined(separator: " & ")
    }
}

extension LatestReview: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.hashValue == rhs.hashValue }
}

extension LatestReview: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(urlString)
        hasher.combine(bands)
        hasher.combine(release)
        hasher.combine(rating)
        hasher.combine(author)
        hasher.combine(date)
        hasher.combine(time)
    }
}

extension LatestReview: Identifiable {
    public var id: Int { hashValue }
}

extension LatestReview: PageElement {
    // swiftlint:disable line_length
    /*
     "December  8",
     "<a href=\"https://www.metal-archives.com/reviews/Houle/Houle/1087729/autothrall/192699\" title=\"Sailing the seas of freeze\" class=\"iconContainer ui-state-default ui-corner-all\"><span class=\"ui-icon ui-icon-search\">Read</span></a>",
     "<a href=\"https://www.metal-archives.com/bands/Houle/3540515080\">Houle</a>",
     "<a href=\"https://www.metal-archives.com/albums/Houle/Houle/1087729\">Houle</a>",

     "75%",
     "<a href=\"https://www.metal-archives.com/users/autothrall\" class=\"profileMenu\">autothrall</a>",
     "12:17"
     */
    // swiftlint:enable line_length
    init(from strings: [String]) throws {
        guard strings.count == 7 else {
            throw PageElementError.badCount(count: strings.count, expectedCount: 7)
        }

        date = strings[0]

        let reviewHtml = try Kanna.HTML(html: strings[1], encoding: .utf8)
        guard let urlString = reviewHtml.at_css("a")?["href"] else {
            throw PageElementError.failedToParse("Latest review's urlString")
        }
        self.urlString = urlString

        let bandsHtml = try Kanna.HTML(html: strings[2], encoding: .utf8)
        var bands = [BandLite]()
        for aTag in bandsHtml.css("a") {
            if let name = aTag.text,
               let urlString = aTag["href"],
               let band = BandLite(urlString: urlString, name: name)
            {
                bands.append(band)
            }
        }
        self.bands = bands

        let releaseHtml = try Kanna.HTML(html: strings[3], encoding: .utf8)
        guard let aTag = releaseHtml.at_css("a"),
              let title = aTag.text,
              let urlString = aTag["href"],
              let release = ReleaseLite(urlString: urlString, title: title)
        else {
            throw PageElementError.failedToParse("\(ReleaseLite.self)")
        }
        self.release = release

        rating = Int(strings[4].replacingOccurrences(of: "%", with: "")) ?? 0

        let authorHtml = try Kanna.HTML(html: strings[5], encoding: .utf8)
        guard let aTag = authorHtml.at_css("a"),
              let username = aTag.text,
              let urlString = aTag["href"]
        else {
            throw PageElementError.failedToParse("\(UserLite.self)")
        }
        author = .init(name: username, urlString: urlString)

        time = strings[6]
    }
}

final class LatestReviewPageManager: PageManager<LatestReview> {
    init() {
        let components = Calendar.current.dateComponents([.month, .year], from: Date())
        let month = String(format: "%02d", components.month ?? 1)
        let year = components.year ?? 2024
        // swiftlint:disable:next line_length
        let configs = PageConfigs(baseUrlString: "https://www.metal-archives.com/review/ajax-list-browse/by/date/selection/\(year)-\(month)/json/1?sEcho=1&iColumns=7&sColumns=&iDisplayStart=\(kDisplayStartPlaceholder)&iDisplayLength=\(kDisplayLengthPlaceholder)&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&mDataProp_4=4&mDataProp_5=5&mDataProp_6=6&iSortCol_0=6&sSortDir_0=desc&iSortingCols=1&bSortable_0=true&bSortable_1=false&bSortable_2=true&bSortable_3=false&bSortable_4=true&bSortable_5=true&bSortable_6=true",
                                  pageSize: 200)
        super.init(configs: configs)
    }
}
