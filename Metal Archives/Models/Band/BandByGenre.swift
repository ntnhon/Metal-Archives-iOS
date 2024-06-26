//
//  BandByGenre.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 22/10/2022.
//

import Foundation

typealias BandByGenre = BandByAlphabet

final class BandsByGenrePageManager: PageManager<BandByGenre> {
    init(genre: Genre, sortOptions: SortOption) {
        // swiftlint:disable:next line_length
        let configs = PageConfigs(baseUrlString: "https://www.metal-archives.com/browse/ajax-genre/g/\(genre.parameterString)/json/1?sEcho=1&iColumns=4&sColumns=&iDisplayStart=\(kDisplayStartPlaceholder)&iDisplayLength=\(kDisplayLengthPlaceholder)&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&iSortCol_0=\(kSortColumnPlaceholder)&sSortDir_0=\(kSortDirectionPlaceholder)&iSortingCols=1&bSortable_0=true&bSortable_1=true&bSortable_2=true&bSortable_3=true",
                                  pageSize: 500)
        super.init(configs: configs, options: sortOptions.options)
    }
}

extension BandsByGenrePageManager {
    typealias SortOption = BandByAlphabetPageManager.SortOption
}
