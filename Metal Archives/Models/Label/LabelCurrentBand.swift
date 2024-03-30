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
              let band = BandLite(urlString: bandUrlString, name: bandName) else {
            throw PageElementError.failedToParse("\(BandLite.self): \(strings[0])")
        }
        self.band = band

        self.genre = strings[1]
        self.country = CountryManager.shared.country(by: \.name, value: strings[2])
    }
}

final class LabelCurrentBandPageManager: PageManager<LabelCurrentBand> {
    init(apiService: APIServiceProtocol, sortOptions: SortOption, labelId: String) {
        // swiftlint:disable:next line_length
        let configs = PageConfigs(baseUrlString: "https://www.metal-archives.com/label/ajax-bands/nbrPerPage/100/id/\(labelId)?sEcho=1&iColumns=3&sColumns=&iDisplayStart=\(kDisplayStartPlaceholder)&iDisplayLength=\(kDisplayLengthPlaceholder)&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&iSortCol_0=\(kSortColumnPlaceholder)&sSortDir_0=\(kSortDirectionPlaceholder)&iSortingCols=1&bSortable_0=true&bSortable_1=true&bSortable_2=true",
                                  pageSize: 100)
        super.init(configs: configs, apiService: apiService, options: sortOptions.options)
    }
}

extension LabelCurrentBandPageManager {
    enum SortOption: Equatable {
        case band(Order)
        case genre(Order)
        case country(Order)

        var title: String {
            switch self {
            case .band(.ascending): return "Band ↑"
            case .band(.descending): return "Band ↓"
            case .genre(.ascending): return "Genre ↑"
            case .genre(.descending): return "Genre ↓"
            case .country(.ascending): return "Country ↑"
            case .country(.descending): return "Country ↓"
            }
        }

        var column: Int {
            switch self {
            case .band: return 0
            case .genre: return 1
            case .country: return 2
            }
        }

        var order: Order {
            switch self {
            case .band(.ascending), .genre(.ascending), .country(.ascending):
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
                (.country(.ascending), .country(.ascending)),
                (.country(.descending), .country(.descending)):
                return true
            default:
                return false
            }
        }
    }
}
