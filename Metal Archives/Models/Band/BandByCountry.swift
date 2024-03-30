//
//  BandByCountry.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 22/10/2022.
//

import Kanna

struct BandByCountry {
    let band: BandLite
    let genre: String
    let location: String
    let status: BandStatus
}

extension BandByCountry: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.band == rhs.band }
}

extension BandByCountry: PageElement {
    /*
     "<a href='https://www.metal-archives.com/bands/%C3%81i_T%E1%BB%AD_Thi/3540513363'>Ãi Tá»­ Thi</a>",
     "Depressive Black Metal",
     "Hanoi, Red River Delta",
     "<span class=\"active\">Active</span>"
     */
    init(from strings: [String]) throws {
        guard strings.count == 4 else {
            throw PageElementError.badCount(count: strings.count, expectedCount: 4)
        }

        guard let aTag = try Kanna.HTML(html: strings[0], encoding: .utf8).at_css("a"),
              let bandName = aTag.text,
              let bandUrlString = aTag["href"],
              let band = BandLite(urlString: bandUrlString, name: bandName)
        else {
            throw PageElementError.failedToParse("\(BandLite.self): \(strings[0])")
        }
        self.band = band
        genre = strings[1]
        location = strings[2]

        guard let spanTag = try Kanna.HTML(html: strings[3], encoding: .utf8).at_css("span"),
              let statusText = spanTag.text
        else {
            throw PageElementError.failedToParse("\(BandStatus.self): \(strings[3])")
        }

        status = BandStatus(rawValue: statusText)
    }
}

final class BandByCountryPageManager: PageManager<BandByCountry> {
    init(apiService: APIServiceProtocol, country: Country, sortOptions: SortOption) {
        // swiftlint:disable:next line_length
        let configs = PageConfigs(baseUrlString: "https://www.metal-archives.com/browse/ajax-country/c/\(country.isoCode)/json/1?sEcho=1&iColumns=4&sColumns=&iDisplayStart=\(kDisplayStartPlaceholder)&iDisplayLength=\(kDisplayLengthPlaceholder)&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&iSortCol_0=\(kSortColumnPlaceholder)&sSortDir_0=\(kSortDirectionPlaceholder)&iSortingCols=1&bSortable_0=true&bSortable_1=true&bSortable_2=true&bSortable_3=false",
                                  pageSize: 500)
        super.init(configs: configs, apiService: apiService, options: sortOptions.options)
    }
}

extension BandByCountryPageManager {
    enum SortOption: Equatable {
        case band(Order)
        case genre(Order)
        case location(Order)

        var title: String {
            switch self {
            case .band(.ascending):
                "Band ↑"
            case .band(.descending):
                "Band ↓"
            case .genre(.ascending):
                "Genre ↑"
            case .genre(.descending):
                "Genre ↓"
            case .location(.ascending):
                "Location ↑"
            case .location(.descending):
                "Location ↓"
            }
        }

        var column: Int {
            switch self {
            case .band:
                0
            case .genre:
                1
            case .location:
                2
            }
        }

        var order: Order {
            switch self {
            case .band(.ascending), .genre(.ascending), .location(.ascending):
                return .ascending
            default:
                return .descending
            }
        }

        var options: [String: String] {
            [kSortColumnPlaceholder: "\(column)", kSortDirectionPlaceholder: order.queryValue]
        }

        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.band(.ascending), .band(.ascending)),
                 (.band(.descending), .band(.descending)),
                 (.genre(.ascending), .genre(.ascending)),
                 (.genre(.descending), .genre(.descending)),
                 (.location(.ascending), .location(.ascending)),
                 (.location(.descending), .location(.descending)):
                return true
            default:
                return false
            }
        }
    }
}
