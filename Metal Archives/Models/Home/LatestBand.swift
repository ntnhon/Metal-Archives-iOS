//
//  LatestBand.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 22/12/2022.
//

import Foundation
import Kanna

struct LatestBand {
    let date: String
    let band: BandLite
    let country: Country
    let genre: String
    let dateAndTime: String
    let author: UserLite
}

extension LatestBand: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.hashValue == rhs.hashValue }
}

extension LatestBand: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(band)
        hasher.combine(country)
        hasher.combine(genre)
        hasher.combine(date)
        hasher.combine(author)
    }
}

extension LatestBand: Identifiable {
    public var id: Int { hashValue }
}

extension LatestBand: PageElement {
    /*
     "December 22",
     "<a href=\"https://www.metal-archives.com/bands/Cryptogenic/3540517357\">Cryptogenic</a>",
     "<a href=\"https://www.metal-archives.com/lists/US\">United States</a>",
     "Death/Thrash Metal",
     "Dec 22nd, 13:10",
     "<a href=\"https://www.metal-archives.com/users/KingSpooky\" class=\"profileMenu\">KingSpooky</a>"
     */
    init(from strings: [String]) throws {
        guard strings.count == 6 else {
            throw PageElementError.badCount(count: strings.count, expectedCount: 6)
        }

        date = strings[0]

        let bandHtml = try Kanna.HTML(html: strings[1], encoding: .utf8)
        guard let bandATag = bandHtml.at_css("a"),
              let bandName = bandATag.text,
              let bandUrlString = bandATag["href"],
              let band = BandLite(urlString: bandUrlString, name: bandName)
        else {
            throw PageElementError.failedToParse("\(BandLite.self)")
        }
        self.band = band

        let countryHtml = try Kanna.HTML(html: strings[2], encoding: .utf8)
        if let countryATag = countryHtml.at_css("a"),
           let countryHtmlString = countryATag["href"],
           let countryCode = countryHtmlString.components(separatedBy: "/").last
        {
            country = CountryManager.shared.country(by: \.isoCode, value: countryCode)
        } else {
            country = .unknown
        }

        genre = strings[3]
        dateAndTime = strings[4]

        let authorHtml = try Kanna.HTML(html: strings[5], encoding: .utf8)
        guard let authorATag = authorHtml.at_css("a"),
              let username = authorATag.text,
              let userUrlString = authorATag["href"]
        else {
            throw PageElementError.failedToParse("\(UserLite.self)")
        }
        author = .init(name: username, urlString: userUrlString)
    }
}

final class LatestBandPageManager: PageManager<LatestBand> {
    init(apiService: APIServiceProtocol, type: LatestType) {
        let components = Calendar.current.dateComponents([.month, .year], from: Date())
        let month = String(format: "%02d", components.month ?? 1)
        let year = components.year ?? 2024
        // swiftlint:disable:next line_length
        let configs = PageConfigs(baseUrlString: "https://www.metal-archives.com/archives/ajax-band-list/selection/\(year)-\(month)/by/\(type.path)/json/1?sEcho=1&iColumns=6&sColumns=&iDisplayStart=\(kDisplayStartPlaceholder)&iDisplayLength=\(kDisplayLengthPlaceholder)&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&mDataProp_4=4&mDataProp_5=5&iSortCol_0=4&sSortDir_0=desc&iSortingCols=1&bSortable_0=true&bSortable_1=true&bSortable_2=true&bSortable_3=true&bSortable_4=true&bSortable_5=true",
                                  pageSize: 200)
        super.init(configs: configs, apiService: apiService)
    }
}
