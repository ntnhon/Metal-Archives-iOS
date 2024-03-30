//
//  UserTabsDatasource.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 07/11/2022.
//

import Foundation

enum UserTab: CaseIterable {
    case comments
    case reviews
    case albumCollection
    case wantedList
    case tradeList
    case submittedBands
    case modificationHistory

    var title: String {
        switch self {
        case .comments:
            "Comments"
        case .reviews:
            "Reviews"
        case .albumCollection:
            "Album Collection"
        case .wantedList:
            "Wanted List"
        case .tradeList:
            "Trade List"
        case .submittedBands:
            "Submitted Bands"
        case .modificationHistory:
            "Modification History"
        }
    }

    var iconName: String {
        switch self {
        case .comments:
            "text.bubble"
        case .reviews:
            "star.bubble"
        case .albumCollection:
            "circle.grid.3x3"
        case .wantedList:
            "circle.hexagongrid"
        case .tradeList:
            "circlebadge.2"
        case .submittedBands:
            "person.3"
        case .modificationHistory:
            "pencil.circle"
        }
    }

    var selectedIconName: String {
        switch self {
        case .comments:
            "text.bubble.fill"
        case .reviews:
            "star.bubble.fill"
        case .albumCollection:
            "circle.grid.3x3.fill"
        case .wantedList:
            "circle.hexagongrid.fill"
        case .tradeList:
            "circlebadge.2.fill"
        case .submittedBands:
            "person.3.fill"
        case .modificationHistory:
            "pencil.circle.fill"
        }
    }
}

final class UserTabsDatasource: HorizontalTabsDatasource {
    private let allTabs: [UserTab]
    private(set) var selectedTab: UserTab {
        didSet {
            objectWillChange.send()
        }
    }

    init(user: User) {
        var allTabs = UserTab.allCases
        if user.comments == nil { allTabs.removeAll { $0 == .comments } }
        self.allTabs = allTabs
        selectedTab = allTabs.first ?? .reviews
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
