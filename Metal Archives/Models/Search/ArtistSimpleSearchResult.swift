//
//  ArtistSimpleSearchResult.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 16/11/2022.
//

import Kanna

struct ArtistSimpleSearchResult {
    let artist: ArtistLite
    let note: String?
    let realName: String
    let country: Country
    let bands: [BandLite]
    let bandsString: String
}

extension ArtistSimpleSearchResult: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.hashValue == rhs.hashValue }
}

extension ArtistSimpleSearchResult: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(artist)
        hasher.combine(realName)
        hasher.combine(country)
        hasher.combine(bands)
        hasher.combine(bandsString)
    }
}

extension ArtistSimpleSearchResult: PageElement {
    // swiftlint:disable line_length
    /*
     "<a href=\"https://www.metal-archives.com/artists/Corporate_Death/33140\">Corporate Death</a> ",
     "Lance Lencioni",
     "United States",
     "<a href=\"https://www.metal-archives.com/bands/Macabre/167\">Macabre</a>, <a href=\"https://www.metal-archives.com/bands/Java/3540294733\">Java</a>, <a href=\"https://www.metal-archives.com/bands/Idiom/3540294674\">Idiom</a>, <a href=\"https://www.metal-archives.com/bands/Cephalic_Carnage/910\">Cephalic Carnage</a>, etc.&nbsp;"
     */
    // swiftlint:enable line_length
    init(from strings: [String]) throws {
        guard strings.count == 4 else {
            throw PageElementError.badCount(count: strings.count, expectedCount: 4)
        }

        guard let aTag = try Kanna.HTML(html: strings[0], encoding: .utf8).at_css("a"),
              let name = aTag.text,
              let urlString = aTag["href"],
              let artist = ArtistLite(urlString: urlString, name: name)
        else {
            throw PageElementError.failedToParse("\(ArtistLite.self): \(strings[0])")
        }
        self.artist = artist

        if let artistText = try Kanna.HTML(html: strings[0], encoding: .utf8).text {
            let note = artistText
                .replacingOccurrences(of: artist.name, with: "")
                .replacingOccurrences(of: "(", with: "")
                .replacingOccurrences(of: ")", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if note.isEmpty {
                self.note = nil
            } else {
                self.note = note
            }
        } else {
            note = strings[0].subString(after: "(", before: ")")
        }

        realName = strings[1]
        country = CountryManager.shared.country(by: \.name, value: strings[2])

        var bands = [BandLite]()
        let html = try Kanna.HTML(html: strings[3], encoding: .utf8)
        for aTag in html.css("a") {
            if let name = aTag.text,
               let urlString = aTag["href"],
               let band = BandLite(urlString: urlString, name: name)
            {
                bands.append(band)
            }
        }
        self.bands = bands
        bandsString = html.text ?? ""
    }
}

final class ArtistSimpleSearchResultPageManager: PageManager<ArtistSimpleSearchResult> {
    init(apiService: APIServiceProtocol, query: String) {
        // swiftlint:disable:next line_length
        let configs = PageConfigs(baseUrlString: "https://www.metal-archives.com/search/ajax-artist-search/?field=alias&query=\(query)&sEcho=1&iColumns=4&sColumns=&iDisplayStart=\(kDisplayStartPlaceholder)&iDisplayLength=\(kDisplayLengthPlaceholder)&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3",
                                  pageSize: 200)
        super.init(configs: configs, apiService: apiService)
    }
}
