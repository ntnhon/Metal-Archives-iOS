//
//  LatestLabel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 23/12/2022.
//

import Foundation
import Kanna

struct LatestLabel {
    let date: String
    let label: LabelLite
    let status: LabelStatus
    let country: Country
    let dateAndTime: String
    let author: UserLite
}

extension LatestLabel: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.hashValue == rhs.hashValue }
}

extension LatestLabel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(date)
        hasher.combine(label)
        hasher.combine(status)
        hasher.combine(country)
        hasher.combine(dateAndTime)
        hasher.combine(author)
    }
}

extension LatestLabel: Identifiable {
    public var id: Int { hashValue }
}

extension LatestLabel: PageElement {
    /*
     "December 22",
     "<a href=\"https://www.metal-archives.com/labels/Heavytron_Sound_Studio/60390\">Heavytron Sound Studio</a>",
     "<span class=\"active\">active</span>&nbsp;",
     "Brazil&nbsp;",
     "2022-12-22 16:08:28",
     "<a href=\"https://www.metal-archives.com/users/TiberioChagas\" class=\"profileMenu\">TiberioChagas</a>"
     */
    init(from strings: [String]) throws {
        guard strings.count == 6 else {
            throw PageElementError.badCount(count: strings.count, expectedCount: 6)
        }

        self.date = strings[0]

        let labelHtml = try Kanna.HTML(html: strings[1], encoding: .utf8)
        guard let labelATag = labelHtml.at_css("a"),
              let labelName = labelATag.text,
              let labelUrlString = labelATag["href"] else {
            throw PageElementError.failedToParse("\(LabelLite.self)")
        }
        self.label = .init(thumbnailInfo: .init(urlString: labelUrlString, type: .label),
                           name: labelName)

        let statusHtml = try Kanna.HTML(html: strings[2], encoding: .utf8)
        guard let statusSpanTag = statusHtml.at_css("span"),
              let statusText = statusSpanTag.text else {
            throw PageElementError.failedToParse("\(LabelStatus.self)")
        }
        self.status = .init(rawValue: statusText)

        let countryName = strings[3].replacingOccurrences(of: "&nbsp;", with: "")
        self.country = CountryManager.shared.country(by: \.name, value: countryName)

        self.dateAndTime = strings[4]

        let authorHtml = try Kanna.HTML(html: strings[5], encoding: .utf8)
        guard let authorATag = authorHtml.at_css("a"),
              let username = authorATag.text,
              let userUrlString = authorATag["href"] else {
            throw PageElementError.failedToParse("\(UserLite.self)")
        }
        self.author = .init(name: username, urlString: userUrlString)
    }
}

final class LatestLabelPageManager: PageManager<LatestLabel> {
    init(apiService: APIServiceProtocol, type: LatestType) {
        let components = Calendar.current.dateComponents([.month, .year], from: Date())
        let month = String(format: "%02d", components.month ?? 1)
        let year = components.year ?? 2_023
        // swiftlint:disable:next line_length
        let configs = PageConfigs(baseUrlString: "https://www.metal-archives.com/archives/ajax-label-list/selection/\(year)-\(month)/by/\(type.path)/json/1?sEcho=1&iColumns=6&sColumns=&iDisplayStart=\(kDisplayStartPlaceholder)&iDisplayLength=\(kDisplayLengthPlaceholder)&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&mDataProp_4=4&mDataProp_5=5&iSortCol_0=4&sSortDir_0=desc&iSortingCols=1&bSortable_0=true&bSortable_1=true&bSortable_2=true&bSortable_3=true&bSortable_4=true&bSortable_5=true",
                                  pageSize: 200)
        super.init(configs: configs, apiService: apiService)
    }
}
