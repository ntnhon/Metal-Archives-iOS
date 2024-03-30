//
//  ReleaseTabsDatasource.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 11/10/2022.
//

import Foundation

enum ReleaseTab: CaseIterable {
    case songs
    case lineUp
    case reviews
    case otherVersions
    case additionalNotes

    var title: String {
        switch self {
        case .songs: return "Songs"
        case .lineUp: return "Line-up"
        case .reviews: return "Reviews"
        case .otherVersions: return "Other Versions"
        case .additionalNotes: return "Additional Notes"
        }
    }

    var iconName: String {
        switch self {
        case .songs: return "music.note.list"
        case .lineUp: return "person.3"
        case .reviews: return "star.bubble"
        case .otherVersions: return "circle.grid.cross"
        case .additionalNotes: return "info.circle"
        }
    }

    var selectedIconName: String {
        switch self {
        case .songs: return "music.note.list"
        case .lineUp: return "person.3.fill"
        case .reviews: return "star.bubble.fill"
        case .otherVersions: return "circle.grid.cross.fill"
        case .additionalNotes: return "info.circle.fill"
        }
    }
}

final class ReleaseTabsDatasource: HorizontalTabsDatasource {
    private(set) var selectedTab = ReleaseTab.songs {
        didSet {
            objectWillChange.send()
        }
    }

    override func numberOfTabs() -> Int {
        ReleaseTab.allCases.count
    }

    override func titleForTab(index: Int) -> String {
        ReleaseTab.allCases[index].title
    }

    override func normalSystemIconNameForTab(index: Int) -> String {
        ReleaseTab.allCases[index].iconName
    }

    override func selectedSystemIconNameForTab(index: Int) -> String {
        ReleaseTab.allCases[index].selectedIconName
    }

    override func isSelectedTab(index: Int) -> Bool {
        let tab = ReleaseTab.allCases[index]
        return tab == selectedTab
    }

    override func onSelectTab(index: Int) {
        selectedTab = ReleaseTab.allCases[index]
    }
}
