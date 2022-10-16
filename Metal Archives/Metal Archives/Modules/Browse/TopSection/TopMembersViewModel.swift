//
//  TopMembersViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 16/10/2022.
//

import SwiftUI

enum TopMembersCategory {
    case submittedBands, writtenReviews, submittedAlbums, artistsAdded

    var title: String {
        switch self {
        case .submittedBands: return "Top 100 members by number of submitted bands"
        case .writtenReviews: return "Top 100 members by number of written reviews"
        case .submittedAlbums: return "Top 100 members by number of submitted albums"
        case .artistsAdded: return "Top 100 members by number of artists added"
        }
    }
}

final class TopMembersViewModel: ObservableObject {
    private let apiService: APIServiceProtocol
    let category: TopMembersCategory

    init(apiService: APIServiceProtocol, category: TopMembersCategory) {
        self.apiService = apiService
        self.category = category
    }
}
