//
//  HomeSectionViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 07/12/2022.
//

import Foundation

final class HomeSectionViewModel<T: HashableEquatablePageElement>: AdvancedSearchResultViewModel<T> {
    var chunkedResults: [[T]] {
        Array(results.prefix(HomeSettings.entriesPerPage * HomeSettings.maxPages))
            .chunked(into: HomeSettings.entriesPerPage)
    }
}
