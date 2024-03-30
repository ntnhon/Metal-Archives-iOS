//
//  ReviewLite.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 25/05/2021.
//

import Kanna

struct ReviewLite {
    let urlString: String
    let title: String
    let rating: Int
    let author: UserLite
    let date: String
}

extension ReviewLite {
    final class Builder {
        var urlString: String?
        var title: String?
        var rating: Int?
        var author: UserLite?
        var date: String?

        func build() -> ReviewLite? {
            guard let urlString else {
                Logger.log("[Building ReviewLite] urlString can not be nil.")
                return nil
            }

            guard let title else {
                Logger.log("[Building ReviewLite] title can not be nil.")
                return nil
            }

            guard let rating else {
                Logger.log("[Building ReviewLite] rating can not be nil.")
                return nil
            }

            guard let author else {
                Logger.log("[Building ReviewLite] author can not be nil.")
                return nil
            }

            guard let date else {
                Logger.log("[Building ReviewLite] date can not be nil.")
                return nil
            }

            return ReviewLite(urlString: urlString,
                              title: title,
                              rating: rating,
                              author: author,
                              date: date)
        }
    }
}

extension ReviewLite: PageElement {
    // swiftlint:disable line_length
    /*
     "<a href='https://www.metal-archives.com/reviews/Death/Non%3AAnalog_-_On%3AStage_Series_-_Montreal_06.22.1995/837129/aidane154/377951'>Non:Analog - On:Stage Series - Montreal 06.22.1995</a>",

     "96%",
     "<a href=\"https://www.metal-archives.com/users/aidane154\" class=\"profileMenu\">aidane154</a>",
     "September 26th, 2022"
     */
    // swiftlint:enable line_length

    init(from strings: [String]) throws {
        guard strings.count == 4 else {
            throw PageElementError.badCount(count: strings.count, expectedCount: 4)
        }

        guard let stringAndTitleATag = try Kanna.HTML(html: strings[0], encoding: .utf8).at_css("a"),
              let title = stringAndTitleATag.text,
              let urlString = stringAndTitleATag["href"]
        else {
            throw PageElementError.failedToParse("title & urlString")
        }
        self.urlString = urlString
        self.title = title
        rating = Int(strings[1].replacingOccurrences(of: "%", with: "")) ?? -1

        guard let authorATag = try Kanna.HTML(html: strings[2], encoding: .utf8).at_css("a"),
              let authorName = authorATag.text,
              let authorUrlString = authorATag["href"]
        else {
            throw PageElementError.failedToParse("\(UserLite.self)")
        }
        author = .init(name: authorName, urlString: authorUrlString)
        date = strings[3]
    }
}

final class ReviewLitePageManager: PageManager<ReviewLite> {
    init(bandId: String, apiService: APIServiceProtocol, sortOptions: SortOption) {
        // swiftlint:disable:next line_length
        let configs = PageConfigs(baseUrlString: "https://www.metal-archives.com/review/ajax-list-band/id/\(bandId)/json/1?sEcho=1&iColumns=4&sColumns=&iDisplayStart=\(kDisplayStartPlaceholder)&iDisplayLength=\(kDisplayLengthPlaceholder)&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&iSortCol_0=\(kSortColumnPlaceholder)&sSortDir_0=\(kSortDirectionPlaceholder)&iSortingCols=1&bSortable_0=true&bSortable_1=true&bSortable_2=true&bSortable_3=true")
        super.init(configs: configs, apiService: apiService, options: sortOptions.options)
    }
}

extension ReviewLitePageManager {
    enum SortOption: Equatable {
        case album(Order)
        case rating(Order)
        case author(Order)
        case date(Order)

        var title: String {
            switch self {
            case .album(.ascending):
                "Album ↑"
            case .album(.descending):
                "Album ↓"
            case .rating(.ascending):
                "Rating ↑"
            case .rating(.descending):
                "Rating ↓"
            case .author(.ascending):
                "Author ↑"
            case .author(.descending):
                "Author ↓"
            case .date(.ascending):
                "Date ↑"
            case .date(.descending):
                "Date ↓"
            }
        }

        var column: Int {
            switch self {
            case .album:
                0
            case .rating:
                1
            case .author:
                2
            case .date:
                3
            }
        }

        var order: Order {
            switch self {
            case .album(.ascending),
                 .rating(.ascending),
                 .author(.ascending),
                 .date(.ascending):
                .ascending
            default:
                .descending
            }
        }

        var options: [String: String] {
            [kSortColumnPlaceholder: "\(column)", kSortDirectionPlaceholder: order.queryValue]
        }

        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.album(.ascending), .album(.ascending)),
                 (.album(.descending), .album(.descending)),
                 (.rating(.ascending), .rating(.ascending)),
                 (.rating(.descending), .rating(.descending)),
                 (.author(.ascending), .author(.ascending)),
                 (.author(.descending), .author(.descending)),
                 (.date(.ascending), .date(.ascending)),
                 (.date(.descending), .date(.descending)):
                true
            default:
                false
            }
        }
    }
}
