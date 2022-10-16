//
//  TopBandsViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 16/10/2022.
//

import SwiftUI

enum TopBandsCategory {
    case releases, fullLengths, reviews

    var title: String {
        switch self {
        case .releases: return "Top 100 bands by number of releases"
        case .fullLengths: return "Top 100 bands by number of full-lengths"
        case .reviews: return "Top 100 bands by number of reviews"
        }
    }
}

final class TopBandsViewModel: ObservableObject {
    private let apiService: APIServiceProtocol
    let category: TopBandsCategory

    init(apiService: APIServiceProtocol, category: TopBandsCategory) {
        self.apiService = apiService
        self.category = category
    }
}
