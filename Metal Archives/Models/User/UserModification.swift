//
//  UserModification.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 08/11/2022.
//

import Foundation
import Kanna

enum UserModificationItem: Hashable {
    case band(BandLite)
    case artist(ArtistLite)
    case release(ReleaseLite)
    case label(LabelLite)
    case unknown(String)

    func hash(into hasher: inout Hasher) {
        switch self {
        case let .band(band):
            hasher.combine(band)
        case let .artist(artist):
            hasher.combine(artist)
        case let .release(release):
            hasher.combine(release)
        case let .label(label):
            hasher.combine(label)
        case let .unknown(text):
            hasher.combine(text)
        }
    }

    var thumbnailInfo: ThumbnailInfo? {
        switch self {
        case let .band(band):
            return band.thumbnailInfo
        case let .artist(artist):
            return artist.thumbnailInfo
        case let .release(release):
            return release.thumbnailInfo
        case let .label(label):
            return label.thumbnailInfo
        case .unknown:
            return nil
        }
    }

    var title: String {
        switch self {
        case let .band(band):
            return band.name
        case let .artist(artist):
            return artist.name
        case let .release(release):
            return release.title
        case let .label(label):
            return label.name
        case let .unknown(text):
            return text
        }
    }

    var systemImage: String {
        switch self {
        case .band:
            return "person.3.fill"
        case .artist:
            return "person.fill"
        case .release:
            return "opticaldisc.fill"
        case .label:
            return "tag.fill"
        case .unknown:
            return "questionmark"
        }
    }
}

struct UserModification {
    #warning("Convert to relative date")
    let date: String
    let item: UserModificationItem
    let note: String
}

extension UserModification: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.hashValue == rhs.hashValue }
}

extension UserModification: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(date)
        hasher.combine(item)
        hasher.combine(note)
    }
}

extension UserModification: PageElement {
    // swiftlint:disable line_length
    /*
     "2022-11-01 16:32:27",
     "<a href=\"https://www.metal-archives.com/artists/Kevin_Christoph/969741\">Kevin Christoph</a>",
     "Modified artist data",
     "<span class='historyItem' data-historyId='19038534'><a id=\"19038534\" class=\"details iconContainer ui-state-default ui-corner-all\" href=\"javascript:;\" title=\"Expand\"><span id=\"icon_19038534\" class=\"ui-icon ui-icon-plus\"> </span></a></span>",
     "0"
     */
    // swiftlint:enable line_length
    init(from strings: [String]) throws {
        guard strings.count == 5 else {
            throw PageElementError.badCount(count: strings.count, expectedCount: 5)
        }

        date = strings[0]

        if let aTag = try Kanna.HTML(html: strings[1], encoding: .utf8).at_css("a"),
           let text = aTag.text,
           let urlString = aTag["href"]
        {
            if urlString.contains("/bands/"),
               let band = BandLite(urlString: urlString, name: text)
            {
                item = .band(band)
            } else if urlString.contains("/artists/"),
                      let artist = ArtistLite(urlString: urlString, name: text)
            {
                item = .artist(artist)
            } else if urlString.contains("/albums/"),
                      let release = ReleaseLite(urlString: urlString, title: text)
            {
                item = .release(release)
            } else if urlString.contains("/labels/") {
                let label = LabelLite(thumbnailInfo: .init(urlString: urlString, type: .label), name: text)
                item = .label(label)
            } else {
                throw PageConfigsError.impossibleCase
            }
        } else {
            item = .unknown(strings[1])
        }

        note = (try? Kanna.HTML(html: strings[2], encoding: .utf8).text) ?? strings[2]
    }
}

final class UserModificationPageManager: PageManager<UserModification> {
    init(apiService: APIServiceProtocol, sortOptions: SortOption, userId: String) {
        // swiftlint:disable:next line_length
        let configs = PageConfigs(baseUrlString: "https://www.metal-archives.com/history/ajax-view/id/\(userId)/type/user?sEcho=1&iColumns=5&sColumns=&iDisplayStart=\(kDisplayStartPlaceholder)&iDisplayLength=\(kDisplayLengthPlaceholder)&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&mDataProp_4=4&iSortCol_0=\(kSortColumnPlaceholder)&sSortDir_0=\(kSortDirectionPlaceholder)&iSortingCols=1&bSortable_0=true&bSortable_1=true&bSortable_2=false&bSortable_3=false&bSortable_4=true",
                                  pageSize: 500)
        super.init(configs: configs, apiService: apiService, options: sortOptions.options)
    }
}

extension UserModificationPageManager {
    enum SortOption: Equatable {
        case date(Order)
        case item(Order)

        var title: String {
            switch self {
            case .date(.ascending):
                "Date ↑"
            case .date(.descending):
                "Date ↓"
            case .item(.ascending):
                "Item ↑"
            case .item(.descending):
                "Item ↓"
            }
        }

        var column: Int {
            switch self {
            case .date:
                0
            case .item:
                1
            }
        }

        var order: Order {
            switch self {
            case .date(.ascending), .item(.ascending):
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
                 (.item(.ascending), .item(.ascending)),
                 (.item(.descending), .item(.descending)):
                true
            default:
                false
            }
        }
    }
}
