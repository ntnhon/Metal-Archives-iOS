//
//  ArtistTabsDatasource.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 02/11/2022.
//

import Foundation

enum ArtistTab: CaseIterable {
    case activeBands
    case pastBands
    case live
    case guestSession
    case miscStaff
    case biography
    case links

    var title: String {
        switch self {
        case .activeBands:
            "Active Bands"
        case .pastBands:
            "Past Bands"
        case .live:
            "Live"
        case .guestSession:
            "Guest/Session"
        case .miscStaff:
            "Misc. Staff"
        case .biography:
            "Biography"
        case .links:
            "Links"
        }
    }

    var iconName: String {
        switch self {
        case .activeBands:
            "circle"
        case .pastBands:
            "circle.dashed"
        case .live:
            "circle.lefthalf.filled"
        case .guestSession:
            "circle.righthalf.filled"
        case .miscStaff:
            "smallcircle.filled.circle"
        case .biography:
            "doc.plaintext"
        case .links:
            "link"
        }
    }

    var selectedIconName: String {
        switch self {
        case .activeBands:
            "circle.fill"
        case .pastBands:
            "circle.dashed.inset.filled"
        case .live:
            "circle.lefthalf.filled"
        case .guestSession:
            "circle.righthalf.filled"
        case .miscStaff:
            "smallcircle.filled.circle.fill"
        case .biography:
            "doc.plaintext.fill"
        case .links:
            "link"
        }
    }
}

final class ArtistTabsDatasource: HorizontalTabsDatasource {
    private let allTabs: [ArtistTab]
    private(set) var selectedTab: ArtistTab {
        didSet {
            objectWillChange.send()
        }
    }

    init(artist: Artist) {
        var allTabs = [ArtistTab]()
        if !artist.activeRoles.isEmpty { allTabs.append(.activeBands) }
        if !artist.pastRoles.isEmpty { allTabs.append(.pastBands) }
        if !artist.liveRoles.isEmpty { allTabs.append(.live) }
        if !artist.guestSessionRoles.isEmpty { allTabs.append(.guestSession) }
        if !artist.miscStaffRoles.isEmpty { allTabs.append(.miscStaff) }
        if artist.hasMoreBiography || artist.biography != nil { allTabs.append(.biography) }
        allTabs.append(.links)
        self.allTabs = allTabs
        selectedTab = allTabs.first ?? .links
    }

    override func numberOfTabs() -> Int {
        allTabs.count
    }

    override func titleForTab(index: Int) -> String {
        allTabs[index].title
    }

    override func normalSystemIconNameForTab(index: Int) -> String {
        allTabs[index].iconName
    }

    override func selectedSystemIconNameForTab(index: Int) -> String {
        allTabs[index].selectedIconName
    }

    override func isSelectedTab(index: Int) -> Bool {
        let tab = allTabs[index]
        return tab == selectedTab
    }

    override func onSelectTab(index: Int) {
        selectedTab = allTabs[index]
    }
}
