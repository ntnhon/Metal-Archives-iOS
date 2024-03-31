//
//  UserReview.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 07/11/2022.
//

import Foundation
import Kanna

struct UserReview {
    let urlString: String
    let date: String
    let band: BandLite
    let release: ReleaseLite
    let title: String
    let rating: Int
}

extension UserReview: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.hashValue == rhs.hashValue }
}

extension UserReview: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(date)
        hasher.combine(band)
        hasher.combine(release)
        hasher.combine(title)
        hasher.combine(rating)
    }
}

extension UserReview: PageElement {
    // swiftlint:disable line_length
    /*
     "<a href='https://www.metal-archives.com/reviews/Grave/You%27ll_Never_See.../6289/Felix_1666/329559' class='iconContainer ui-state-default ui-corners-all' title='Read'><span class='ui-icon ui-icon-search'>Read</span></a>",
     "November 4th, 2022",
     "<a href=\"https://www.metal-archives.com/bands/Grave/1020\">Grave</a>",
     "<a href=\"https://www.metal-archives.com/albums/Grave/You%27ll_Never_See.../6289\">You'll Never See...</a>",
     "Full conviction",
     "71%"
     */
    // swiftlint:enable line_length
    init(from strings: [String]) throws {
        guard strings.count == 6 else {
            throw PageElementError.badCount(count: strings.count, expectedCount: 6)
        }

        guard let aTag = try Kanna.HTML(html: strings[0], encoding: .utf8).at_css("a"),
              let urlString = aTag["href"]
        else {
            throw PageElementError.failedToParse("URL: \(strings[0])")
        }

        self.urlString = urlString
        date = strings[1]

        guard let aTag = try Kanna.HTML(html: strings[2], encoding: .utf8).at_css("a"),
              let bandName = aTag.text,
              let bandUrlString = aTag["href"],
              let band = BandLite(urlString: bandUrlString, name: bandName)
        else {
            throw PageElementError.failedToParse("\(BandLite.self): \(strings[2])")
        }
        self.band = band

        guard let aTag = try Kanna.HTML(html: strings[3], encoding: .utf8).at_css("a"),
              let releaseTitle = aTag.text,
              let releaseUrlString = aTag["href"],
              let release = ReleaseLite(urlString: releaseUrlString, title: releaseTitle)
        else {
            throw PageElementError.failedToParse("\(ReleaseLite.self): \(strings[3])")
        }
        self.release = release

        title = strings[4]

        let ratingString = strings[5].replacingOccurrences(of: "%", with: "")
        guard let rating = Int(ratingString) else {
            throw PageElementError.failedToParse("Rating: \(strings[5])")
        }
        self.rating = rating
    }
}

final class UserReviewPageManager: PageManager<UserReview> {
    init(sortOptions: SortOption, userId: String) {
        // swiftlint:disable:next line_length
        let configs = PageConfigs(baseUrlString: "https://www.metal-archives.com/review/ajax-list-user/userId/\(userId)?sEcho=1&iColumns=6&sColumns=&iDisplayStart=\(kDisplayStartPlaceholder)&iDisplayLength=\(kDisplayLengthPlaceholder)&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&mDataProp_4=4&mDataProp_5=5&iSortCol_0=\(kSortColumnPlaceholder)&sSortDir_0=\(kSortDirectionPlaceholder)&iSortingCols=1&bSortable_0=false&bSortable_1=true&bSortable_2=true&bSortable_3=true&bSortable_4=true&bSortable_5=true",
                                  pageSize: 200)
        super.init(configs: configs, options: sortOptions.options)
    }
}

extension UserReviewPageManager {
    enum SortOption: Equatable {
        case date(Order)
        case band(Order)
        case release(Order)
        case title(Order)
        case rating(Order)

        var title: String {
            switch self {
            case .date(.ascending):
                "Date ↑"
            case .date(.descending):
                "Date ↓"
            case .band(.ascending):
                "Band ↑"
            case .band(.descending):
                "Band ↓"
            case .release(.ascending):
                "Release ↑"
            case .release(.descending):
                "Release ↓"
            case .title(.ascending):
                "Title ↑"
            case .title(.descending):
                "Title ↓"
            case .rating(.ascending):
                "Rating ↑"
            case .rating(.descending):
                "Rating ↓"
            }
        }

        var column: Int {
            switch self {
            case .date:
                1
            case .band:
                2
            case .release:
                3
            case .title:
                4
            case .rating:
                5
            }
        }

        var order: Order {
            switch self {
            case .date(.ascending),
                 .band(.ascending),
                 .release(.ascending),
                 .title(.ascending),
                 .rating(.ascending):
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
            case (.date(.ascending), .date(.ascending)),
                 (.date(.descending), .date(.descending)),
                 (.band(.ascending), .band(.ascending)),
                 (.band(.descending), .band(.descending)),
                 (.release(.ascending), .release(.ascending)),
                 (.release(.descending), .release(.descending)),
                 (.title(.ascending), .title(.ascending)),
                 (.title(.descending), .title(.descending)),
                 (.rating(.ascending), .rating(.ascending)),
                 (.rating(.descending), .rating(.descending)):
                true
            default:
                false
            }
        }
    }
}
