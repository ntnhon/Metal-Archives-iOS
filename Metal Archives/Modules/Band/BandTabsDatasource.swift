//
//  BandTabsDatasource.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 10/10/2022.
//

import Foundation

enum BandTab: CaseIterable {
    case discography
    case members
    case reviews
    case similarArtists
    case relatedLinks

    var title: String {
        switch self {
        case .discography:
            "Discography"
        case .members:
            "Members"
        case .reviews:
            "Reviews"
        case .similarArtists:
            "Similar Artists"
        case .relatedLinks:
            "Related Links"
        }
    }

    var iconName: String {
        switch self {
        case .discography:
            "circle.grid.3x3"
        case .members:
            "person.3"
        case .reviews:
            "star.bubble"
        case .similarArtists:
            "dot.radiowaves.up.forward"
        case .relatedLinks:
            "link"
        }
    }

    var selectedIconName: String {
        switch self {
        case .discography:
            "circle.grid.3x3.fill"
        case .members:
            "person.3.fill"
        case .reviews:
            "star.bubble.fill"
        case .similarArtists:
            "dot.radiowaves.up.forward"
        case .relatedLinks:
            "link"
        }
    }
}

final class BandTabsDatasource: HorizontalTabsDatasource {
    private(set) var selectedTab = BandTab.discography {
        didSet {
            objectWillChange.send()
        }
    }

    override func numberOfTabs() -> Int {
        BandTab.allCases.count
    }

    override func titleForTab(index: Int) -> String {
        BandTab.allCases[index].title
    }

    override func normalSystemIconNameForTab(index: Int) -> String {
        BandTab.allCases[index].iconName
    }

    override func selectedSystemIconNameForTab(index: Int) -> String {
        BandTab.allCases[index].selectedIconName
    }

    override func isSelectedTab(index: Int) -> Bool {
        let tab = BandTab.allCases[index]
        return tab == selectedTab
    }

    override func onSelectTab(index: Int) {
        selectedTab = BandTab.allCases[index]
    }
}
