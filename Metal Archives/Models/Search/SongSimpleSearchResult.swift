//
//  SongSimpleSearchResult.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 16/11/2022.
//

import Kanna

struct SongSimpleSearchResult {
    let band: BandExtraLite
    let release: ReleaseLite
    let releaseType: ReleaseType
    let title: String
}

extension SongSimpleSearchResult: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.hashValue == rhs.hashValue }
}

extension SongSimpleSearchResult: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(band)
        hasher.combine(release)
        hasher.combine(releaseType)
        hasher.combine(title)
    }
}

extension SongSimpleSearchResult: PageElement {
    // swiftlint:disable line_length
    /*
     "<a href=\"https://www.metal-archives.com/bands/3_Pieces_of_Evil/3540473664\" title=\"3 Pieces of Evil (US)\">3 Pieces of Evil</a>",
     "<a href=\"https://www.metal-archives.com/albums/3_Pieces_of_Evil/Weeping_Willow/877874\">Weeping Willow</a>",
     "Demo",
     "Death"
     */
    // swiftlint:enable line_length
    init(from strings: [String]) throws {
        guard strings.count >= 4 else {
            throw PageElementError.badCount(count: strings.count, expectedCount: 4)
        }

        let html = try Kanna.HTML(html: strings[0], encoding: .utf8)
        if strings[0].contains("<a") {
            guard let aTag = html.at_css("a"),
                  let bandName = aTag.text,
                  let bandUrlString = aTag["href"]
            else {
                throw PageElementError.failedToParse("\(BandExtraLite.self): \(strings[0])")
            }
            band = .init(urlString: bandUrlString, name: bandName)
        } else {
            guard let bandName = html.at_css("span")?.text else {
                throw PageElementError.failedToParse("\(BandExtraLite.self): \(strings[0])")
            }
            band = .init(urlString: nil, name: bandName)
        }

        guard let aTag = try Kanna.HTML(html: strings[1], encoding: .utf8).at_css("a"),
              let releaseTitle = aTag.text,
              let releaseUrlString = aTag["href"],
              let release = ReleaseLite(urlString: releaseUrlString, title: releaseTitle)
        else {
            throw PageElementError.failedToParse("\(ReleaseLite.self): \(strings[1])")
        }
        self.release = release
        releaseType = .init(typeString: strings[2]) ?? .demo
        title = strings[3]
    }
}

final class SongSimpleSearchResultPageManager: PageManager<SongSimpleSearchResult> {
    init(apiService: APIServiceProtocol, query: String) {
        // swiftlint:disable:next line_length
        let configs = PageConfigs(baseUrlString: "https://www.metal-archives.com/search/ajax-song-search/?field=title&query=\(query)&sEcho=1&iColumns=4&sColumns=&iDisplayStart=\(kDisplayStartPlaceholder)&iDisplayLength=kDisplayLengthPlaceholder\(kDisplayLengthPlaceholder)&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3",
                                  pageSize: 200)
        super.init(configs: configs, apiService: apiService)
    }
}
