//
//  DeceasedArtist.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 23/10/2022.
//

import Kanna

struct DeceasedArtist {
    let artist: ArtistLite
    let country: Country
    let bands: [BandLite]
    let bandsString: String
    let dateOfDeath: String
    let causeOfDeath: String
}

extension DeceasedArtist: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.artist == rhs.artist }
}

extension DeceasedArtist: PageElement {
    // swiftlint:disable line_length
    /*
     "<a href=\"https://www.metal-archives.com/artists/Gustavo_Zavala/108202\">Gustavo Zavala</a>",
     "Argentina",
     "<a href=\"https://www.metal-archives.com/bands/Tren_Loco/550\">Tren Loco</a>, <a href=\"https://www.metal-archives.com/bands/Pablo_G._Soler/27221\">Pablo G. Soler</a>, <a href=\"https://www.metal-archives.com/bands/Apocalipsis/50436\">Apocalipsis</a>,  etc.",
     "Mar 28th, 2022",
     "Cancer"
     */
    // swiftlint:enable line_length
    init(from strings: [String]) throws {
        guard strings.count == 5 else {
            throw PageElementError.badCount(count: strings.count, expectedCount: 5)
        }

        guard let aTag = try Kanna.HTML(html: strings[0], encoding: .utf8).at_css("a"),
              let name = aTag.text,
              let urlString = aTag["href"],
              let artist = ArtistLite(urlString: urlString, name: name)
        else {
            throw PageElementError.failedToParse("\(ArtistLite.self): \(strings[0])")
        }
        self.artist = artist

        country = CountryManager.shared.country(by: \.name, value: strings[1])

        let bandsHtml = try Kanna.HTML(html: strings[2], encoding: .utf8)
        var bands = [BandLite]()
        for aTag in bandsHtml.css("a") {
            if let bandName = aTag.text,
               let bandUrlString = aTag["href"],
               let band = BandLite(urlString: bandUrlString, name: bandName)
            {
                bands.append(band)
            }
        }
        self.bands = bands
        bandsString = bandsHtml.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        dateOfDeath = strings[3]
        causeOfDeath = strings[4]
    }
}

final class DeceasedArtistPageManager: PageManager<DeceasedArtist> {
    init(sortOptions: SortOption) {
        // swiftlint:disable:next line_length
        let configs = PageConfigs(baseUrlString: "https://www.metal-archives.com/artist/ajax-rip?sEcho=2&iColumns=5&sColumns=&iDisplayStart=\(kDisplayStartPlaceholder)&iDisplayLength=\(kDisplayLengthPlaceholder)&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&mDataProp_4=4&sSearch=&bRegex=false&sSearch_0=&bRegex_0=false&bSearchable_0=true&sSearch_1=&bRegex_1=false&bSearchable_1=true&sSearch_2=&bRegex_2=false&bSearchable_2=true&sSearch_3=&bRegex_3=false&bSearchable_3=true&sSearch_4=&bRegex_4=false&bSearchable_4=true&iSortCol_0=\(kSortColumnPlaceholder)&sSortDir_0=\(kSortDirectionPlaceholder)&iSortingCols=\(kSortColumnPlaceholder)&bSortable_0=true&bSortable_1=true&bSortable_2=false&bSortable_3=true&bSortable_4=false")
        super.init(configs: configs, options: sortOptions.options)
    }
}

extension DeceasedArtistPageManager {
    enum SortOption: Equatable {
        case country(Order)
        case date(Order)

        var title: String {
            switch self {
            case .country(.ascending):
                "Country ↑"
            case .country(.descending):
                "Country ↓"
            case .date(.ascending):
                "Date ↑"
            case .date(.descending):
                "Date ↓"
            }
        }

        var column: Int {
            switch self {
            case .country:
                1
            case .date:
                3
            }
        }

        var order: Order {
            switch self {
            case .country(.ascending), .date(.ascending):
                .ascending
            default:
                .descending
            }
        }

        var options: [String: String] {
            [kSortColumnPlaceholder: "\(column)", kSortDirectionPlaceholder: order.queryValue]
        }

        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.country(.ascending), .country(.ascending)),
                 (.country(.descending), .country(.descending)),
                 (.date(.ascending), .date(.ascending)),
                 (.date(.descending), .date(.descending)):
                true
            default:
                false
            }
        }
    }
}
