//
//  SongSimpleSearchResult.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 16/11/2022.
//

import Kanna

struct SongSimpleSearchResult {
    let band: BandLite
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
        guard strings.count == 4 else {
            throw PageElementError.badCount(count: strings.count, expectedCount: 4)
        }

        guard let aTag = try Kanna.HTML(html: strings[0], encoding: .utf8).at_css("a"),
              let bandName = aTag.text,
              let bandUrlString = aTag["href"],
              let band = BandLite(urlString: bandUrlString, name: bandName) else {
            throw PageElementError.failedToParse("\(BandLite.self): \(strings[0])")
        }
        self.band = band

        guard let aTag = try Kanna.HTML(html: strings[1], encoding: .utf8).at_css("a"),
              let releaseTitle = aTag.text,
              let releaseUrlString = aTag["href"],
              let release = ReleaseLite(urlString: releaseUrlString, title: releaseTitle) else {
            throw PageElementError.failedToParse("\(ReleaseLite.self): \(strings[1])")
        }
        self.release = release
        self.releaseType = .init(typeString: strings[2]) ?? .demo
        self.title = strings[3]
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
