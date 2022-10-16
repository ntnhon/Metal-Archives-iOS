//
//  TopAlbumsViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 16/10/2022.
//

import SwiftUI

enum TopAlbumsCategory {
    case reviews, mostOwned, mostWanted

    var title: String {
        switch self {
        case .reviews: return "Top 100 albums by number of reviews"
        case .mostOwned: return "Top 100 most owned albums"
        case .mostWanted: return "Top 100 most wanted albums"
        }
    }
}

final class TopAlbumsViewModel: ObservableObject {
    private let apiService: APIServiceProtocol
    let category: TopAlbumsCategory

    init(apiService: APIServiceProtocol, category: TopAlbumsCategory) {
        self.apiService = apiService
        self.category = category
    }
}
