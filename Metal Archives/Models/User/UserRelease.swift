//
//  UserRelease.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 09/11/2022.
//

import Foundation
import Kanna

enum UserReleaseType: Int {
    case collection = 1
    case forTrade = 2
    case wanted = 3
}

struct UserRelease {
    let bands: [BandLite]
    let release: ReleaseLite
    let releaseNote: String? // E.g: (Demo), (EP)...
    let version: String
    let note: String?
}

extension UserRelease: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.hashValue == rhs.hashValue }
}

extension UserRelease: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(bands)
        hasher.combine(release)
        hasher.combine(releaseNote)
        hasher.combine(version)
        hasher.combine(note)
    }
}

extension UserRelease: PageElement {
    // swiftlint:disable line_length
    /*
    "<a class=\"iconContainer ui-state-default ui-corner-all\" href=\"https://www.metal-archives.com/collection/owner-list/releaseId/512737\" title=\"See who owns / wants this album\"><span class=\"ui-icon ui-icon-person\">Owners</span></a>",
    "<a href=\"https://www.metal-archives.com/bands/Classica/2462\">Classica</a> / <a href=\"https://www.metal-archives.com/bands/Ruff_Stuff/3540396842\">Ruff Stuff</a> / <a href=\"https://www.metal-archives.com/bands/Majesty/3540396843\">Majesty</a>",
    "<a href=\"https://www.metal-archives.com/albums/Classica_-_Ruff_Stuff_-_Majesty/Rock_from_the_Heart_of_Europe/512737\">Rock from the Heart of Europe</a> (Split)",
    "<span id='version_512737_512737'>1991, 12\" vinyl, Breakin' Records </span>",
    ""
     */
    // swiftlint:enable line_length
    init(from strings: [String]) throws {
        guard strings.count >= 5 else {
            throw PageElementError.badCount(count: strings.count, expectedCount: 5)
        }

        var bands = [BandLite]()
        let bandHtml = try Kanna.HTML(html: strings[1], encoding: .utf8)
        for aTag in bandHtml.css("a") {
            if let bandName = aTag.text,
               let urlString = aTag["href"],
               let band = BandLite(urlString: urlString, name: bandName) {
                bands.append(band)
            }
        }
        self.bands = bands

        guard let aTag = try Kanna.HTML(html: strings[2], encoding: .utf8).at_css("a"),
              let releaseTitle = aTag.text,
              let releaseUrlString = aTag["href"],
              let release = ReleaseLite(urlString: releaseUrlString, title: releaseTitle) else {
            throw PageElementError.failedToParse("\(BandLite.self): \(strings[2])")
        }
        self.release = release
        self.releaseNote = aTag.text

        let version = strings[3]
        self.version = (try? Kanna.HTML(html: version, encoding: .utf8).text) ?? version

        let note = strings[4]
        self.note = note.isEmpty ? nil : note
    }
}

final class UserReleasePageManager: PageManager<UserRelease> {
    init(apiService: APIServiceProtocol, userId: String, type: UserReleaseType) {
        // swiftlint:disable:next line_length
        let configs = PageConfigs(baseUrlString: "https://www.metal-archives.com/collection/ajax-view/id/\(userId)/type/\(type.rawValue)/json/1?sEcho=1&iColumns=5&sColumns=&iDisplayStart=\(kDisplayStartPlaceholder)&iDisplayLength=\(kDisplayLengthPlaceholder)&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&mDataProp_4=4",
                                  pageSize: 200)
        super.init(configs: configs, apiService: apiService)
    }
}
