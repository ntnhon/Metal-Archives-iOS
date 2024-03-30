//
//  BandByAlphabet.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 20/10/2022.
//

import Kanna

struct BandByAlphabet {
    let band: BandLite
    let country: Country
    let genre: String
    let status: BandStatus
}

extension BandByAlphabet: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.band == rhs.band }
}

extension BandByAlphabet: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(band)
        hasher.combine(country)
        hasher.combine(genre)
        hasher.combine(status)
    }
}

extension BandByAlphabet: PageElement {
    /*
     "<a href='https://www.metal-archives.com/bands/Aten/3540381609'>Aten</a>",
     "Albania",
     "Death Metal",
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

        country = CountryManager.shared.country(by: \.name, value: strings[1])
        genre = strings[2]

        guard let spanTag = try Kanna.HTML(html: strings[3], encoding: .utf8).at_css("span"),
              let statusText = spanTag.text
        else {
            throw PageElementError.failedToParse("\(BandStatus.self): \(strings[3])")
        }

        status = BandStatus(rawValue: statusText)
    }
}

final class BandByAlphabetPageManager: PageManager<BandByAlphabet> {
    init(letter: Letter, apiService: APIServiceProtocol, sortOptions: SortOption) {
        // swiftlint:disable:next line_length
        let configs = PageConfigs(baseUrlString: "https://www.metal-archives.com/browse/ajax-letter/l/\(letter.parameterString)/json/1?sEcho=1&iColumns=4&sColumns=&iDisplayStart=\(kDisplayStartPlaceholder)&iDisplayLength=\(kDisplayLengthPlaceholder)&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&iSortCol_0=\(kSortColumnPlaceholder)&sSortDir_0=\(kSortDirectionPlaceholder)&iSortingCols=1&bSortable_0=true&bSortable_1=true&bSortable_2=true&bSortable_3=true",
                                  pageSize: 500)
        super.init(configs: configs, apiService: apiService, options: sortOptions.options)
    }
}

extension BandByAlphabetPageManager {
    enum SortOption: Equatable {
        case band(Order)
        case country(Order)
        case genre(Order)

        var title: String {
            switch self {
            case .band(.ascending):
                "Band ↑"
            case .band(.descending):
                "Band ↓"
            case .country(.ascending):
                "Country ↑"
            case .country(.descending):
                "Country ↓"
            case .genre(.ascending):
                "Genre ↑"
            case .genre(.descending):
                "Genre ↓"
            }
        }

        var column: Int {
            switch self {
            case .band:
                0
            case .country:
                1
            case .genre:
                2
            }
        }

        var order: Order {
            switch self {
            case .band(.ascending), .country(.ascending), .genre(.ascending):
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
                 (.country(.ascending), .country(.ascending)),
                 (.country(.descending), .country(.descending)),
                 (.genre(.ascending), .genre(.ascending)),
                 (.genre(.descending), .genre(.descending)):
                return true
            default:
                return false
            }
        }
    }
}
