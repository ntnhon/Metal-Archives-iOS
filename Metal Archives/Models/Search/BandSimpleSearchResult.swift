//
//  BandSimpleSearchResult.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 15/11/2022.
//

import Kanna

struct BandSimpleSearchResult {
    let band: BandLite
    let note: String? // e.g. a.k.a. D.A.D.
    let genre: String
    let country: Country
}

extension BandSimpleSearchResult: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.hashValue == rhs.hashValue }
}

extension BandSimpleSearchResult: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(band)
        hasher.combine(note)
        hasher.combine(country)
        hasher.combine(genre)
    }
}

extension BandSimpleSearchResult: PageElement {
    /*
     "<a href=\"https://www.metal-archives.com/bands/Death/141\">Death</a>  <!-- 5.8260393 -->" ,
     "Death Metal (early); Progressive Death Metal (later)" ,
     "United States"
     */
    init(from strings: [String]) throws {
        guard strings.count == 3 else {
            throw PageElementError.badCount(count: strings.count, expectedCount: 3)
        }

        guard let aTag = try Kanna.HTML(html: strings[0], encoding: .utf8).at_css("a"),
              let bandName = aTag.text,
              let bandUrlString = aTag["href"],
              let band = BandLite(urlString: bandUrlString, name: bandName)
        else {
            throw PageElementError.failedToParse("\(BandLite.self): \(strings[0])")
        }
        self.band = band

        if let noteHtml = strings[0].subString(after: "</a> (", before: ")") {
            note = try Kanna.HTML(html: noteHtml, encoding: .utf8).text
        } else {
            note = nil
        }

        genre = strings[1]
        country = CountryManager.shared.country(by: \.name, value: strings[2])
    }
}

final class BandSimpleSearchResultPageManager: PageManager<BandSimpleSearchResult> {
    init(apiService: APIServiceProtocol, query: String) {
        // swiftlint:disable:next line_length
        let configs = PageConfigs(baseUrlString: "https://www.metal-archives.com/search/ajax-band-search/?field=name&query=\(query)&sEcho=1&iColumns=3&sColumns=&iDisplayStart=\(kDisplayStartPlaceholder)&iDisplayLength=\(kDisplayLengthPlaceholder)&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2",
                                  pageSize: 200)
        super.init(configs: configs, apiService: apiService)
    }
}
