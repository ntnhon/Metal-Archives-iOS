//
//  BandAdvancedSearchResult.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 03/12/2022.
//

import Foundation
import Kanna

enum CountryOrLocation: Hashable {
    case country(Country)
    case location(String)
}

struct BandAdvancedSearchResult {
    let band: BandLite
    let note: String? // e.g. a.k.a. D.A.D.
    let genre: String
    let countryOrLocation: CountryOrLocation
    let year: String
    let label: String?
}

extension BandAdvancedSearchResult: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.hashValue == rhs.hashValue }
}

extension BandAdvancedSearchResult: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(band)
        hasher.combine(note)
        hasher.combine(countryOrLocation)
        hasher.combine(genre)
        hasher.combine(year)
        hasher.combine(label)
    }
}

extension BandAdvancedSearchResult: PageElement {
    /*
     "<a href=\"https://www.metal-archives.com/bands/Death/141\">Death</a>  <!-- 5.8260393 -->" ,
     "Death Metal (early); Progressive Death Metal (later)" ,
     "United States",
     "1984"
     */
    init(from strings: [String]) throws {
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

        let countryOrLocationString = strings[2]
        if countryOrLocationString.contains(",") {
            countryOrLocation = .location(countryOrLocationString)
        } else {
            countryOrLocation = .country(CountryManager.shared.country(by: \.name,
                                                                       value: countryOrLocationString))
        }

        let year = Int(strings[3]) ?? 0
        let thisYear = Calendar.current.component(.year, from: .init())
        let distance = thisYear - year
        switch distance {
        case 0:
            self.year = "\(year) (this year)"
        case 1:
            self.year = "\(year) (last year)"
        default:
            self.year = "\(year) (\(distance) years ago)"
        }

        if strings.count == 5 {
            label = strings[4]
        } else {
            label = nil
        }
    }
}

final class BandAdvancedSearchParams {
    var bandName = ""
    var exactMatch = false
    var genre = ""
    var countries = [Country]()
    var fromYear: Int?
    var toYear: Int?
    var notes = ""
    var statuses = [BandStatus]()
    var lyricalThemes = ""
    var location = ""
    var labelName = ""
    var indieLabel = false
}

final class BandAdvancedSearchResultPageManager: PageManager<BandAdvancedSearchResult> {
    init(apiService: APIServiceProtocol, params: BandAdvancedSearchParams) {
        var urlString = "https://www.metal-archives.com/search/ajax-advanced/searching/bands/?"

        urlString += "bandName=\(params.bandName)"

        if params.exactMatch {
            urlString += "&exactBandMatch=1"
        }

        urlString += "&genre=\(params.genre)"

        if params.countries.isEmpty {
            urlString += "&country="
        } else {
            for country in params.countries {
                urlString += "&country[]=\(country.isoCode)"
            }
        }

        if let fromYear = params.fromYear {
            urlString += "&yearCreationFrom=\(fromYear)"
        } else {
            urlString += "&yearCreationFrom="
        }

        if let toYear = params.toYear {
            urlString += "&yearCreationTo=\(toYear)"
        } else {
            urlString += "&yearCreationTo="
        }

        urlString += "&bandNotes=\(params.notes)"

        if params.statuses.isEmpty {
            urlString += "&status="
        } else {
            for status in params.statuses {
                urlString += "&status[]=\(status.paramValue)"
            }
        }

        urlString += "&themes=\(params.lyricalThemes)"
        urlString += "&location=\(params.location)"
        urlString += "&bandLabelName=\(params.labelName)"

        if params.indieLabel {
            urlString += "&indieLabel=1"
        }

        // swiftlint:disable:next line_length
        urlString += "&sEcho=1&iColumns=8&sColumns=&iDisplayStart=\(kDisplayStartPlaceholder)&iDisplayLength=\(kDisplayLengthPlaceholder)&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&mDataProp_4=4&mDataProp_5=5&mDataProp_6=6&mDataProp_7=7"

        let configs = PageConfigs(baseUrlString: urlString, pageSize: 200)
        super.init(configs: configs, apiService: apiService)
    }
}
