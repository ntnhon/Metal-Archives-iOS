//
//  UserSubmittedBand.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 08/11/2022.
//

import Foundation
import Kanna

struct UserSubmittedBand {
    let band: BandLite
    let genre: String
    let country: Country
    let date: String
}

extension UserSubmittedBand: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.hashValue == rhs.hashValue }
}

extension UserSubmittedBand: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(band)
        hasher.combine(genre)
        hasher.combine(country)
        hasher.combine(date)
    }
}

extension UserSubmittedBand: PageElement {
    /*
     "<a href='https://www.metal-archives.com/bands/Entidad_Mecanica/3540503531'>Entidad Mecanica</a>",
     "Thrash Metal",
     "Ecuador",
     "March 15, 2022"
     */
    // swiftlint:enable line_length
    init(from strings: [String]) throws {
        guard strings.count == 4 else {
            throw PageElementError.badCount(count: strings.count, expectedCount: 4)
        }

        guard let aTag = try Kanna.HTML(html: strings[0], encoding: .utf8).at_css("a"),
              let bandName = aTag.text,
              let urlString = aTag["href"],
              let band = BandLite(urlString: urlString, name: bandName) else {
            throw PageElementError.failedToParse("URL: \(strings[0])")
        }

        self.band = band
        self.genre = strings[1]
        self.country = CountryManager.shared.country(by: \.name, value: strings[2])
        self.date = strings[3]
    }
}

final class UserSubmittedBandPageManager: PageManager<UserSubmittedBand> {
    init(apiService: APIServiceProtocol, sortOptions: SortOption, userId: String) {
        // swiftlint:disable:next line_length
        let configs = PageConfigs(baseUrlString: "https://www.metal-archives.com/band/ajax-list-user/id/\(userId)?sEcho=1&iColumns=4&sColumns=&iDisplayStart=\(kDisplayStartPlaceholder)&iDisplayLength=\(kDisplayLengthPlaceholder)&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&iSortCol_0=\(kSortColumnPlaceholder)&sSortDir_0=\(kSortDirectionPlaceholder)&iSortingCols=1&bSortable_0=true&bSortable_1=true&bSortable_2=true&bSortable_3=true",
                                  pageSize: 100)
        super.init(configs: configs, apiService: apiService, options: sortOptions.options)
    }
}

extension UserSubmittedBandPageManager {
    enum SortOption: Equatable {
        case band(Order)
        case genre(Order)
        case country(Order)
        case date(Order)

        var title: String {
            switch self {
            case .band(.ascending): return "Band ↑"
            case .band(.descending): return "Band ↓"
            case .genre(.ascending): return "Genre ↑"
            case .genre(.descending): return "Genre ↓"
            case .country(.ascending): return "Country ↑"
            case .country(.descending): return "Country ↓"
            case .date(.ascending): return "Date ↑"
            case .date(.descending): return "Date ↓"
            }
        }

        var column: Int {
            switch self {
            case .band: return 0
            case .genre: return 1
            case .country: return 2
            case .date: return 3
            }
        }

        var order: Order {
            switch self {
            case .band(.ascending),
                    .genre(.ascending),
                    .country(.ascending),
                    .date(.ascending):
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
                (.country(.descending), .country(.descending)),
                (.date(.ascending), .date(.ascending)),
                (.date(.descending), .date(.descending)):
                return true
            default:
                return false
            }
        }
    }
}
