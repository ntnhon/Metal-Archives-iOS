//
//  LyricalSimpleSearchResult.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 16/11/2022.
//

import Kanna

struct LyricalSimpleSearchResult {
    let band: BandLite
    let note: String? // e.g. a.k.a. D.A.D.
    let genre: String
    let country: Country
    let lyricalThemes: String
}

extension LyricalSimpleSearchResult: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.hashValue == rhs.hashValue }
}

extension LyricalSimpleSearchResult: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(band)
        hasher.combine(note)
        hasher.combine(country)
        hasher.combine(genre)
        hasher.combine(lyricalThemes)
    }
}

extension LyricalSimpleSearchResult: PageElement {
    // swiftlint:disable line_length
    /*
     "<a href=\"https://www.metal-archives.com/bands/%24lutrot/3540438154\">$lutrot</a> (<strong>a.k.a.</strong> SlutRot, $lutRot) <!-- 4.4575386 -->" ,
     "Slam/Brutal Death Metal" ,
     "United States"  ,
     "Gore"
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

        if let noteHtml = strings[0].subString(after: "</a> (", before: ")") {
            self.note = try Kanna.HTML(html: noteHtml, encoding: .utf8).text
        } else {
            self.note = nil
        }

        self.genre = strings[1]
        self.country = CountryManager.shared.country(by: \.name, value: strings[2])
        self.lyricalThemes = strings[3]
    }
}

final class LyricalSimpleSearchResultPageManager: PageManager<LyricalSimpleSearchResult> {
    init(apiService: APIServiceProtocol, query: String) {
        // swiftlint:disable:next line_length
        let configs = PageConfigs(baseUrlString: "https://www.metal-archives.com/search/ajax-band-search/?field=themes&query=\(query)&sEcho=1&iColumns=4&sColumns=&iDisplayStart=\(kDisplayStartPlaceholder)&iDisplayLength=\(kDisplayLengthPlaceholder)&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3",
                                  pageSize: 200)
        super.init(configs: configs, apiService: apiService)
    }
}
