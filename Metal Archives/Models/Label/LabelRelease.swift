//
//  LabelRelease.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 06/11/2022.
//

import Foundation
import Kanna

struct LabelRelease {
    let band: BandLite
    let release: ReleaseLite
    let type: ReleaseType
    let year: String
    let catalog: String
    let format: String
    let description: String?
}

extension LabelRelease: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(band)
        hasher.combine(release)
        hasher.combine(type)
        hasher.combine(year)
        hasher.combine(catalog)
        hasher.combine(format)
        hasher.combine(description)
    }
}

extension LabelRelease: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

extension LabelRelease: PageElement {
    /*
     "<a href=\"https://www.metal-archives.com/bands/Abomination/2853\">Abomination</a>",
     "<a href='https://www.metal-archives.com/albums/Abomination/Abomination/420459'>Abomination</a>",
     "Full-length",
     "1990",
     "NB 028",
     "12\" vinyl",
     "Limited edition, 2 colors"
     */
    init(from strings: [String]) throws {
        guard strings.count == 7 else {
            throw PageElementError.badCount(count: strings.count, expectedCount: 7)
        }

        guard let bandATag = try Kanna.HTML(html: strings[0], encoding: .utf8).at_css("a"),
              let bandName = bandATag.text,
              let bandUrlString = bandATag["href"],
              let band = BandLite(urlString: bandUrlString, name: bandName)
        else {
            throw PageElementError.failedToParse("\(BandLite.self): \(strings[0])")
        }
        self.band = band

        guard let releaseATag = try Kanna.HTML(html: strings[1], encoding: .utf8).at_css("a"),
              let releaseTitle = releaseATag.text,
              let releaseUrlString = releaseATag["href"],
              let release = ReleaseLite(urlString: releaseUrlString, title: releaseTitle)
        else {
            throw PageElementError.failedToParse("\(BandLite.self): \(strings[1])")
        }
        self.release = release

        type = ReleaseType(typeString: strings[2]) ?? .fullLength
        year = strings[3]
        catalog = strings[4]
        format = strings[5]
        let description = strings[6]
        self.description = description.isEmpty ? nil : description
    }
}

final class LabelReleasePageManager: PageManager<LabelRelease> {
    init(apiService: APIServiceProtocol, sortOptions: SortOption, labelId: String) {
        // swiftlint:disable:next line_length
        let configs = PageConfigs(baseUrlString: "https://www.metal-archives.com/label/ajax-albums/nbrPerPage/200/id/\(labelId)?sEcho=1&iColumns=7&sColumns=&iDisplayStart=\(kDisplayStartPlaceholder)&iDisplayLength=\(kDisplayLengthPlaceholder)&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&mDataProp_4=4&mDataProp_5=5&mDataProp_6=6&iSortCol_0=\(kSortColumnPlaceholder)&sSortDir_0=\(kSortDirectionPlaceholder)&iSortingCols=1&bSortable_0=true&bSortable_1=false&bSortable_2=true&bSortable_3=true&bSortable_4=true&bSortable_5=true&bSortable_6=false",
                                  pageSize: 200)
        super.init(configs: configs, apiService: apiService, options: sortOptions.options)
    }
}

extension LabelReleasePageManager {
    enum SortOption: Equatable {
        case band(Order)
        case type(Order)
        case year(Order)
        case catalog(Order)
        case format(Order)

        var title: String {
            switch self {
            case .band(.ascending):
                "Band ↑"
            case .band(.descending):
                "Band ↓"
            case .type(.ascending):
                "Type ↑"
            case .type(.descending):
                "Type ↓"
            case .year(.ascending):
                "Year ↑"
            case .year(.descending):
                "Year ↓"
            case .catalog(.ascending):
                "Catalog ↑"
            case .catalog(.descending):
                "Catalog ↓"
            case .format(.ascending):
                "Format ↑"
            case .format(.descending):
                "Format ↓"
            }
        }

        var column: Int {
            switch self {
            case .band:
                0
            case .type:
                2
            case .year:
                3
            case .catalog:
                4
            case .format:
                5
            }
        }

        var order: Order {
            switch self {
            case .band(.ascending),
                 .type(.ascending),
                 .year(.ascending),
                 .catalog(.ascending),
                 .format(.ascending):
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
            case (.band(.ascending), .band(.ascending)),
                 (.band(.descending), .band(.descending)),
                 (.type(.ascending), .type(.ascending)),
                 (.type(.descending), .type(.descending)),
                 (.year(.ascending), .year(.ascending)),
                 (.year(.descending), .year(.descending)),
                 (.catalog(.ascending), .catalog(.ascending)),
                 (.catalog(.descending), .catalog(.descending)),
                 (.format(.ascending), .format(.ascending)),
                 (.format(.descending), .format(.descending)):
                true
            default:
                false
            }
        }
    }
}
