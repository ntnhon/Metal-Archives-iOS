//
//  BandAdvancedSearchResult.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 03/12/2022.
//

import Foundation

typealias BandAdvancedSearchResult = BandSimpleSearchResult

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
                urlString += "$status[]=\(status.paramValue)"
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
