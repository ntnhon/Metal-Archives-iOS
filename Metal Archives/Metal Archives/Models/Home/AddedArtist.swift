//
//  AddedArtist.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 23/12/2022.
//

import Foundation
import Kanna

struct AddedArtist {
    let date: String
    let artist: ArtistLite
    let realName: String?
    let country: Country
    let bands: [BandLite]
    let dateAndTime: String
    let author: UserLite
}

extension AddedArtist: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.hashValue == rhs.hashValue }
}

extension AddedArtist: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(date)
        hasher.combine(artist)
        hasher.combine(realName)
        hasher.combine(country)
        hasher.combine(bands)
        hasher.combine(dateAndTime)
        hasher.combine(author)
    }
}

extension AddedArtist: Identifiable {
    public var id: Int { hashValue }
}

extension AddedArtist: PageElement {
    // swiftlint:disable line_length
    /*
     "December 21",
     "<a href=\"https://www.metal-archives.com/artists/Lord_Vantom/975934\">Lord Vantom</a>",
     "United States</a>",
     "<a href=\"https://www.metal-archives.com/bands/Fetish_Altar/3540404515\">Fetish Altar</a>, <a href=\"https://www.metal-archives.com/bands/%D0%9F%D1%80%D0%B8%D0%B7%D1%80%D0%B0%D0%BA/3540412940\">Призрак</a>",
     "2022-12-21 08:53:21",
     "<a href=\"https://www.metal-archives.com/users/airzez\" class=\"profileMenu\">airzez</a>"
     */
    // swiftlint:enable line_length
    init(from strings: [String]) throws {
        guard strings.count == 6 else {
            throw PageElementError.badCount(count: strings.count, expectedCount: 6)
        }

        self.date = strings[0]

        let artistHtml = try Kanna.HTML(html: strings[1], encoding: .utf8)
        guard let artistATag = artistHtml.at_css("a"),
              let artistName = artistATag.text,
              let artistUrlString = artistATag["href"],
              let artist = ArtistLite(urlString: artistUrlString, name: artistName) else {
            throw PageElementError.failedToParse("\(ArtistLite.self)")
        }
        self.artist = artist
        self.realName = strings[1].subString(after: "(", before: ")")

        let countryName = strings[2].replacingOccurrences(of: "</a>", with: "")
        self.country = CountryManager.shared.country(by: \.name, value: countryName)

        let bandsHtml = try Kanna.HTML(html: strings[3], encoding: .utf8)
        var bands = [BandLite]()
        for aTag in bandsHtml.css("a") {
            if let bandName = aTag.text,
               let bandUrlString = aTag["href"],
               let band = BandLite(urlString: bandUrlString, name: bandName) {
                bands.append(band)
            }
        }
        self.bands = bands

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

final class AddedArtistPageManager: PageManager<AddedArtist> {
    init(apiService: APIServiceProtocol) {
        let components = Calendar.current.dateComponents([.month, .year], from: Date())
        let month = components.month ?? 1
        let year = components.year ?? 2_023
        // swiftlint:disable:next line_length
        let configs = PageConfigs(baseUrlString: "https://www.metal-archives.com/archives/ajax-artist-list/selection/\(year)-\(month)/by/created/json/1?sEcho=3&iColumns=6&sColumns=&iDisplayStart=\(kDisplayStartPlaceholder)&iDisplayLength=\(kDisplayLengthPlaceholder)&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&mDataProp_4=4&mDataProp_5=5&iSortCol_0=4&sSortDir_0=desc&iSortingCols=1&bSortable_0=true&bSortable_1=true&bSortable_2=true&bSortable_3=false&bSortable_4=true&bSortable_5=true",
                                  pageSize: 200)
        super.init(configs: configs, apiService: apiService)
    }
}
