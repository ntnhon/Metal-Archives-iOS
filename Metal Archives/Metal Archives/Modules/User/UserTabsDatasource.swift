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
        case .comments: return "Comments"
        case .reviews: return "Reviews"
        case .albumCollection: return "Album Collection"
        case .wantedList: return "Wanted List"
        case .tradeList: return "Trade List"
        case .submittedBands: return "Submitted Bands"
        case .modificationHistory: return "Modification History"
        }
    }

    var iconName: String {
        switch self {
        case .comments: return "text.bubble"
        case .reviews: return "star.bubble"
        case .albumCollection: return "circle.grid.3x3"
        case .wantedList: return "circle.hexagongrid"
        case .tradeList: return "circlebadge.2"
        case .submittedBands: return "person.3"
        case .modificationHistory: return "pencil.circle"
        }
    }

    var selectedIconName: String {
        switch self {
        case .comments: return "text.bubble.fill"
        case .reviews: return "star.bubble.fill"
        case .albumCollection: return "circle.grid.3x3.fill"
        case .wantedList: return "circle.hexagongrid.fill"
        case .tradeList: return "circlebadge.2.fill"
        case .submittedBands: return "person.3.fill"
        case .modificationHistory: return "pencil.circle.fill"
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
        self.selectedTab = allTabs.first ?? .reviews
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
