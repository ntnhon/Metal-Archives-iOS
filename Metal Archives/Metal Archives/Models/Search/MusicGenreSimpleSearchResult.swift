//
//  MusicGenreSimpleSearchResult.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 15/11/2022.
//

import Foundation

typealias MusicGenreSimpleSearchResult = BandSimpleSearchResult

final class MusicGenreSimpleSearchResultPageManager: PageManager<MusicGenreSimpleSearchResult> {
    init(apiService: APIServiceProtocol, query: String) {
        // swiftlint:disable:next line_length
        let configs = PageConfigs(baseUrlString: "https://www.metal-archives.com/search/ajax-band-search/?field=genre&query=\(query)&sEcho=1&iColumns=3&sColumns=&iDisplayStart=\(kDisplayStartPlaceholder)&iDisplayLength=\(kDisplayLengthPlaceholder)&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2",
                                  pageSize: 200)
        super.init(configs: configs, apiService: apiService)
    }
}
