//
//  TopCategory.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 16/10/2022.
//

import Foundation

enum TopCategory {
    case bands, bandsByReleases, bandsByFullLengths, bandsByReviews
    case albums, albumsByReviews, albumsByMostOwned, albumsByMostWanted
    case members
    case membersBySubmittedBands
    case membersByWrittenReviews
    case membersBySubmittedAlbums
    case membersByArtistsAdded

    var title: String {
        switch self {
        case .bands: return "Top 100 bands"
        case .bandsByReleases: return "Number of releases"
        case .bandsByFullLengths: return "Number of full-lengths"
        case .bandsByReviews: return "Number of reviews"
        case .albums: return "Top 100 albums"
        case .albumsByReviews: return "Reviews"
        case .albumsByMostOwned: return "Most owned"
        case .albumsByMostWanted: return "Most wanted"
        case .members: return "Top 100 members"
        case .membersBySubmittedBands: return "Submitted bands"
        case .membersByWrittenReviews: return "Written reviews"
        case .membersBySubmittedAlbums: return "Submitted albums (since 2004)"
        case .membersByArtistsAdded: return "Artists added (since 2011)"
        }
    }

    var icon: String? {
        switch self {
        case .bands: return "person.3.fill"
        case .albums: return "opticaldisc"
        case .members: return "person.fill"
        default: return nil
        }
    }
}

struct GroupedTopCategory: Identifiable {
    let id = UUID()
    let category: TopCategory
    var subCategories: [GroupedTopCategory]?
}

extension GroupedTopCategory {
    static let bands = GroupedTopCategory(category: .bands,
                                          subCategories: [.init(category: .bandsByReleases),
                                                          .init(category: .bandsByFullLengths),
                                                          .init(category: .bandsByReviews)])

    static let albums = GroupedTopCategory(category: .albums,
                                           subCategories: [.init(category: .albumsByReviews),
                                                           .init(category: .albumsByMostOwned),
                                                           .init(category: .albumsByMostWanted)])

    static let members = GroupedTopCategory(category: .members,
                                            subCategories: [.init(category: .membersBySubmittedBands),
                                                            .init(category: .membersByWrittenReviews),
                                                            .init(category: .membersBySubmittedAlbums),
                                                            .init(category: .membersByArtistsAdded)])
}
