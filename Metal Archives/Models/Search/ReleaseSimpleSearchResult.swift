//
//  ReleaseSimpleSearchResult.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 16/11/2022.
//

import Kanna

struct ReleaseSimpleSearchResult {
    let band: BandLite
    let release: ReleaseLite
    let releaseType: ReleaseType
    let date: String
}

extension ReleaseSimpleSearchResult: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.hashValue == rhs.hashValue }
}

extension ReleaseSimpleSearchResult: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(band)
        hasher.combine(release)
        hasher.combine(releaseType)
        hasher.combine(date)
    }
}

extension ReleaseSimpleSearchResult: PageElement {
    // swiftlint:disable line_length
    /*
     "<a href=\"https://www.metal-archives.com/bands/A_Serpent%27s_Hand/3540475068\" title=\"A Serpent's Hand (US)\">A Serpent's Hand</a>",
     "<a href=\"https://www.metal-archives.com/albums/A_Serpent%27s_Hand/Death/1079766\">Death</a> <!-- 11.746316 -->" ,
     "Full-length"      ,
     "October 7th, 2022 <!-- 2022-10-07 -->"
     */
    // swiftlint:enable line_length
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

        guard let aTag = try Kanna.HTML(html: strings[1], encoding: .utf8).at_css("a"),
              let releaseTitle = aTag.text,
              let releaseUrlString = aTag["href"],
              let release = ReleaseLite(urlString: releaseUrlString, title: releaseTitle)
        else {
            throw PageElementError.failedToParse("\(ReleaseLite.self): \(strings[1])")
        }
        self.release = release
        releaseType = .init(typeString: strings[2]) ?? .demo
        let dateRawString = strings[3]
        if let index = dateRawString.firstIndex(of: "<") {
            date = String(dateRawString[..<index]).trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            date = dateRawString
        }
    }
}

final class ReleaseSimpleSearchResultPageManager: PageManager<ReleaseSimpleSearchResult> {
    init(apiService: APIServiceProtocol, query: String) {
        // swiftlint:disable:next line_length
        let configs = PageConfigs(baseUrlString: "https://www.metal-archives.com/search/ajax-album-search/?field=title&query=\(query)&sEcho=1&iColumns=4&sColumns=&iDisplayStart=\(kDisplayStartPlaceholder)&iDisplayLength=\(kDisplayLengthPlaceholder)&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3",
                                  pageSize: 200)
        super.init(configs: configs, apiService: apiService)
    }
}
