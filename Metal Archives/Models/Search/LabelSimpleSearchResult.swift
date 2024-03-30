//
//  LabelSimpleSearchResult.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 16/11/2022.
//

import Kanna

struct LabelSimpleSearchResult {
    let label: LabelLite
    let note: String?
    let country: Country
    let specialisation: String
}

extension LabelSimpleSearchResult: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.hashValue == rhs.hashValue }
}

extension LabelSimpleSearchResult: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(label)
        hasher.combine(note)
        hasher.combine(country)
        hasher.combine(specialisation)
    }
}

extension LabelSimpleSearchResult: PageElement {
    // swiftlint:disable line_length
    /*
     "<a href=\"https://www.metal-archives.com/labels/Aesthetic_Death/1053\">Aesthetic Death</a> (a.k.a. Aesthetic Death Records)",
     "United Kingdom",
     "Funeral Doom, Death/Doom Metal, Sludge, Black Metal"
     */
    // swiftlint:enable line_length
    init(from strings: [String]) throws {
        guard strings.count == 3 else {
            throw PageElementError.badCount(count: strings.count, expectedCount: 3)
        }

        guard let aTag = try Kanna.HTML(html: strings[0], encoding: .utf8).at_css("a"),
              let labelName = aTag.text,
              let labelUrlString = aTag["href"] else {
            throw PageElementError.failedToParse("\(LabelLite.self): \(strings[0])")
        }
        let thumbnailInfo = ThumbnailInfo(urlString: labelUrlString, type: .label)
        self.label = .init(thumbnailInfo: thumbnailInfo, name: labelName)
        self.note = strings[0].subString(after: "(", before: ")")
        self.country = CountryManager.shared.country(by: \.name, value: strings[1])
        self.specialisation = strings[2]
    }
}

final class LabelSimpleSearchResultPageManager: PageManager<LabelSimpleSearchResult> {
    init(apiService: APIServiceProtocol, query: String) {
        // swiftlint:disable:next line_length
        let configs = PageConfigs(baseUrlString: "https://www.metal-archives.com/search/ajax-label-search/?field=name&query=\(query)&sEcho=1&iColumns=3&sColumns=&iDisplayStart=\(kDisplayStartPlaceholder)&iDisplayLength=\(kDisplayLengthPlaceholder)&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2",
                                  pageSize: 200)
        super.init(configs: configs, apiService: apiService)
    }
}
