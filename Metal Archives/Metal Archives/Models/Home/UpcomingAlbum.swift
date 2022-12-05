//
//  UpcomingAlbum.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 04/12/2022.
//

import Foundation
import Kanna

struct UpcomingAlbum {
    let bands: [BandLite]
    let release: ReleaseLite
    let releaseType: ReleaseType
    let genre: String
    let date: String
}

extension UpcomingAlbum: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.hashValue == rhs.hashValue }
}

extension UpcomingAlbum: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(bands)
        hasher.combine(release)
        hasher.combine(releaseType)
        hasher.combine(genre)
        hasher.combine(date)
    }
}

extension UpcomingAlbum: Identifiable {
    var id: Int { hashValue }
}

extension [UpcomingAlbum]: Identifiable {
    public var id: Int { hashValue }
}

extension UpcomingAlbum: PageElement {
    // swiftlint:disable line_length
    /*
     "<a href=\"https://www.metal-archives.com/bands/Ceremonial_Torture/3540415820\">Ceremonial Torture</a> / <a href=\"https://www.metal-archives.com/bands/Cult_of_Eibon/3540408018\">Cult of Eibon</a>",
     "<a href=\"https://www.metal-archives.com/albums/Ceremonial_Torture_-_Cult_of_Eibon/Necronomical_Mirror_Divination/1081924\">Necronomical Mirror Divination</a>",
     "Split",
     "Black Metal | Black Metal",
     "December 9th, 2022",
     "2022-10-15 12:50:23"
     */
    // swiftlint:enable line_length
    init(from strings: [String]) throws {
        guard strings.count == 6 else {
            throw PageElementError.badCount(count: strings.count, expectedCount: 6)
        }

        let bandsHtml = try Kanna.HTML(html: strings[0], encoding: .utf8)
        var bands = [BandLite]()
        for aTag in bandsHtml.css("a") {
            if let name = aTag.text,
               let urlString = aTag["href"],
               let band = BandLite(urlString: urlString, name: name) {
                bands.append(band)
            }
        }
        self.bands = bands

        let releaseHtml = try Kanna.HTML(html: strings[1], encoding: .utf8)
        guard let aTag = releaseHtml.at_css("a"),
              let title = aTag.text,
              let urlString = aTag["href"],
              let release = ReleaseLite(urlString: urlString, title: title) else {
            throw PageElementError.failedToParse("\(ReleaseLite.self)")
        }
        self.release = release

        self.releaseType = .init(typeString: strings[2]) ?? .demo
        self.genre = strings[3]
        self.date = strings[4]
    }
}

final class UpcomingAlbumPageManager: PageManager<UpcomingAlbum> {
    init(apiService: APIServiceProtocol) {
        let formatter = DateFormatter(dateFormat: "yyyy-MM-dd")
        let today = formatter.string(from: Date())
        // swiftlint:disable:next line_length
        let configs = PageConfigs(baseUrlString: "https://www.metal-archives.com/release/ajax-upcoming/json/1?sEcho=28&iColumns=6&sColumns=&iDisplayStart=\(kDisplayStartPlaceholder)&iDisplayLength=\(kDisplayLengthPlaceholder)&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&mDataProp_4=4&mDataProp_5=5&iSortCol_0=4&sSortDir_0=asc&iSortingCols=1&bSortable_0=true&bSortable_1=true&bSortable_2=true&bSortable_3=true&bSortable_4=true&bSortable_5=true&includeVersions=0&fromDate=\(today)&toDate=0000-00-00",
                                  pageSize: 100)
        super.init(configs: configs, apiService: apiService)
    }
}
