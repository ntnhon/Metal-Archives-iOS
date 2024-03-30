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
        case .songs:
            "Songs"
        case .lineUp:
            "Line-up"
        case .reviews:
            "Reviews"
        case .otherVersions:
            "Other Versions"
        case .additionalNotes:
            "Additional Notes"
        }
    }

    var iconName: String {
        switch self {
        case .songs:
            "music.note.list"
        case .lineUp:
            "person.3"
        case .reviews:
            "star.bubble"
        case .otherVersions:
            "circle.grid.cross"
        case .additionalNotes:
            "info.circle"
        }
    }

    var selectedIconName: String {
        switch self {
        case .songs:
            "music.note.list"
        case .lineUp:
            "person.3.fill"
        case .reviews:
            "star.bubble.fill"
        case .otherVersions:
            "circle.grid.cross.fill"
        case .additionalNotes:
            "info.circle.fill"
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
