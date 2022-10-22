//
//  LabelByAlphabet.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 22/10/2022.
//

import Kanna

struct LabelByAlphabet {
    let label: LabelLite
    let country: Country?
    let specialisation: String?
    let status: LabelStatus
    let website: String?
    let onlineShopping: Bool
}

extension LabelByAlphabet: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.label == rhs.label }
}

extension LabelByAlphabet: PageElement {
    // swiftlint:disable line_length
    /*
     "<a href=\"https://www.metal-archives.com/label/edit/id/58919\" class='iconContainer ui-state-default ui-corner-all writeAction' title='Edit'><span class='ui-icon ui-icon-pencil'>Edit</span></a>",
     "<a href=\"https://www.metal-archives.com/labels/Cabale_Prod/58919\">Cabale Prod</a>",
     "Death metal, Thrash metal &nbsp;",
     "<span class=\"active\">active</span>&nbsp;",
     "France&nbsp;",
     "<a href='https://official.shop/cabale-prod' title='Visit label website' target='_blank'><span>Visit</span> <span class='iconContainer'><span class='ui-icon ui-icon-extlink'>Visit</span></span></a>&nbsp;",
     "<span class='iconContainer'><span class='ui-icon ui-icon-check' title='Yes'>Yes</span></span>&nbsp;"
     */
    // swiftlint:enable line_length
    init(from strings: [String]) throws {
        guard strings.count == 7 else {
            throw PageElementError.badCount(count: strings.count, expectedCount: 7)
        }

        guard let aTag = try Kanna.HTML(html: strings[1], encoding: .utf8).at_css("a"),
              let labelName = aTag.text,
              let labelUrlString = aTag["href"] else {
            throw PageElementError.failedToParse("\(LabelLite.self): \(strings[0])")
        }
        self.label = .init(thumbnailInfo: .init(urlString: labelUrlString, type: .label),
                           name: labelName)

        let specialisation = strings[2].replacingOccurrences(of: "&nbsp;", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if !specialisation.isEmpty {
            self.specialisation = specialisation
        } else {
            self.specialisation = nil
        }

        guard let spanTag = try Kanna.HTML(html: strings[3], encoding: .utf8).at_css("span"),
              let statusText = spanTag.text else {
            throw PageElementError.failedToParse("\(LabelStatus.self): \(strings[3])")
        }

        self.status = LabelStatus(rawValue: statusText)

        let countryName = strings[4].replacingOccurrences(of: "&nbsp;", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if let country = CountryManager.shared.country(by: \.name, value: countryName) {
            self.country = country
        } else {
            self.country = nil
        }

        if let aTag = try Kanna.HTML(html: strings[5], encoding: .utf8).at_css("a"),
           let urlString = aTag["href"] {
            self.website = urlString
        } else {
            self.website = nil
        }
        self.onlineShopping = strings[6] != "&nbsp;"
    }
}
final class LabelByAlphabetPageManager: PageManager<LabelByAlphabet> {
    init(apiService: APIServiceProtocol, letter: Letter, sortOptions: SortOption) {
        // swiftlint:disable:next line_length
        let configs = PageConfigs(baseUrlString: "https://www.metal-archives.com/label/ajax-list/json/1/l/\(letter.parameterString)/json/1?sEcho=1&iColumns=4&sColumns=&iDisplayStart=\(kDisplayStartPlaceholder)&iDisplayLength=\(kDisplayLengthPlaceholder)&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&iSortCol_0=\(kSortColumnPlaceholder)&sSortDir_0=\(kSortDirectionPlaceholder)&iSortingCols=1&bSortable_0=false&bSortable_1=true&bSortable_2=true&bSortable_3=true&bSortable_4=true&bSortable_5=false&bSortable_6=true")
        super.init(configs: configs, apiService: apiService, options: sortOptions.options)
    }
}

extension LabelByAlphabetPageManager {
    enum SortOption: Equatable {
        case name(Order)
        case specialisation(Order)
        case status(Order)
        case country(Order)
        case onlineShopping(Order)

        var title: String {
            switch self {
            case .name(.ascending): return "Name ↑"
            case .name(.descending): return "Name ↓"
            case .specialisation(.ascending): return "Specialisation ↑"
            case .specialisation(.descending): return "Specialisation ↓"
            case .status(.ascending): return "Status ↑"
            case .status(.descending): return "Status ↓"
            case .country(.ascending): return "Country ↑"
            case .country(.descending): return "Country ↓"
            case .onlineShopping(.ascending): return "Online shopping ↑"
            case .onlineShopping(.descending): return "Online shopping ↓"
            }
        }

        var column: Int {
            switch self {
            case .name: return 1
            case .specialisation: return 2
            case .status: return 3
            case .country: return 4
            case .onlineShopping: return 6
            }
        }

        var order: Order {
            switch self {
            case .name(.ascending),
                    .specialisation(.ascending),
                    .status(.ascending),
                    .country(.ascending),
                    .onlineShopping(.ascending):
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
            case (.name(.ascending), .name(.ascending)),
                (.name(.descending), .name(.descending)),
                (.specialisation(.ascending), .specialisation(.ascending)),
                (.specialisation(.descending), .specialisation(.descending)),
                (.status(.ascending), .status(.ascending)),
                (.status(.descending), .status(.descending)),
                (.country(.ascending), .country(.ascending)),
                (.country(.descending), .country(.descending)),
                (.onlineShopping(.ascending), .onlineShopping(.ascending)),
                (.onlineShopping(.descending), .onlineShopping(.descending)):
                return true
            default:
                return false
            }
        }
    }
}
