//
//  LabelCurrentBand.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 05/11/2022.
//

import Foundation
import Kanna

struct LabelCurrentBand {
    let band: BandLite
    let genre: String
    let country: Country
}

extension LabelCurrentBand: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(band)
        hasher.combine(genre)
        hasher.combine(country)
    }
}

extension LabelCurrentBand: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

extension LabelCurrentBand: PageElement {
    /*
     "<a href='https://www.metal-archives.com/bands/Aborted/213'>Aborted</a>",
     "Brutal Death Metal (early); Death Metal/Grindcore (later)",
     "Belgium"
     */
    init(from strings: [String]) throws {
        guard strings.count == 3 else {
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
        country = CountryManager.shared.country(by: \.name, value: strings[2])
    }
}

final class LabelCurrentBandPageManager: PageManager<LabelCurrentBand> {
    init(sortOptions: SortOption, labelId: String) {
        // swiftlint:disable:next line_length
        let configs = PageConfigs(baseUrlString: "https://www.metal-archives.com/label/ajax-bands/nbrPerPage/100/id/\(labelId)?sEcho=1&iColumns=3&sColumns=&iDisplayStart=\(kDisplayStartPlaceholder)&iDisplayLength=\(kDisplayLengthPlaceholder)&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&iSortCol_0=\(kSortColumnPlaceholder)&sSortDir_0=\(kSortDirectionPlaceholder)&iSortingCols=1&bSortable_0=true&bSortable_1=true&bSortable_2=true",
                                  pageSize: 100)
        super.init(configs: configs, options: sortOptions.options)
    }
}

extension LabelCurrentBandPageManager {
    enum SortOption: Equatable {
        case band(Order)
        case genre(Order)
        case country(Order)

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
            case .country(.ascending):
                "Country ↑"
            case .country(.descending):
                "Country ↓"
            }
        }

        var column: Int {
            switch self {
            case .band:
                0
            case .genre:
                1
            case .country:
                2
            }
        }

        var order: Order {
            switch self {
            case .band(.ascending), .genre(.ascending), .country(.ascending):
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
                 (.genre(.ascending), .genre(.ascending)),
                 (.genre(.descending), .genre(.descending)),
                 (.country(.ascending), .country(.ascending)),
                 (.country(.descending), .country(.descending)):
                true
            default:
                false
            }
        }
    }
}
