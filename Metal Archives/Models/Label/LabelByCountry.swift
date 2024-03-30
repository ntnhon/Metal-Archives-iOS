//
//  LabelByCountry.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 23/10/2022.
//

import Kanna

struct LabelByCountry {
    let label: LabelLite
    let specialisation: String?
    let status: LabelStatus
    let website: String?
    let onlineShopping: Bool
}

extension LabelByCountry: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.label == rhs.label }
}

extension LabelByCountry: PageElement {
    // swiftlint:disable line_length
    /*
     "<a href=\"https://www.metal-archives.com/label/edit/id/180\" class='iconContainer ui-state-default ui-corner-all writeAction' title='Edit'><span class='ui-icon ui-icon-pencil'>Edit</span></a>",
     "<a href=\"https://www.metal-archives.com/labels/Bloodbath_Records/180\">Bloodbath Records</a>",
     "Noise, Grindcore, Goregrind, Death Metal &nbsp;",
     "<span class=\"active\">active</span>&nbsp;",
     "<a href='http://www.icnet.ne.jp/~noise/home.html' title='Visit label website' target='_blank'><span>Visit</span> <span class='iconContainer'><span class='ui-icon ui-icon-extlink'>Visit</span></span></a>&nbsp;",
     "<span class='iconContainer'><span class='ui-icon ui-icon-check' title='Yes'>Yes</span></span>&nbsp;"
     */
    // swiftlint:enable line_length
    init(from strings: [String]) throws {
        guard strings.count == 6 else {
            throw PageElementError.badCount(count: strings.count, expectedCount: 6)
        }

        guard let aTag = try Kanna.HTML(html: strings[1], encoding: .utf8).at_css("a"),
              let labelName = aTag.text,
              let labelUrlString = aTag["href"]
        else {
            throw PageElementError.failedToParse("\(LabelLite.self): \(strings[0])")
        }
        label = .init(thumbnailInfo: .init(urlString: labelUrlString, type: .label),
                      name: labelName)

        let specialisation = strings[2].replacingOccurrences(of: "&nbsp;", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if !specialisation.isEmpty {
            self.specialisation = specialisation
        } else {
            self.specialisation = nil
        }

        guard let spanTag = try Kanna.HTML(html: strings[3], encoding: .utf8).at_css("span"),
              let statusText = spanTag.text
        else {
            throw PageElementError.failedToParse("\(LabelStatus.self): \(strings[3])")
        }

        status = LabelStatus(rawValue: statusText)

        if let aTag = try Kanna.HTML(html: strings[4], encoding: .utf8).at_css("a"),
           let urlString = aTag["href"]
        {
            website = urlString
        } else {
            website = nil
        }
        onlineShopping = strings[5] != "&nbsp;"
    }
}

final class LabelByCountryPageManager: PageManager<LabelByCountry> {
    init(apiService: APIServiceProtocol, country: Country, sortOptions: SortOption) {
        // swiftlint:disable:next line_length
        let configs = PageConfigs(baseUrlString: "https://www.metal-archives.com/label/ajax-list/c/\(country.isoCode)/json/1?sEcho=1&iColumns=4&sColumns=&iDisplayStart=\(kDisplayStartPlaceholder)&iDisplayLength=\(kDisplayLengthPlaceholder)&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&iSortCol_0=\(kSortColumnPlaceholder)&sSortDir_0=\(kSortDirectionPlaceholder)&iSortingCols=1&bSortable_0=false&bSortable_1=true&bSortable_2=true&bSortable_3=true&bSortable_4=true&bSortable_5=false&bSortable_6=true")
        super.init(configs: configs, apiService: apiService, options: sortOptions.options)
    }
}

extension LabelByCountryPageManager {
    enum SortOption: Equatable {
        case name(Order)
        case specialisation(Order)
        case status(Order)
        case onlineShopping(Order)

        var title: String {
            switch self {
            case .name(.ascending):
                "Name ↑"
            case .name(.descending):
                "Name ↓"
            case .specialisation(.ascending):
                "Specialisation ↑"
            case .specialisation(.descending):
                "Specialisation ↓"
            case .status(.ascending):
                "Status ↑"
            case .status(.descending):
                "Status ↓"
            case .onlineShopping(.ascending):
                "Online shopping ↑"
            case .onlineShopping(.descending):
                "Online shopping ↓"
            }
        }

        var column: Int {
            switch self {
            case .name:
                1
            case .specialisation:
                2
            case .status:
                3
            case .onlineShopping:
                5
            }
        }

        var order: Order {
            switch self {
            case .name(.ascending),
                 .specialisation(.ascending),
                 .status(.ascending),
                 .onlineShopping(.ascending):
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
            case (.name(.ascending), .name(.ascending)),
                 (.name(.descending), .name(.descending)),
                 (.specialisation(.ascending), .specialisation(.ascending)),
                 (.specialisation(.descending), .specialisation(.descending)),
                 (.status(.ascending), .status(.ascending)),
                 (.status(.descending), .status(.descending)),
                 (.onlineShopping(.ascending), .onlineShopping(.ascending)),
                 (.onlineShopping(.descending), .onlineShopping(.descending)):
                true
            default:
                false
            }
        }
    }
}
