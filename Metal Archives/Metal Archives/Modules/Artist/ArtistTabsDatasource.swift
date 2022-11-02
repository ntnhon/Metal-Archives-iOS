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
        case .activeBands: return "Active Bands"
        case .pastBands: return "Past Bands"
        case .live: return "Live"
        case .guestSession: return "Guest/Session"
        case .miscStaff: return "Misc. Staff"
        case .biography: return "Biography"
        case .links: return "Links"
        }
    }

    var iconName: String {
        switch self {
        case .activeBands: return "circle"
        case .pastBands: return "circle.dashed"
        case .live: return "circle.lefthalf.filled"
        case .guestSession: return "circle.righthalf.filled"
        case .miscStaff: return "smallcircle.filled.circle"
        case .biography: return "doc.plaintext"
        case .links: return "link"
        }
    }

    var selectedIconName: String {
        switch self {
        case .activeBands: return "circle.fill"
        case .pastBands: return "circle.dashed.inset.filled"
        case .live: return "circle.lefthalf.filled"
        case .guestSession: return "circle.righthalf.filled"
        case .miscStaff: return "smallcircle.filled.circle.fill"
        case .biography: return "doc.plaintext.fill"
        case .links: return "link"
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
        self.selectedTab = allTabs.first ?? .links
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
