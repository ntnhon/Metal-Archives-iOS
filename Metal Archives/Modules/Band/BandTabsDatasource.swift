//
//  BandTabsManager.swift
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
        case .discography: return "Discography"
        case .members: return "Members"
        case .reviews: return "Reviews"
        case .similarArtists: return "Similar Artists"
        case .relatedLinks: return "Related Links"
        }
    }

    var iconName: String {
        switch self {
        case .discography: return "circle.grid.3x3"
        case .members: return "person.3"
        case .reviews: return "star.bubble"
        case .similarArtists: return "dot.radiowaves.up.forward"
        case .relatedLinks: return "link"
        }
    }

    var selectedIconName: String {
        switch self {
        case .discography: return "circle.grid.3x3.fill"
        case .members: return "person.3.fill"
        case .reviews: return "star.bubble.fill"
        case .similarArtists: return "dot.radiowaves.up.forward"
        case .relatedLinks: return "link"
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
