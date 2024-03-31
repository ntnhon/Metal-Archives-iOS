//
//  ReleaseAdvancedSearchResult.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 04/12/2022.
//

import Foundation
import Kanna

struct ReleaseAdvancedSearchResult {
    let band: BandLite
    let release: ReleaseLite
    let type: ReleaseType
    let otherInfo: [String]
}

extension ReleaseAdvancedSearchResult: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.hashValue == rhs.hashValue }
}

extension ReleaseAdvancedSearchResult: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(band)
        hasher.combine(release)
        hasher.combine(type)
        hasher.combine(otherInfo)
    }
}

extension ReleaseAdvancedSearchResult: PageElement {
    // swiftlint:disable line_length
    /*
     "<a href=\"https://www.metal-archives.com/bands/Olympic/3540453058\" title=\"Olympic (CZ)\">Olympic</a>",
     "<a href=\"https://www.metal-archives.com/albums/Olympic/Bingo_-_Pickwick-Tee/776199\">Bingo / Pickwick-Tee</a> <!-- 1 -->" ,
     "Single"      ,
     "1964 <!-- 1964-00-00 -->"
     */
    // swiftlint:enable line_length
    init(from strings: [String]) throws {
        guard let aTag = try Kanna.HTML(html: strings[0], encoding: .utf8).at_css("a"),
              let bandName = aTag.text,
              let bandUrlString = aTag["href"],
              let band = BandLite(urlString: bandUrlString, name: bandName)
        else {
            throw PageElementError.failedToParse("\(BandLite.self): \(strings[0])")
        }
        self.band = band

        guard let aTag = try Kanna.HTML(html: strings[1], encoding: .utf8).at_css("a"),
              let releaseTitle = aTag.text,
              let releaseUrlString = aTag["href"],
              let release = ReleaseLite(urlString: releaseUrlString, title: releaseTitle)
        else {
            throw PageElementError.failedToParse("\(ReleaseLite.self): \(strings[1])")
        }
        self.release = release

        type = .init(typeString: strings[2]) ?? .demo
        otherInfo = Array(strings.dropFirst(3))
    }
}

final class ReleaseAdvancedSearchParams {
    var bandName = ""
    var exactMatchBandName = false
    var releaseTitle = ""
    var exactMatchReleaseTitle = false
    var fromDate = DateFormatter.default.date(from: "1960-01-01 00:00:00") ?? Date()
    var toDate = Date()
    var countries = [Country]()
    var location = ""
    var label = ""
    var indieLabel = false
    var catalogNumber = ""
    var identifier = ""
    var recordingInformation = ""
    var versionDescription = ""
    var additionalNote = ""
    var genre = ""
    var releaseTypes = [ReleaseType]()
    var releaseFormats = [ReleaseFormat]()
}

final class ReleaseAdvancedSearchResultPageManager: PageManager<ReleaseAdvancedSearchResult> {
    init(params: ReleaseAdvancedSearchParams) {
        var urlString = "https://www.metal-archives.com/search/ajax-advanced/searching/albums/?"

        urlString += "bandName=\(params.bandName)"

        if params.exactMatchBandName {
            urlString += "&exactBandMatch=1"
        }

        urlString += "&releaseTitle=\(params.releaseTitle)"

        if params.exactMatchReleaseTitle {
            urlString += "&exactReleaseMatch=1"
        }

        let calendar = Calendar.current

        let fromComponents = calendar.dateComponents([.year, .month], from: params.fromDate)
        if let fromYear = fromComponents.year,
           let fromMonth = fromComponents.month
        {
            urlString += "&releaseYearFrom=\(fromYear)"
            urlString += "&releaseMonthFrom=\(fromMonth)"
        }

        let toComponents = calendar.dateComponents([.year, .month], from: params.toDate)
        if let fromYear = toComponents.year,
           let fromMonth = toComponents.month
        {
            urlString += "&releaseYearTo=\(fromYear)"
            urlString += "&releaseMonthTo=\(fromMonth)"
        }

        if params.countries.isEmpty {
            urlString += "&country="
        } else {
            for country in params.countries {
                urlString += "&country[]=\(country.isoCode)"
            }
        }

        urlString += "&location=\(params.location)"

        urlString += "&releaseLabelName=\(params.label)"

        if params.indieLabel {
            urlString += "&indieLabel=1"
        }

        urlString += "&releaseCatalogNumber=\(params.catalogNumber)"
        urlString += "&releaseIdentifiers=\(params.identifier)"
        urlString += "&releaseRecordingInfo=\(params.recordingInformation)"
        urlString += "&releaseDescription=\(params.versionDescription)"
        urlString += "&releaseNotes=\(params.additionalNote)"
        urlString += "&genre=\(params.genre)"

        for type in params.releaseTypes {
            urlString += "&releaseType[]=\(type.rawValue)"
        }

        for format in params.releaseFormats {
            urlString += "&releaseFormat[]=\(format.rawValue)"
        }

        // swiftlint:disable:next line_length
        urlString += "&sEcho=1&iColumns=8&sColumns=&iDisplayStart=\(kDisplayStartPlaceholder)&iDisplayLength=\(kDisplayLengthPlaceholder)&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&mDataProp_4=4&mDataProp_5=5&mDataProp_6=6&mDataProp_7=7"

        let configs = PageConfigs(baseUrlString: urlString, pageSize: 200)
        super.init(configs: configs)
    }
}
