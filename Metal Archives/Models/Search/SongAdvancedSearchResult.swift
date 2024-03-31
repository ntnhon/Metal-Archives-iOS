//
//  SongAdvancedSearchResult.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 04/12/2022.
//

import Kanna

typealias SongAdvancedSearchResult = SongSimpleSearchResult

final class SongAdvancedSearchResultParams {
    var songTitle = ""
    var exactMatchSongTitle = false
    var bandName = ""
    var exactMatchBandName = false
    var releaseTitle = ""
    var exactMatchReleaseTitle = false
    var lyrics = ""
    var genre = ""
    var releaseTypes = [ReleaseType]()
}

final class SongAdvancedSearchResultPageManager: PageManager<SongAdvancedSearchResult> {
    init(params: SongAdvancedSearchResultParams) {
        var urlString = "https://www.metal-archives.com/search/ajax-advanced/searching/songs/?"

        urlString += "songTitle=\(params.songTitle)"

        if params.exactMatchSongTitle {
            urlString += "&exactSongMatch=1"
        }

        urlString += "&bandName=\(params.bandName)"

        if params.exactMatchBandName {
            urlString += "&exactBandMatch=1"
        }

        urlString += "&releaseTitle=\(params.releaseTitle)"

        if params.exactMatchReleaseTitle {
            urlString += "&exactReleaseMatch=1"
        }

        urlString += "&lyrics=\(params.lyrics)"
        urlString += "&genre=\(params.genre)"

        for type in params.releaseTypes {
            urlString += "&releaseType[]=\(type.rawValue)"
        }

        // swiftlint:disable:next line_length
        urlString += "&sEcho=1&iColumns=6&sColumns=&iDisplayStart=\(kDisplayStartPlaceholder)&iDisplayLength=\(kDisplayLengthPlaceholder)&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&mDataProp_4=4&mDataProp_5=5"

        let configs = PageConfigs(baseUrlString: urlString, pageSize: 200)
        super.init(configs: configs)
    }
}
